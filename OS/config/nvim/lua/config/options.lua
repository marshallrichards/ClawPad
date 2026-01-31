-- Custom options (extends LazyVim defaults)
local opt = vim.opt

opt.relativenumber = true
opt.number = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.expand("~/.local/state/nvim/undo")
opt.hlsearch = false
opt.incsearch = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 50
opt.colorcolumn = "100"
opt.clipboard = "unnamedplus"
opt.conceallevel = 0
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
