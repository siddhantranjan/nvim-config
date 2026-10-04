# Rust in this Neovim config

A practical guide: one-time setup, everyday workflow, and every Rust-related key.
`<leader>` is <kbd>Space</kbd>, so `<leader>ex` means press Space, then `e`, then `x`.

---

## 1. One-time setup

### Install the Rust toolchain (in a normal terminal)

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# restart the terminal (or: source "$HOME/.cargo/env"), then:
rustup component add rust-analyzer rustfmt clippy
```

Check it worked:

```sh
cargo --version
rust-analyzer --version
```

Why not Mason? rust-analyzer, rustfmt and clippy must match your compiler version. rustup
keeps them in sync; Mason would not.

### Sync Neovim plugins

Open Neovim and run:

```vim
:Lazy sync
:Lazy clean
```

Mason then installs `codelldb` (debugger) and `taplo` (TOML) on its own; watch with `:Mason`.

### One-off cleanup after removing C++ (optional, frees disk space)

```vim
:MasonUninstall clangd clang-format cpplint
:TSUninstall c cpp
```

### Confirm everything is healthy

```vim
:checkhealth rustaceanvim
```

---

## 2. Create and open a project

```sh
cargo new hello          # binary project (src/main.rs)
cargo new mylib --lib    # library project (src/lib.rs)
cd hello
nvim src/main.rs
```

Open Neovim from the project folder (where `Cargo.toml` is). Next time, just run `nvim` in
that folder and your last session (open files and splits) comes back automatically.

The first time a project opens, rust-analyzer indexes it. Give it a few seconds; progress
shows in the bottom-right corner.

---

## 3. Everyday workflow

| Do this | Keys |
|---|---|
| **Run** the program (`cargo run`, output in a split below) | `<leader>ex` |
| **Build** only (`cargo build`, errors open in a list) | `<leader>eb` |
| **Debug** — pick a binary or test, then step through | `<leader>ed` |
| Set / remove a **breakpoint** on the current line | `<leader>db` |
| Run a **test** (pick from a list) | `<leader>cT` |
| Run anything runnable (main, tests, examples) | `<leader>cR` |
| **Format** | automatic on save (rustfmt) |
| **Lint** | automatic on save (clippy) — warnings appear inline |

### Build errors

When `<leader>eb` fails, the quickfix list opens with every error. Move onto an error and
press <kbd>Enter</kbd> to jump to it. `]q` / `[q` move to the next / previous error from
anywhere. A clean build closes the list again.

### Run output

`<leader>ex` opens the output in a split at the bottom. It stays open after the program
finishes so you can read it. Press `<C-k>` to jump back to your code, or `:close` in the split
to close it. Programs that read input (`stdin`) work: click into the split, or move to it
and press `i`, then type.

### Debugging

1. Put the cursor on a line and press `<leader>db` to set a breakpoint.
2. Press `<leader>ed` and choose what to debug.
3. The debug UI opens (variables, call stack, breakpoints). Then:

| Action | Keys |
|---|---|
| continue | `<leader>dc` |
| step over | `<leader>dn` |
| step into | `<leader>di` |
| step out | `<leader>du` |
| evaluate expression under cursor | `<leader>de` |
| run to cursor | `<leader>dC` |
| stop | `<leader>dt` |
| toggle the debug UI | `<leader>dd` |

### Single practice files (no Cargo project)

A lone `something.rs` file works too: `<leader>ex` compiles it with `rustc` into a binary
next to it (`something.rs` → `something`) and runs it; `<leader>ed` debugs it. Code
intelligence is limited without a `Cargo.toml`, so for anything bigger than a scratch file,
use `cargo new`.

---

## 4. Reading and fixing errors

| Do this | Keys |
|---|---|
| show the error under the cursor | `<leader>k` |
| full compiler message (with the ASCII arrows rustc prints) | `<leader>cr` |
| explain the error code (e.g. E0382) | `<leader>cE` |
| quick fix / code action (import, add `mut`, …) | `<leader>ca` |
| next / previous error | `]e` / `[e` |
| next / previous diagnostic of any kind | `]d` / `[d` |
| all problems in the project | `<leader>xx` |

---

## 5. Navigating code

| Do this | Keys |
|---|---|
| hover docs / types | `K` |
| hover with actions (run, debug, go to impl) | `<leader>ck` |
| peek definition / go to definition | `gd` / `gD` |
| find references | `<leader>fr` |
| rename symbol | `<leader>rn` |
| expand a macro (`println!`, `vec!`, derive, …) | `<leader>cx` |
| go to parent module | `<leader>cp` |
| open this crate's `Cargo.toml` | `<leader>cC` |
| open docs.rs for the item under the cursor | `<leader>cD` |
| toggle inline type hints | `<leader>ci` |

---

## 6. Managing dependencies (`Cargo.toml`)

Open `Cargo.toml` (`<leader>cC` from any Rust file). Every dependency shows its latest
version next to it, and outdated or invalid versions are flagged.

| Do this | Keys |
|---|---|
| versions, features, docs for the crate under cursor | `K` |
| actions (upgrade, enable a feature, open docs) | `<leader>ca` |
| upgrade the crate under the cursor | `<leader>cu` |
| upgrade all crates | `<leader>cU` |
| list / toggle features | `<leader>cf` |
| pick a version | `<leader>cv` |
| open on crates.io | `<leader>co` |

Typing under `[dependencies]` completes crate names, then versions, then features.
Typos in other sections (e.g. `[profile.release]`) are flagged by the TOML checker.

You can also add crates from the terminal as usual: `cargo add serde --features derive`.

---

## 7. Terminal, search and other handy keys

| Do this | Keys |
|---|---|
| toggle a terminal (from any mode) | <kbd>Ctrl</kbd>+<kbd>/</kbd> |
| floating terminal / vertical split | `<leader>tt` / `<leader>tv` |
| leave terminal typing mode | <kbd>Esc</kbd> <kbd>Esc</kbd> |
| find file / search text | `<leader>ff` / `<leader>fg` |
| search & replace across the project | `<leader>rg` |
| any cargo / make / npm task | `<leader>er` |
| re-run the last task | `<leader>el` |
| restore this folder's session manually | `<leader>ws` |

Forgot a key? Press <kbd>Space</kbd> and wait — a menu shows every option.

---

## 8. Troubleshooting

**No completion / go-to-definition in `.rs` files.**
Open Neovim from the folder that contains `Cargo.toml`, then run `:checkhealth rustaceanvim`.
Most often `rust-analyzer` isn't installed — run `rustup component add rust-analyzer`.

**"rustfmt not found" on save / clippy warnings never appear.**
`rustup component add rustfmt clippy`.

**`<leader>ed` says no adapter / codelldb not found.**
Open `:Mason` and check `codelldb` is installed (it installs automatically on first launch).

**Format-on-save is getting in the way.**
`<leader>ct` toggles it off and on.

**On Neovim 0.12 or newer?**
You can move to the latest rustaceanvim: in `lua/plugins/rustaceanvim.lua` change
`version = "^8"` to `version = "^9"`, then `:Lazy sync`. (v9 requires Neovim 0.12.)

---

## Where things live in the config

| File | What it does |
|---|---|
| `lua/plugins/rustaceanvim.lua` | rust-analyzer settings (clippy, inlay hints) and Rust-only keys |
| `lua/plugins/crates.lua` | Cargo.toml dependency helper and its keys |
| `lua/servers/taplo.lua` | TOML language server (Cargo.toml validation) |
| `lua/utils/runner.lua` | what `<leader>eb` / `ex` / `ed` do |
| `lua/plugins/conform.lua` | rustfmt on save |
| `lua/plugins/nvim-dap-ui.lua` | debugger UI and `<leader>d…` keys |
