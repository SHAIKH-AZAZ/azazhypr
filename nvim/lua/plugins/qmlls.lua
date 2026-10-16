-- Mason's qmlls is a CI nightly with /home/runner import paths baked in → can't find Quickshell module.
-- Use system Qt6 qmlls (has /usr/lib/qt6/qml/Quickshell).
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      qmlls = {
        mason = false,
        cmd = { "/usr/lib/qt6/bin/qmlls", "-I", "/usr/lib/qt6/qml", "--no-cmake-calls" },
      },
    },
  },
}
