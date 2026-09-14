-- [[ Harpoon ]]
-- Pin the handful of files you're actively working on and jump to them with a
-- single keystroke — instead of scrolling through 30+ buffers in a large project.
--  See https://github.com/ThePrimeagen/harpoon/tree/harpoon2
--
-- Harpoon 2 lives on the `harpoon2` branch and depends on plenary.nvim, which is
-- already installed by the Telescope section in init.lua. This file is loaded last
-- (via `require 'custom.plugins'`), so plenary is guaranteed to be available here.
vim.pack.add { { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' } }

local harpoon = require 'harpoon'
harpoon:setup {}

-- Add the current file to the harpoon list, and open the quick menu.
--  In the menu you can edit/delete/reorder lines like a normal buffer, then `:w`.
vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end, { desc = 'H[a]rpoon: add file' })
vim.keymap.set('n', '<leader>e', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon: quick m[e]nu' })

-- Jump straight to marked file 1-4. The whole point: no fuzzy finding, no
-- looking — just muscle memory to your key files.
vim.keymap.set('n', '<leader>1', function() harpoon:list():select(1) end, { desc = 'Harpoon: file 1' })
vim.keymap.set('n', '<leader>2', function() harpoon:list():select(2) end, { desc = 'Harpoon: file 2' })
vim.keymap.set('n', '<leader>3', function() harpoon:list():select(3) end, { desc = 'Harpoon: file 3' })
vim.keymap.set('n', '<leader>4', function() harpoon:list():select(4) end, { desc = 'Harpoon: file 4' })
