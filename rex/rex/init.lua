-- Rex config migrated from tmux, Herdr and Ghostty.

-- Prefix: ctrl+a (tmux ^A, Herdr ctrl+a). Pass it through to programs.
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- tmux (~/.config/tmux/tmux.reset.conf, ~/.config/tmux/tmux.conf)
rex.bind("ctrl+a>shift+s", "session.switch")
rex.bind("ctrl+a>shift+h", "client.tab.previous")
rex.bind("ctrl+a>shift+l", "client.tab.next")
rex.bind("ctrl+a>r", "client.tab.rename")
rex.bind("ctrl+a>shift+'", "session.switch")
rex.bind("ctrl+a>s", "pane.split", { direction = "down" })
rex.bind("ctrl+a>v", "pane.split", { direction = "right" })
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "down" })
rex.bind("ctrl+a>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+a>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+a>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>,", "pane.resize", { amount = 20, direction = "left" })
rex.bind("ctrl+a>.", "pane.resize", { amount = 20, direction = "right" })
rex.bind("ctrl+a>-", "pane.resize", { amount = 7, direction = "down" })
rex.bind("ctrl+a>=", "pane.resize", { amount = 7, direction = "up" })
rex.bind("ctrl+a>shift+r", "client.config.reload")
rex.bind("ctrl+a>ctrl+y", "client.tab.new")
rex.bind("ctrl+a>ctrl+p", "client.tab.new")

-- tmux repeatable (bind -r) resize bindings
rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+a>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")
rex.bind("repeat/,", "pane.resize", { amount = 20, direction = "left" })
rex.bind("repeat/.", "pane.resize", { amount = 20, direction = "right" })
rex.bind("repeat/-", "pane.resize", { amount = 7, direction = "down" })
rex.bind("repeat/=", "pane.resize", { amount = 7, direction = "up" })

-- Herdr (~/.config/herdr/config.toml)
rex.bind("ctrl+a>[", "pane.focus_previous")
rex.bind("ctrl+a>]", "pane.focus_next")
rex.bind("ctrl+a>ctrl+c", "client.tab.new")   -- also tmux `bind ^C new-window`
rex.bind("ctrl+a>x", "pane.close")            -- wins over tmux `bind x swap-pane -D`
rex.bind("ctrl+a>c", "pane.close")            -- also tmux `bind c kill-pane`
rex.bind("ctrl+a>shift+x", "client.tab.close")
rex.bind("ctrl+a>b", "client.sidebar.toggle")
rex.bind("ctrl+a>w", "session.switch")

-- Ghostty (~/.config/ghostty/config)
rex.bind("shift+cmd+r", "client.config.reload")

-- Lazygit popup at the git root of the focused pane (tmux prefix+C-j, Ghostty cmd+j).
rex.action{
  name  = "lazygit",
  title = "Lazygit (git root)",
  run   = function(ctx, args)
    local dir = os.getenv("HOME")
    if ctx.block_id then
      local r = rex.block.call("com.superlogical.terminal", "pwd", { block_id = ctx.block_id })
      if r and r.pwd then
        dir = (r.pwd:gsub("^file://[^/]*", ""):gsub("%%(%x%x)", function(h)
          return string.char(tonumber(h, 16))
        end))
      end
    end
    local git = rex.exec({ "git", "rev-parse", "--show-toplevel" }, { cwd = dir, timeout = 5 })
    if git and git.ok then dir = (git.stdout:gsub("%s+$", "")) end
    local l, err = rex.session.new_layer{
      bounds = { 0.05, 0.05, 0.9, 0.9 },
      focus  = true,
      layout = rex.layout.block{
        flavor  = "com.superlogical.terminal.shell",
        label   = "lazygit",
        options = { command = { "lazygit" }, cwd = dir },
      },
    }
    if err ~= nil then error(err, 0) end
    return { layer_id = l.layer_id }
  end,
}
rex.bind("cmd+j", "lazygit")
