lua require('plugins')

let g:coq_settings = { 'auto_start': 'shut-up' }
scriptencoding utf-8

colorscheme catppuccin-mocha

au FileType * setlocal formatoptions-=cro
set timeoutlen=500
set updatetime=500
if !empty(provider#clipboard#Executable())
  set clipboard+=unnamedplus
endif
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set matchpairs+=<:>,[:],{:},“:”,‘:’,(:)
set formatoptions-=cro
set number
set ignorecase smartcase
set linebreak
set showbreak=↪
set scrolloff=3
set mousemodel=popup
set mousescroll=ver:1,hor:6
set confirm
set history=500
set autowrite
set undofile
set termguicolors
set nu
set showmatch
set hlsearch
set incsearch
set autoindent
set wildmode=longest,list
syntax on
set mouse=a
set clipboard=unnamedplus
set ttyfast

augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end
