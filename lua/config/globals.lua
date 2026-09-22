-- ================================================================================================
-- TITLE : globals
-- ABOUT :
--   Leader keys. These MUST be set before lazy.nvim loads any plugin, because a plugin's
--   `keys = {}` specs are resolved against whatever <leader> is at load time. This is the
--   only place they are assigned -- setting them again in keymaps.lua (as this config used
--   to) is redundant at best and a silent source of half-registered mappings at worst.
-- ================================================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable providers that aren't used, so `:checkhealth` stays quiet and startup skips
-- probing for interpreters that aren't installed.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
