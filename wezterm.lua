-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Log warnings or generate errors if we define an invalid configuration option
local config = wezterm.config_builder()

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab.tab_title ~= "" and tab.tab_title or tab.active_pane.title

  return {
    { Foreground = { Color = tab.is_active and '#d3869b' or '#a89984' } },
    { Text = ' ' .. (tab.tab_index + 1) .. ': ' },
    { Attribute = { Italic = true } },
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = tab.is_active and '#7daea3' or '#a89984' } },
    { Text = title .. ' ' },
    { Attribute = { Italic = false } },
    { Attribute = { Intensity = "Normal" } },
  }
end)

wezterm.on('update-right-status', function(window, pane)
  local key_table = window:active_key_table()
  local status = {}

  if key_table then
    table.insert(status, { Attribute = { Italic = true } })
    table.insert(status, { Attribute = { Intensity = "Bold" } })
    table.insert(status, { Foreground = { Color = '#ea6962' } })
    table.insert(status, { Text = key_table .. ' ' })
    table.insert(status, { Attribute = { Italic = false } })
    table.insert(status, { Attribute = { Intensity = "Normal" } })
  end

  table.insert(status, { Attribute = { Intensity = "Bold" } })
  table.insert(status, { Foreground = { Color = '#a89984' } })
  table.insert(status, { Text = '[ ' })
  table.insert(status, { Attribute = { Italic = true } })
  table.insert(status, { Foreground = { Color = '#89b482' } })
  table.insert(status, { Text = window:active_workspace() })
  table.insert(status, { Attribute = { Italic = false } })
  table.insert(status, { Foreground = { Color = '#a89984' } })
  table.insert(status, { Text = ' ]' })
  table.insert(status, { Attribute = { Intensity = "Normal" } })

  window:set_right_status(wezterm.format(status))
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
-- Pane geometry helpers for sidebar/scratchpad management.
--

-- Returns the bottommost pane in the tab, or nil if no bottom split exists.
local function find_bottom_pane(tab)
  local panes = tab:panes_with_info()
  local bottom = nil
  for _, p in ipairs(panes) do
    if not bottom or p.top > bottom.top then
      bottom = p
    end
  end
  return (bottom and bottom.top > 0) and bottom.pane or nil
end

-- Returns the leftmost sidebar pane in the tab, or nil if no left split exists.
local function find_left_pane(tab)
  local panes = tab:panes_with_info()
  local min_left, max_left = math.huge, 0
  for _, p in ipairs(panes) do
    if p.left < min_left then min_left = p.left end
    if p.left > max_left then max_left = p.left end
  end
  if max_left == 0 then return nil end
  -- Among panes at min_left, pick the one closest to the top
  local found = nil
  for _, p in ipairs(panes) do
    if p.left == min_left and (not found or p.top < found.top) then
      found = p
    end
  end
  return found and found.pane or nil
end

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
	-- Scratchpad / sidebar panes
	--

	{ -- Focus or create bottom 30% scratchpad pane
		key = "PageUp",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:active_tab()
			local bottom = find_bottom_pane(tab)
			if bottom then
				bottom:activate()
			else
				window:perform_action(
					wezterm.action.SplitPane({
						direction = "Down",
						size = { Percent = 30 },
						command = { args = { "tmux", "new-session", "-A", "-s", "wezterm-bottom-" .. tab:tab_id() } },
					}),
					pane
				)
			end
		end),
	},
	{ -- Close bottom scratchpad pane
		key = "PageDown",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local bottom = find_bottom_pane(window:active_tab())
			if bottom then
				window:perform_action(
					wezterm.action.CloseCurrentPane({ confirm = false }),
					bottom
				)
			end
		end),
	},
	{ -- Focus or create left 28% sidebar pane
		key = "End",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:active_tab()
			local left = find_left_pane(tab)
			if left then
				left:activate()
			else
				window:perform_action(
					wezterm.action.SplitPane({
						direction = "Left",
						size = { Percent = 28 },
						command = { args = { "tmux", "new-session", "-A", "-s", "wezterm-left-" .. tab:tab_id() } },
					}),
					pane
				)
			end
		end),
	},
	{ -- Close left sidebar pane
		key = "Home",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			local left = find_left_pane(window:active_tab())
			if left then
				window:perform_action(
					wezterm.action.CloseCurrentPane({ confirm = false }),
					left
				)
			end
		end),
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
			action = wezterm.action_callback(function(window, pane)
				local tab_id = window:active_tab():tab_id()
				wezterm.run_child_process({ "tmux", "kill-session", "-t", "wezterm-bottom-" .. tab_id })
				wezterm.run_child_process({ "tmux", "kill-session", "-t", "wezterm-left-" .. tab_id })
				window:perform_action(wezterm.action.CloseCurrentTab({ confirm = false }), pane)
			end),
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
		{ -- Split pane vertically (bottom, 50%)
			key = "s",
			action = wezterm.action.SplitPane({
				direction = "Down",
				size = { Percent = 50 },
			}),
		},
		{ -- Split pane horizontally (left, 50%)
			key = "v",
			action = wezterm.action.SplitPane({
				direction = "Left",
				size = { Percent = 50 },
			}),
		},
		{ -- Close current pane (no-op if last pane, use tab_mode q to close the tab)
			key = "q",
			action = wezterm.action_callback(function(window, pane)
				local tab = window:active_tab()
				if #tab:panes() > 1 then
					window:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), pane)
				end
			end),
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
