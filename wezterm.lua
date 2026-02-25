-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Log warnings or generate errors if we define an invalid configuration option
local config = wezterm.config_builder()

-- Format window title to prefer explicit tab titles over process names
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  -- Use explicit tab title if set, otherwise fall back to process name
  if tab.tab_title and tab.tab_title ~= "" then
    return tab.tab_title
  end
  -- Fallback to active pane's title (process name)
  return tab.active_pane.title
end)

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(wezterm.format({
    { Foreground = { Color = '#89b482' } },
    { Text = window:active_workspace() },
  }))
end)

--
-- General configuration options.
--

-- Do not check for or show window with update information
config.check_for_updates = false

-- Improve wezterm graphical performance 
config.front_end = "OpenGL"
config.max_fps = 144
config.animation_fps = 144

-- Spawn a zsh shell in login mode
config.default_prog = { os.getenv("HOME") .. '/.nix-profile/bin/zsh', '-l' }

-- Font configuration
config.font = wezterm.font("Fisa Code")
config.font_size = 10.0

-- Setup our persistent domains
config.unix_domains = {
  { name = 'unix', }
}
config.default_gui_startup_args = { 'connect', 'unix' }

-- Gruvbox Material Dark color scheme
config.colors = {
	foreground = "#D4BE98",
	background = "#282828",
	cursor_bg = "#A89984",
	cursor_fg = "#3C3836",
	cursor_border = "#A89984",
	selection_fg = "#A89984",
	selection_bg = "#3C3836",

	ansi = {
		"#282828", -- black (bg0)
		"#EA6962", -- red
		"#A9B665", -- green
		"#D8A657", -- yellow
		"#7DAEA3", -- blue
		"#D3869B", -- purple
		"#89B482", -- aqua
		"#D4BE98", -- white (fg0)
	},

	brights = {
		"#7C6F65", -- bright black (grey0)
		"#EA6962", -- bright red
		"#A9B665", -- bright green
		"#D8A657", -- bright yellow
		"#7DAEA3", -- bright blue
		"#D3869B", -- bright purple
		"#89B482", -- bright aqua
		"#DDC7A1", -- bright white (fg1)
	},
}

-- Pad window borders
config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 10,
}

--
-- Tab bar configuration options.
--

-- Disable modern tab bar
config.use_fancy_tab_bar = false
config.tab_max_width = 32

-- Tab bar colors
config.colors.tab_bar = {
	background = "#32302f",
	active_tab = {
		bg_color = "#32302f",
		fg_color = "#7daea3",
		intensity = "Bold",
		italic = true,
	},
	inactive_tab = {
		bg_color = "#32302f",
		fg_color = "#a89984",
		intensity = "Bold",
		italic = true,
	},
	inactive_tab_hover = {
		bg_color = "#32302f",
		fg_color = "#a89984",
		intensity = "Bold",
		italic = true,
	},
	new_tab = {
		bg_color = "#32302f",
		fg_color = "#a89984",
		intensity = "Bold",
		italic = true,
	},
	new_tab_hover = {
		bg_color = "#32302f",
		fg_color = "#a89984",
		intensity = "Bold",
		italic = true,
	},
}

--
-- Keymaps configuration.
--

-- Disable the default keybindings
config.disable_default_key_bindings = true

-- Setup leader key
config.leader = { key = "a", mods = "ALT", timeout_milliseconds = 2000 }

-- General keymaps
config.keys = {
	--
	-- Enter key table modes
	--

  { -- Enter workspace management mode
    key = "w",
    mods = "LEADER",
    action = wezterm.action.ActivateKeyTable({
      name = "workspace_mode",
      one_shot = true,
    }),
  },
	{ -- Enter tab management mode
		key = "t",
		mods = "LEADER",
		action = wezterm.action.ActivateKeyTable({
			name = "tab_mode",
			one_shot = true,
		}),
	},
	{ -- Enter pane management mode
		key = "p",
		mods = "LEADER",
		action = wezterm.action.ActivateKeyTable({
			name = "pane_mode",
			one_shot = true,
		}),
	},

	--
	-- Navigation
	--

	{ -- Focus previous tab
		key = "LeftArrow",
		mods = "ALT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{ -- Focus next tab
		key = "RightArrow",
		mods = "ALT",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{ -- Focus previous pane
		key = "UpArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection("Prev"),
	},

	{ -- Focus next pane
		key = "DownArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection("Next"),
	},

  ---
  --- Rezising
  ---

  {
    key = "LeftArrow",
    mods = "ALT|SHIFT",
    action = wezterm.action.AdjustPaneSize { "Left", 5 },
  },
  {
    key = "RightArrow",
    mods = "ALT|SHIFT",
    action = wezterm.action.AdjustPaneSize { "Right", 5 },
  },
  {
    key = "UpArrow",
    mods = "ALT|SHIFT",
    action = wezterm.action.AdjustPaneSize { "Up", 5 },
  },
  {
    key = "DownArrow",
    mods = "ALT|SHIFT",
    action = wezterm.action.AdjustPaneSize { "Down", 5 },
  },

	{ -- Focus largest (master) pane
		key = "Delete",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:active_tab()
			local largest = nil
			local largest_size = 0

			for _, p in ipairs(tab:panes()) do
				local dims = p:get_dimensions()
				local size = dims.pixel_width * dims.pixel_height
				if size > largest_size then
					largest_size = size
					largest = p
				end
			end

			if largest and largest:pane_id() ~= pane:pane_id() then
				largest:activate()
			end
		end),
	},

	--
	-- Copy / Paste
	--

	{ -- Enter copy mode
		key = "c",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},

	{ -- Paste from clipboard
		key = "v",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PasteFrom("Clipboard"),
	},

	--
	-- Miscellaneous
	--

	{ -- This lets us unify delete word across programs
		key = "Backspace",
		mods = "CTRL",
		action = wezterm.action.SendKey({ key = "w", mods = "CTRL" }),
	},
}

--
-- Key table definitions for modal keybinding namespaces
--

config.key_tables = {
  -- Domain management mode (LEADER + d)
  workspace_mode = {
   { -- (d)efault
      key = "d",
      action = wezterm.action.SwitchToWorkspace {
        name = "default",
      }
   },
   { -- (s)ysadmin
      key = "s",
      action = wezterm.action.SwitchToWorkspace {
        name = "sysadmin",
      }
    },
    { -- (c)hat
      key = "c",
      action = wezterm.action.SwitchToWorkspace {
        name = "chat",
      }
    },
    { -- (m)edia
      key = "m",
      action = wezterm.action.SwitchToWorkspace {
        name = "media",
      }
    },
    { -- (a)cademics
      key = "a",
      action = wezterm.action.SwitchToWorkspace {
        name = "academics",
      }
    },
    -- Exit back to default state
    { key = "Escape", action = "PopKeyTable" },
  },

	-- Tab management mode (LEADER + t)
	tab_mode = {
		{ -- Create new tab
			key = "n",
			action = wezterm.action.SpawnTab "CurrentPaneDomain",
		},
		{ -- Close current tab
			key = "q",
			action = wezterm.action.CloseCurrentTab({ confirm = false }),
		},
		{ -- Rename current tab
			key = "r",
			action = wezterm.action_callback(function(window, pane)
				local success, stdout, stderr = wezterm.run_child_process({
					"dmenu",
					"-fn",
					"Fisa Code-10",
					"-p",
					"Tab name:",
				})
				if success and stdout then
					local name = stdout:gsub("\n", "")
					if name ~= "" then
						window:active_tab():set_title(name)
					end
				end
			end),
		},
    -- Exit back to default state
    { key = "Escape", action = "PopKeyTable" },
	},

	-- Pane management mode (LEADER + p)
	pane_mode = {
		{ -- Split pane vertically (bottom, 30%)
			key = "s",
			action = wezterm.action.SplitPane({
				direction = "Down",
				size = { Percent = 30 },
			}),
		},
		{ -- Split pane horizontally (left, 28%)
			key = "v",
			action = wezterm.action.SplitPane({
				direction = "Left",
				size = { Percent = 50 },
			}),
		},
		{ -- Close current pane
			key = "q",
			action = wezterm.action.CloseCurrentPane({ confirm = false }),
		},
		{ -- Maximize/zoom pane
			key = "m",
			action = wezterm.action.TogglePaneZoomState,
		},
    -- Exit back to default state
    { key = "Escape", action = "PopKeyTable" },
	},
}

-- Jump to specific tabs by number (ALT + 1-9)
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config
