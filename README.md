# nvim

A modular Neovim configuration built on [lazy.nvim](https://github.com/folke/lazy.nvim).

## Requirements

**Required**

- **Neovim ≥ 0.11** — the config uses `vim.lsp.config` / `vim.lsp.enable`, `vim.diagnostic.jump`, and `vim.hl.on_yank`, none of which exist earlier.
- `git`, `make`, a C compiler, and a Nerd Font v3+ in your terminal.
- **`tree-sitter` CLI** — nvim-treesitter is pinned to its `main` branch, which compiles parsers through the CLI rather than shipping prebuilt ones. Without it every parser install fails with `failed to compile parser`.

```sh
xcode-select --install     # git, make, clang
brew install tree-sitter
```

**Optional** — each is detected at startup and falls back cleanly if absent, so nothing errors:

| Tool | Without it |
|---|---|
| `ripgrep` | `:grep` keeps Neovim's built-in `grep`; fzf-lua's live grep is unavailable |
| `fd` | fzf-lua lists files with `rg --files`, then plain `find` |
| `bat` | fzf-lua uses its own treesitter previewer (arguably nicer — it matches the colorscheme) |

```sh
brew install ripgrep fd bat
```

Everything else — language servers, linters, formatters, `codelldb` — is installed automatically by `mason-tool-installer` on first launch. Watch progress with `:Mason`.

Toolchain-specific extras that Mason can't provide:

| Stack | Needs |
|---|---|
| Swift / iOS | Xcode (supplies `sourcekit-lsp`), plus `xcbeautify`, `xcode-build-server`, `pymobiledevice3` |
| Flutter / Dart | The Flutter SDK (supplies `dartls` and `dart format`) |
| Rust | `rustup` (supplies `rust-analyzer` and `rustfmt`) |
| Ruby | `ruby-lsp` via asdf — the config looks for `~/.asdf/shims/ruby-lsp` and skips the server cleanly if it's absent |

## Layout

```
init.lua                  entry point — requires config.lazy and nothing else
lua/config/
  lazy.lua                bootstrap + lazy.nvim setup
  globals.lua             leader keys (must run before any plugin spec)
  options.lua             vim.opt settings
  keymaps.lua             global, non-plugin mappings
  autocmds.lua            autocommands
lua/plugins/              one file per plugin, returned as a lazy.nvim spec
lua/servers/              one file per LSP server; filename == server name
  init.lua                registry — loads and enables every server module
lua/utils/
  lsp.lua                 buffer-local LSP mappings (LspAttach)
  diagnostics.lua         vim.diagnostic styling
```

**Adding a language server:** drop `lua/servers/<name>.lua` returning `function(capabilities)` that calls `vim.lsp.config("<name>", …)`, then add `"<name>"` to the list in `lua/servers/init.lua`. The filename, the name passed to `vim.lsp.config`, and the entry in the list must all match — the registry enables servers by name, so a mismatch means the config silently never applies.

## Who owns what

Several concerns could plausibly be handled by more than one plugin here. They aren't — each has exactly one owner, and the losers are configured off:

| Concern | Owner | Explicitly disabled elsewhere |
|---|---|---|
| Formatting | `conform.nvim` | efm (`documentFormatting = false`), `lua_ls`, `ruby_lsp` |
| Linting | `efm-langserver` | — |
| Winbar (path + current symbol) | `dropbar.nvim` | lspsaga `symbol_in_winbar`, lualine winbar |
| Rust LSP + DAP | `rustaceanvim` | no `rust_analyzer` in `lua/servers/`, no `dap.configurations.rust` |
| Dart LSP | `flutter-tools.nvim` | no `dartls` in `lua/servers/` |
| Icons | `mini.icons` | mocks `nvim-web-devicons` for plugins that ask for it |
| Trailing whitespace | `conform.nvim` (`_` formatter) | the old `BufWritePre` mini.trailspace autocmd |

## Leader map

`<leader>` is <kbd>Space</kbd>. Press it and wait for which-key, or `<leader>?` for buffer-local mappings.

| Prefix | Group |
|---|---|
| `<leader>b` | buffers |
| `<leader>c` | code actions, Copilot Chat, formatting |
| `<leader>d` | debug (DAP) |
| `<leader>f` | find (fzf-lua) |
| `<leader>g` | git (gitsigns, fugitive, diffview) |
| `<leader>m` | mobile — Xcode globally, Flutter on Dart buffers |
| `<leader>n` | notes (obsidian) |
| `<leader>r` | rename, resize, config |
| `<leader>s` | splits |
| `<leader>x` | diagnostics (Trouble) |

Standalone keys are kept out of those prefixes on purpose — a single mapping that shares a prefix with a group makes every key in that group wait out `timeoutlen` before firing:

`<leader>h` clear highlights · `<leader>q` Oil · `<leader>z` Zen Mode · `<leader>;` winbar picker · `<leader>D` delete without yanking · `<leader>k` / `<leader>K` diagnostics under cursor / for line

LSP navigation uses the standard `g` motions rather than `<leader>g…`, which belongs to git: `gd` peek definition, `gD` go to definition, `gy` peek type, `gO` outline, `K` hover. Neovim 0.11's own `grn` / `gra` / `grr` / `gri` defaults are left intact.

Copilot lives on <kbd>Alt</kbd> (`<M-l>` accept, `<M-]>` / `<M-[>` cycle, `<M-h>` dismiss) so it doesn't contend with nvim-cmp's `<C-y>` and `<C-e>`.

## The winbar

Every window shows its path and the symbol trail down to the cursor:

```
 lua  plugins  dropbar.lua   config   setup()
```

It's interactive — `<leader>;` enters pick mode, each segment gets a letter, and the dropdown lists that level's siblings (`i` inside a dropdown fuzzy-finds). LSP symbols are preferred, with treesitter as fallback, so the function name still appears in buffers where no server has attached.

## Escape hatches

| | |
|---|---|
| `<leader>ct` | toggle format-on-save globally |
| `:let b:disable_autoformat = v:true` | disable it for one buffer |
| `<leader>cd` | toggle diagnostic virtual text |
| `<leader>ci` | toggle inlay hints |
| `<leader>cH` | toggle inline colour swatches |
| `:Lazy` / `:Mason` | `<leader>rl` / `<leader>rm` |

## Health

`:checkhealth` after the first launch. Unused language providers (perl, ruby, node, python3) are switched off in `globals.lua`, so their absence is expected and not a warning worth chasing.
