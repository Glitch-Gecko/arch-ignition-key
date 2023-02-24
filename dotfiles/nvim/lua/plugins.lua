local packer = require("packer")

return require('packer').startup(function(use)
      
  use "wbthomason/packer.nvim"
      
  use { "catppuccin/nvim", as = "catppuccin" }
  use {
	  'glepnir/dashboard-nvim',
	  event = 'VimEnter',
      cond = firenvim_not_active,
	  config = [[require('config.dashboard-nvim')]],
	  requires = {'nvim-tree/nvim-web-devicons'}
  }
end)