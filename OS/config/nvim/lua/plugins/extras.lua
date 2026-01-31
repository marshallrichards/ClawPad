return {
  -- Better escape (jk/jj to escape)
  {
    "max397574/better-escape.nvim",
    opts = {
      mapping = { "jk", "jj" },
      timeout = 200,
    },
  },
  -- Surround
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },
  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    opts = {},
  },
  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },
}
