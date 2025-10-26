require "nvchad.mappings"

local map = vim.keymap.set

map("i", "jk", "<ESC>")
map("i", "<C-CR>", function()
        local enter = require("scripts.smart_enter")
        enter.EnterInsideQuotes()
      end,
  {desc = "Magic enter"}
)

 -- Normal
map("n", ";", ":", { desc = "CMD enter command mode" })

map("n", "gsd", ':vsplit<CR>:lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true, desc = "LSP definition in vsplit" })

map("n", "gr",
      function()
        local telescope = require('telescope.builtin')
        telescope.lsp_references()
      end
, { desc = "LSP references" })


-- map("n", "gd",
--       function()
--         local telescope = require('telescope.builtin')
--         telescope.lsp_definitions()
--       end
-- , { desc = "LSP definitions" })

map("n", "gi",
      function()
        local telescope = require('telescope.builtin')
        telescope.lsp_implementations()
      end
, { desc = "LSP references" })


map("n", "gh", function()
  vim.lsp.buf.hover()
end, { desc = "Show information about the symbol under the cursor" })


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
