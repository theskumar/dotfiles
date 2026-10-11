#!/usr/bin/env python3
"""Preload AgentsInTheCloud workspace images into the System's nested Docker.

Why: this ISP routes IPv4 to GitHub's package CDN (pkg-containers.githubusercontent.com)
at about 150 KiB/s. IPv6 is fast, but OrbStack containers egress over IPv4 only.
The System's own pull of the 2 GB workspace image then hits its 30-minute timeout.

This script downloads the blobs on the Mac (curl prefers IPv6), writes an OCI layout,
and streams it into the nested Docker with docker load. The System's later
docker pull by digest finds every blob locally and finishes in about a second.

Usage: preload-images.py [REF ...]
Default REFs: the eagerly-preload label of every app image inside the System.
Run it after an app update stalls on "Downloading workspace image", then
docker restart agents-in-the-cloud-system.
"""
import hashlib, json, os, shutil, subprocess, sys, tempfile, urllib.request
from concurrent.futures import ThreadPoolExecutor

SYS = "agents-in-the-cloud-system"
os.environ["PATH"] = "/opt/homebrew/bin:/usr/local/bin:" + os.environ["PATH"]
IDX = "application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.list.v2+json"
MAN = "application/vnd.oci.image.manifest.v1+json,application/vnd.docker.distribution.manifest.v2+json"

def sh(*args, **kw):
    return subprocess.run(args, check=True, capture_output=True, text=True, **kw).stdout

def default_refs():
    refs = set()
    for img in sh("docker", "exec", SYS, "docker", "image", "ls", "--format", "{{.Repository}}:{{.Tag}}").split():
        if img.startswith("ghcr.io/lucasmeijer/agents-in-the-cloud:"):
            label = sh("docker", "exec", SYS, "docker", "image", "inspect", img, "--format", '{{index .Config.Labels "eagerly-preload"}}').strip()
            refs.update(json.loads(label or "[]"))
    return sorted(refs)

def preload(ref, arch):
    name, digest = ref.split("@")
    repo_tag = name.removeprefix("ghcr.io/")
    repo, tag = repo_tag.rsplit(":", 1)
    tok = json.load(urllib.request.urlopen(f"https://ghcr.io/token?scope=repository:{repo}:pull"))["token"]
    d = tempfile.mkdtemp(prefix="aitc-oci-")
    b = f"{d}/blobs/sha256"
    os.makedirs(b)

    def get(dg, kind="blobs", accept="*/*"):
        p = f"{b}/{dg.split(':')[1]}"
        subprocess.run(["curl", "-sfL", "--retry", "3", "-H", f"Authorization: Bearer {tok}", "-H", f"Accept: {accept}",
                        "-o", p, f"https://ghcr.io/v2/{repo}/{kind}/{dg}"], check=True)
        with open(p, "rb") as f:
            h = "sha256:" + hashlib.file_digest(f, "sha256").hexdigest()
        if h != dg:
            sys.exit(f"digest mismatch for {dg}")
        return p

    top = json.load(open(get(digest, "manifests", IDX + "," + MAN)))
    if "manifests" in top:
        desc = next(m for m in top["manifests"] if m.get("platform", {}).get("architecture") == arch and m["platform"].get("os") == "linux")
    else:
        desc = {"digest": digest, "mediaType": top["mediaType"]}
    man = json.load(open(get(desc["digest"], "manifests", MAN)))
    get(man["config"]["digest"])
    with ThreadPoolExecutor(6) as ex:
        list(ex.map(lambda l: get(l["digest"]), man["layers"]))
    size = os.path.getsize(f"{b}/{desc['digest'].split(':')[1]}")
    json.dump({"schemaVersion": 2, "mediaType": "application/vnd.oci.image.index.v1+json", "manifests": [{
        "mediaType": desc["mediaType"], "digest": desc["digest"], "size": size,
        "platform": {"architecture": arch, "os": "linux"},
        "annotations": {"io.containerd.image.name": name, "org.opencontainers.image.ref.name": tag}}]},
        open(f"{d}/index.json", "w"))
    open(f"{d}/oci-layout", "w").write('{"imageLayoutVersion":"1.0.0"}')
    tar = subprocess.Popen(["tar", "-C", d, "-cf", "-", "oci-layout", "index.json", "blobs"], stdout=subprocess.PIPE)
    subprocess.run(["docker", "exec", "-i", SYS, "docker", "load"], stdin=tar.stdout, check=True)
    tar.wait()
    shutil.rmtree(d)

if __name__ == "__main__":
    arch = {"aarch64": "arm64", "x86_64": "amd64"}[sh("docker", "exec", SYS, "uname", "-m").strip()]
    for ref in sys.argv[1:] or default_refs():
        print("preloading", ref, flush=True)
        preload(ref, arch)
