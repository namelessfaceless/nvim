# Windows Copilot notes

- Copilot ghost text is enabled on the `copilot/windows-setup-copilot` branch.
  - `<M-l>` accepts the current suggestion.
  - `<M-h>` dismisses the current suggestion.
  - `markdown`, `gitcommit`, and `help` are disabled in `lua/custom/plugins.lua` to keep prose buffers quieter.
- Copilot stays out of the `nvim-cmp` popup menu on this branch; completion sources fall back to the NvChad defaults.
- CopilotChat keymaps live under `<leader>c`:
  - `<leader>co` open chat
  - `<leader>ct` toggle chat
  - `<leader>cp` quick prompt
  - `<leader>cx` explain buffer / selection
  - `<leader>cf` fix buffer / selection
  - `<leader>cr` refactor buffer / selection
  - `<leader>cg` generate tests for buffer / selection
- Custom LSP setup now supports both Neovim 0.10 (`require("lspconfig").<server>.setup`) and Neovim 0.11+ (`vim.lsp.config` / `vim.lsp.enable`) so `:LspInfo` and `marksman` can attach on either API path.
