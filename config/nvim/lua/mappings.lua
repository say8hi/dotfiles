local map = vim.keymap.set

-- Insert mode navigation
map("i", "<C-b>", "<ESC>^i", { desc = "move beginning of line" })
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-h>", "<Left>", { desc = "move left" })
map("i", "<C-l>", "<Right>", { desc = "move right" })
map("i", "<C-j>", "<Down>", { desc = "move down" })
map("i", "<C-k>", "<Up>", { desc = "move up" })

-- Quick escape
map("i", "jk", "<ESC>")
map("i", "<C-CR>", function()
  local enter = require("scripts.smart_enter")
  enter.enter_inside_quotes()
end, { desc = "Magic enter" })

-- Normal mode

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

-- General
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "clear highlights" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "copy whole file" })
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Toggle line numbers
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })

-- Format file
map({ "n", "x" }, "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "format file" })

-- Comment
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- NvimTree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus" })

-- Telescope
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "help page" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "find in buffer" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "git status" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "find files" })
map("n", "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", { desc = "find all files" })

-- Git (gitsigns - applied on BufEnter for git files)
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  callback = function(args)
    local bufnr = args.buf
    -- Only setup gitsigns mappings if gitsigns is loaded
    vim.schedule(function()
      -- Check if buffer is still valid before setting keymaps
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      if package.loaded.gitsigns then
        local gs = package.loaded.gitsigns
        local function git_map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        git_map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, "Next git hunk")

        git_map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, "Previous git hunk")

        -- Actions
        git_map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        git_map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        git_map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        git_map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        git_map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        git_map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        git_map("n", "<leader>hb", function()
          gs.blame_line { full = true }
        end, "Blame line")
        git_map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle inline blame")
        git_map("n", "<leader>hd", gs.diffthis, "Diff this")
      end
    end)
  end,
})

-- LSP mappings (applied on LspAttach)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local function lsp_map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP " .. desc })
    end

    -- Navigation
    lsp_map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    lsp_map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    lsp_map("n", "gsd", ":vsplit<CR>:lua vim.lsp.buf.definition()<CR>", "Definition in vsplit")
    lsp_map("n", "K", vim.lsp.buf.hover, "Hover documentation")
    lsp_map("n", "gi", function()
      require('telescope.builtin').lsp_implementations()
    end, "Go to implementation")
    lsp_map("n", "gK", vim.lsp.buf.signature_help, "Signature help")  -- Changed from <C-k> to avoid conflict with window navigation
    lsp_map("n", "gr", function()
      require('telescope.builtin').lsp_references()
    end, "Show references")
    lsp_map("n", "<leader>D", vim.lsp.buf.type_definition, "Go to type definition")

    -- Actions
    lsp_map("n", "<leader>ra", vim.lsp.buf.rename, "Rename symbol")
    lsp_map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    lsp_map("n", "<leader>f", function()
      vim.lsp.buf.format { async = true }
    end, "Format buffer")

    -- Workspace
    lsp_map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
    lsp_map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
    lsp_map("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "List workspace folders")

    -- Diagnostics
    lsp_map("n", "gl", vim.diagnostic.open_float, "Show line diagnostics")
    lsp_map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    lsp_map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  end,
})

-- Folding (nvim-ufo)
map("n", "zR", function()
  require("ufo").openAllFolds()
end, { desc = "Open all folds" })
map("n", "zM", function()
  require("ufo").closeAllFolds()
end, { desc = "Close all folds" })

-- Go specific
map("n", "<leader>gj", "<cmd>GoTagAdd json<CR>", { desc = "Add JSON tags" })
map("n", "ga", "<cmd>GoIfErr<CR>", { desc = "if err != nil {}" })

-- Debug
map("n", "<leader>dgt",
      function()
        require('dap-go').debug_test()
      end,
 { desc = "Debug go test" })


map("n", "<leader>dgl",
      function()
        require('dap-go').debug_last()
      end,
 { desc = "Debug last go test" })


map("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>", { desc = "Add breakpoint at line" })
map("n", "<leader>dus",
      function ()
        local widgets = require('dap.ui.widgets');
        local sidebar = widgets.sidebar(widgets.scopes);
        sidebar.open();
      end,
{ desc = "Open debugging sidebar" })


map("n", "dn", "<cmd> DapStepOver <CR>", { desc = "DAP Next step" })
map("n", "<leader>dc", function() require('dap').continue() end, { desc = "Debug" })

map("n", "n", "nzzzv", { desc = "centered move to the next find" })
map("n", "N", "Nzzzv", { desc = "centered move to the next find" })

map("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "centered move to the next find" })

map("n", "<leader>ds", '<cmd>Telescope diagnostics<CR>', { desc = "LSP diagnostic loclist" })

-- Visual
map("v", "<S-down>", ":m '>+1<CR>gv=gv", { desc = "move selected down" })
map("v", "<S-up>", ":m '<-2<CR>gv=gv", { desc = "move selected up" })

map("v", "p", "\"_dP", { desc = "paste without copying" })
map("v", "c", "\"_c", { desc = "c without copying" })

-- Vim Visual Multi
vim.g.VM_maps = {
  ['Find Under'] = '<C-b>',
  ['Find Subword Under'] = '<C-b>',
}

-- Bufferline navigation
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
map("n", "<leader>x", function()
  require("mini.bufremove").delete(0, false)
end, { desc = "Close buffer" })
map("n", "<leader>X", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other buffers" })

-- Move buffers
map("n", "<leader>bl", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer right" })
map("n", "<leader>bh", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer left" })

-- Pick buffer
map("n", "<leader>bp", "<cmd>BufferLinePick<cr>", { desc = "Pick buffer" })

-- Pin buffer
map("n", "<leader>bP", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle pin buffer" })

-- Tabs management
map("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
map("n", "gt", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "gT", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
map("n", "<leader>t1", "1gt", { desc = "Go to tab 1" })
map("n", "<leader>t2", "2gt", { desc = "Go to tab 2" })
map("n", "<leader>t3", "3gt", { desc = "Go to tab 3" })
map("n", "<leader>t4", "4gt", { desc = "Go to tab 4" })
map("n", "<leader>t5", "5gt", { desc = "Go to tab 5" })

-- Terminal
map("t", "<C-x>", "<C-\\><C-N>", { desc = "escape terminal mode" })

-- Fix Alt+Backspace in terminal mode - map to Ctrl+W (delete word)
map("t", "<M-BS>", "<C-w>", { desc = "delete word backward in terminal" })
map("t", "<A-BS>", "<C-w>", { desc = "delete word backward in terminal" })

-- Terminal splits
map({ "n", "t" }, "<A-h>", function()
  require("utils.terminal").horizontal()
end, { desc = "terminal horizontal split" })

map({ "n", "t" }, "<A-v>", function()
  require("utils.terminal").vertical()
end, { desc = "terminal vertical split" })

map({ "n", "t" }, "<A-i>", function()
  require("utils.terminal").float()
end, { desc = "terminal floating" })

-- WhichKey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })
map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })

-- Theme Switcher
map("n", "<leader>th", function()
  require("scripts.theme_switcher").select_theme()
end, { desc = "switch theme" })
