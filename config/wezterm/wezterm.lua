local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.default_cursor_style = "SteadyBar"
config.automatically_reload_config = true
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "RESIZE"
config.check_for_updates = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.font_size = 12.5
config.enable_tab_bar = false
config.window_padding = {
	left = 16,
	right = 0,
	top = 8,
	bottom = 0,
}
config.color_scheme="Catppuccin Mocha"
config.background = {
	{
		source = {
			Color = "#282c35",
		},
		width = "100%",
		height = "100%",
		opacity = 0.95,
	},
}
config.macos_window_background_blur = 5
config.hyperlink_rules = {
	-- Matches: a URL in parens: (URL)
	{
		regex = "\\((\\w+://\\S+)\\)",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in brackets: [URL]
	{
		regex = "\\[(\\w+://\\S+)\\]",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in curly braces: {URL}
	{
		regex = "\\{(\\w+://\\S+)\\}",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in angle brackets: <URL>
	{
		regex = "<(\\w+://\\S+)>",
		format = "$1",
		highlight = 1,
	},
	-- Then handle URLs not wrapped in brackets
	{
		regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
		format = "$1",
		highlight = 1,
	},
}

config.keys = {
    -- Send Shift+Enter as a distinct key sequence
    {
      key = 'Enter',
      mods = 'SHIFT',
      action = wezterm.action.SendString('\x1b[13;2u'),
    },
    -- Cmd+K to clear terminal (like iTerm2/Terminal.app)
    {
      key = 'k',
      mods = 'CMD',
      action = wezterm.action.ClearScrollback('ScrollbackAndViewport'),
    },
    -- Option+Left/Right to jump between words
    {
      key = 'LeftArrow',
      mods = 'OPT',
      action = wezterm.action.SendString('\x1bb'),  -- Alt+b (backward word)
    },
    {
      key = 'RightArrow',
      mods = 'OPT',
      action = wezterm.action.SendString('\x1bf'),  -- Alt+f (forward word)
    },
  }

return config;