// Based on @opalelement's answer https://github.com/johnste/finicky/issues/96#issuecomment-844571182
// Team ID can be found in the browser URL : https://slack.com/help/articles/221769328-Locate-your-Slack-URL-or-ID
// Free, Pro, and Business+ plans => Team or workspace ID starts with a T in https://app.slack.com/client/TXXXXXXX/CXXXXXXX
// Enterprise grid plans => Org ID starts with an E in https://app.slack.com/client/EXXXXXXX/CXXXXXXX
const workSlackTeamMapping = {
  fueled: "T048W193T",
  // 'acmecorp.enterprise': 'EXXXXXXX',
  // 'acmecorp': 'EXXXXXXX',
};

const personalSlackMapping = {
  // personal slacks
};

const slackSubdomainMapping = {
  ...workSlackTeamMapping,
  ...personalSlackMapping,
};

const slackRewriter = {
  match: ["*.slack.com/*"],
  url: function (urlObj) {
    const subdomain = urlObj.host.slice(0, -10); // before .slack.com
    const pathParts = urlObj.pathname.split("/");

    let team,
      patterns = {};
    if (subdomain != "app") {
      if (!Object.keys(slackSubdomainMapping).includes(subdomain)) {
        console.log(
          `No Slack team ID found for ${urlObj.host}`,
          `Add a correct team ID to ~/.finicky.js to allow direct linking to Slack.`,
        );
        return urlObj;
      }
      team = slackSubdomainMapping[subdomain];

      if (subdomain.slice(-11) == ".enterprise") {
        patterns = {
          file: [/\/files\/\w+\/(?<id>\w+)/],
        };
      } else {
        patterns = {
          file: [/\/messages\/\w+\/files\/(?<id>\w+)/],
          team: [/(?:\/messages\/\w+)?\/team\/(?<id>\w+)/],
          channel: [
            /\/(?:messages|archives)\/(?<id>\w+)(?:\/(?<message>p\d+))?/,
          ],
        };
      }
    } else {
      patterns = {
        file: [
          /\/client\/(?<team>\w+)\/\w+\/files\/(?<id>\w+)/,
          /\/docs\/(?<team>\w+)\/(?<id>\w+)/,
        ],
        team: [/\/client\/(?<team>\w+)\/\w+\/user_profile\/(?<id>\w+)/],
        channel: [
          /\/client\/(?<team>\w+)\/(?<id>\w+)(?:\/(?<message>[\d.]+))?/,
        ],
      };
    }

    for (let [host, host_patterns] of Object.entries(patterns)) {
      for (let pattern of host_patterns) {
        let match = pattern.exec(urlObj.pathname);
        if (match) {
          let search = `team=${team || match.groups.team}`;

          if (match.groups.id) {
            search += `&id=${match.groups.id}`;
          }

          if (match.groups.message) {
            let message = match.groups.message;
            if (message.charAt(0) == "p") {
              message = message.slice(1, 11) + "." + message.slice(11);
            }
            search += `&message=${message}`;
          }

          let outputStr = `slack://${host}?${search}`;
          console.log(
            `Rewrote Slack URL ${urlObj.href} to deep link ${outputStr}`,
          );

          return new URL(outputStr);
        }
      }
    }

    return urlObj;
  },
};

export default {
  defaultBrowser: "Arc",
  rewrite: [slackRewriter],
  handlers: [
    {
      match: ({ url }) => {
        // Check for both 'slack:' and 'slack' since the property might not include the colon
        return url.protocol === "slack:" || url.protocol === "slack";
      },
      browser: "Slack",
    },
    {
      // Optional. If these work url cannot be converted, open them is work browser
      // Login in work workspace unfortunately lands on the personal browser, just copy the link to the work browser
      match: ({ url }) => {
        const workDomains = Object.keys(workSlackTeamMapping).map(
          (subdomain) => subdomain + ".slack.com",
        );
        return workDomains.includes(url.host);
      },
      browser: "Arc", // your work browser
    },
    {
      // Open all linear.app links in the Linear macOS app
      match: finicky.matchHostnames(["linear.app"]),
      url: ({ url }) => {
        // Example: https://linear.app/myteam/issue/ABC-123 -> linear://myteam/issue/ABC-123
        const path = url.pathname.replace(/^\//, "");
        return `linear://${path}`;
      },
      browser: {
        name: "Linear",
        // or the bundle id if needed: "com.linear.app"
      },
    },
  ],
};
