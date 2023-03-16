local packer = require("packer")

return require('packer').startup(function(use) 
      
    use "wbthomason/packer.nvim"
      
    use { "catppuccin/nvim", as = "catppuccin" }
    
    use {
       "goolord/alpha-nvim",
       config = function()
          require("config.alpha").setup()
       end,
    }

    use {
      'nvim-telescope/telescope.nvim', tag = '0.1.1',
    -- or                            , branch = '0.1.x',
      requires = { {'nvim-lua/plenary.nvim'} }
    }

    use {"ms-jpq/coq_nvim", branch = 'coq'}
    use {"ms-jpq/coq.artifacts", branch = 'artifacts'}
    use "lambdalisue/suda.vim"
end)
