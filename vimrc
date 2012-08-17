set number
set laststatus=2
set statusline=\ %f%m%r%h%w\ %=%([%l,%v][%p%%]%k\%Y%)
set cmdheight=2
set nocompatible

" Use 2 spaces for tabs, turn on automatic indenting
set tabstop=2
set smarttab
set shiftwidth=2
set autoindent
set expandtab
set backspace=start,indent

" Turn on highlighted search and syntax highlighting
set hlsearch
set incsearch
syntax on

" Set leader to comma
let mapleader = "," 

" Make backspace work the way it should
set backspace=2

" Make backspace and cursor keys wrap accordingly
set whichwrap+=<,>,h,l

" Make searches case-insensitive
set ignorecase

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$
