return {
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "; before #%d+" },
              { find = "; after #%d+" },
            },
          },
          view = "mini",
        },
      },

      views = {
        mini = {
          position = {
            row = -2,
            col = "50%",
          },
          align = "center",
        },
      },
    },
  },
}
