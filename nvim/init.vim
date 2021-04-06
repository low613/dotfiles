call plug#begin('~/nvim/plugged')
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'vim-syntastic/syntastic'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'editorconfig/editorconfig-vim' 
Plug 'elzr/vim-json' 
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } 
Plug 'junegunn/fzf.vim'
Plug 'mrk21/yaml-vim' 
Plug 'rodjek/vim-puppet' 
Plug 'vim-ruby/vim-ruby' 
call plug#end()
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set laststatus=2
set statusline+=%{coc#status()}
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

set noshowmode
set number
set relativenumber
set mouse=a
set ai

nnoremap <silent> <Leader>v :NERDTreeFind<CR>
autocmd BufEnter * lcd %:p:h

set expandtab
set title
set background=dark
set clipboard+=unnamedplus
