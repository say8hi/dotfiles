local M = {}

M.base_30 = {
	white = "{{colors.on_surface.default.hex}}",
	darker_black = "{{colors.surface_container.default.hex}}", -- sidebar bg (nvim-tree, telescope, etc)
	black = "{{colors.background.default.hex | set_lightness: -0.2}}", --  nvim bg
	black2 = "{{colors.surface.default.hex}}",
	one_bg = "{{colors.surface_dim.default.hex}}",
	one_bg2 = "{{colors.surface_bright.default.hex}}",
	one_bg3 = "{{colors.surface_container_low.default.hex}}",
	grey = "{{colors.surface_variant.default.hex}}",
	grey_fg = "{{colors.surface_variant.default.hex | set_lightness: 5.0}}",
	grey_fg2 = "{{colors.surface_variant.default.hex | set_lightness: 10.0}}",
	light_grey = "{{colors.on_surface_variant.default.hex | set_lightness: -20.0}}",
	red = "{{colors.error.default.hex}}",
	baby_pink = "{{colors.error.default.hex | set_lightness: 15.0}}",
	pink = "{{colors.tertiary_fixed.default.hex}}",
	line = "{{colors.surface_dim.default.hex}}", -- for lines like vertsplit
	green = "{{colors.tertiary.default.hex}}",
	vibrant_green = "{{colors.tertiary.default.hex | set_lightness: 10.0}}",
	nord_blue = "{{colors.primary.default.hex | set_lightness: 5.0}}",
	blue = "{{colors.primary.default.hex}}",
	yellow = "{{colors.secondary.default.hex}}",
	sun = "{{colors.secondary.default.hex | set_lightness: 10.0}}",
	purple = "{{colors.tertiary_fixed.default.hex | set_lightness: -5.0}}",
	dark_purple = "{{colors.tertiary_fixed.default.hex | set_lightness: -15.0}}",
	teal = "{{colors.primary_fixed.default.hex}}",
	orange = "{{colors.secondary.default.hex | set_lightness: -10.0}}",
	cyan = "{{colors.primary_fixed.default.hex | set_lightness: 5.0}}",
	statusline_bg = "{{colors.surface.default.hex | set_lightness: -10.0}}",
	lightbg = "{{colors.surface_bright.default.hex}}",
	pmenu_bg = "{{colors.primary.default.hex}}",
	folder_bg = "{{colors.primary.default.hex}}",
	lavender = "{{colors.primary_fixed.default.hex | set_lightness: 10.0}}",
}

M.base_16 = {
	base00 = "{{colors.background.default.hex}}",
	base01 = "{{colors.surface.default.hex}}",
	base02 = "{{colors.surface_dim.default.hex}}",
	base03 = "{{colors.surface_variant.default.hex}}",
	base04 = "{{colors.on_surface_variant.default.hex}}",
	base05 = "{{colors.on_surface.default.hex}}",
	base06 = "{{colors.on_surface.default.hex | set_lightness: 5.0}}",
	base07 = "{{colors.on_surface.default.hex | set_lightness: 10.0}}",
	base08 = "{{colors.error.default.hex}}",
	base09 = "{{colors.secondary.default.hex | set_lightness: -10.0}}",
	base0A = "{{colors.secondary.default.hex}}",
	base0B = "{{colors.tertiary.default.hex}}",
	base0C = "{{colors.primary_fixed.default.hex}}",
	base0D = "{{colors.primary.default.hex}}",
	base0E = "{{colors.tertiary_fixed.default.hex}}",
	base0F = "{{colors.error.default.hex | set_lightness: 5.0}}",
}

M.polish_hl = {
	defaults = {
		Normal = { bg = M.base_30.black },
		NormalFloat = { bg = M.base_30.darker_black },
		NvimTreeNormal = { bg = M.base_30.darker_black },
		NvimTreeNormalNC = { bg = M.base_30.darker_black },
		TelescopeNormal = { bg = M.base_30.darker_black },
		TelescopePrompt = { bg = M.base_30.darker_black },
		TelescopeResults = { bg = M.base_30.darker_black },
		Pmenu = { bg = M.base_30.black2 },
		CmpPmenu = { bg = M.base_30.black2 },
		BlinkCmpMenu = { bg = M.base_30.black2 },
		Visual = { bg = M.base_30.grey },
		VisualNOS = { bg = M.base_30.grey },
	},

	treesitter = {
		["@variable"] = { fg = M.base_30.white },
		["@module"] = { fg = M.base_30.white },
		["@variable.member"] = { fg = M.base_30.white },
		["@property"] = { fg = M.base_30.teal },
		["@variable.builtin"] = { fg = M.base_30.red },
		["@type.builtin"] = { fg = M.base_30.purple },
		["@variable.parameter"] = { fg = M.base_30.orange },
		["@operator"] = { fg = M.base_30.cyan },
		["@punctuation.delimiter"] = { fg = M.base_30.cyan },
		["@punctuation.bracket"] = { fg = M.base_30.cyan },
		["@punctuation.special"] = { fg = M.base_30.teal },
		["@function.macro"] = { fg = M.base_30.pink },
		["@keyword.storage"] = { fg = M.base_30.purple },
		["@tag.delimiter"] = { fg = M.base_30.cyan },
		["@function"] = { fg = M.base_30.blue },
		["@constructor"] = { fg = M.base_30.lavender },
		["@tag.attribute"] = { fg = M.base_30.orange },
	},

	syntax = {
		StorageClass = { fg = M.base_30.purple },
		Repeat = { fg = M.base_30.purple },
		Define = { fg = M.base_30.blue },
	},

	telescope = {
		TelescopeSelection = { bg = M.base_30.one_bg, fg = M.base_30.blue },
	},
}

M.type = "dark"

M = require("base46").override_theme(M, "matugen")

return M
