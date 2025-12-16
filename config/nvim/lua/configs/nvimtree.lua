return {
  filters = {
    dotfiles = false,
    git_ignored = false,
  },
  disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    width = 30,
    preserve_window_proportions = false,
    side = "left",
    number = false,
    relativenumber = false,
  },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = false,
      window_picker = {
        enable = true,
      },
    },
    remove_file = {
      close_window = false,
    },
  },
  on_attach = function(bufnr)
    local api = require "nvim-tree.api"

    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- custom handler for file deletion
    vim.keymap.set("n", "d", function()
      local node = api.tree.get_node_under_cursor()
      if not node then
        return
      end

      local abs_path = node.absolute_path
      local bufremove_ok, bufremove = pcall(require, "mini.bufremove")

      -- find all windows displaying this buffer
      local wins_to_handle = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) == abs_path then
          for _, win in ipairs(vim.fn.win_findbuf(buf)) do
            table.insert(wins_to_handle, { win = win, buf = buf })
          end
        end
      end

      -- close buffers using mini.bufremove to preserve windows
      for _, item in ipairs(wins_to_handle) do
        if bufremove_ok then
          bufremove.delete(item.buf, true)
        else
          pcall(vim.api.nvim_buf_delete, item.buf, { force = true })
        end
      end

      -- delete file
      api.fs.remove()

      -- restore nvim-tree width
      vim.schedule(function()
        local tree_wins = vim.fn.win_findbuf(vim.fn.bufnr "NvimTree")
        if #tree_wins > 0 then
          vim.api.nvim_win_set_width(tree_wins[1], 30)
        end
      end)
    end, opts "Delete")
  end,
}
