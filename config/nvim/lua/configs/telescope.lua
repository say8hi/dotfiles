return {
  defaults = {
    prompt_prefix = "   ",
    selection_caret = " ",
    entry_prefix = " ",
    sorting_strategy = "ascending",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
      },
      width = 0.87,
      height = 0.80,
    },
    mappings = {
      n = { ["q"] = require("telescope.actions").close },
    },
    file_ignore_patterns = {},
  },
  pickers = {
    find_files = {
      hidden = true,
      no_ignore = true,
    },
  },
  extensions_list = { "themes", "terms" },
  extensions = {},
}
