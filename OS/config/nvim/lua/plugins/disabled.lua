-- Disabled plugins for performance on older hardware
-- These can be re-enabled by removing/commenting out entries below

return {
  -- Disable Copilot (network overhead, not needed with Claude Code)
  { "zbirenbaum/copilot.lua", enabled = false },
  { "CopilotC-Nvim/CopilotChat.nvim", enabled = false },

  -- Disable noice.nvim (fancy UI, pure overhead)
  { "folke/noice.nvim", enabled = false },

  -- Disable treesitter (use vim's built-in syntax highlighting instead)
  { "nvim-treesitter/nvim-treesitter", enabled = false },
  { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
  { "nvim-ts-autotag", enabled = false },
  { "folke/ts-comments.nvim", enabled = false },
}
