"Plugin
call plug#begin('~/.config/nvim/bundle')
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-tmux-navigator'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-commentary'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-repeat'
Plug 'honza/vim-snippets'

Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': ':UpdateRemotePlugins'}

" Markdown Blog
Plug 'junegunn/goyo.vim'
Plug 'cespare/vim-toml'
" For Rails
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'neoclide/coc-solargraph', {'do': 'yarn install --frozen-lockfile'}
Plug 'tpope/vim-endwise'
Plug 'thoughtbot/vim-rspec'
"UI
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General configs                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=UTF-8
set history=500
set mouse=a
set noswapfile
set backspace=indent,eol,start
set whichwrap+=<,>,h,l
set autoread                  " Set to auto read when a file is changed
set clipboard=unnamed         " Use the OS clipboard by default
set hid                       " A buffer becomes hidden when it is abandoned
filetype indent on            " Enable filetype plugins
filetype plugin on
syntax enable
set autoindent                " Auto-indent new lines
set expandtab                 " Use spaces instead of tabs
set shiftwidth=2              " Number of auto-indent spaces
set smartindent               " Enable smart-indent
set smarttab                  " Enable smart-tabs
set softtabstop=2             " Number of spaces per Tab
set foldmethod=indent         " Fold based on indent
set foldnestmax=5             " Deepest fold is 5 levels
set nofoldenable              " No fold when start
set splitbelow                " Split below
set splitright                " Split right
set number relativenumber     " turn hybrid line numbers on
set cursorline                " Highlight cursorline
set hlsearch                  " Highlight all search results
set smartcase                 " Enable smart-case search
set ignorecase                " Always case-insensitive
set incsearch                 " Searches for strings incrementally
set so=7                      " Set 7 lines to the cursor
set laststatus=2
set ruler
set wildmenu

if has("termguicolors") && has("nvim")
  set termguicolors
endif

if exists("g:loaded_webdevicons")
  call webdevicons#refresh()
endif

" Scheme
set background=dark
colorscheme oceanic_material
let g:oceanic_material_background='ocean'
let g:oceanic_material_allow_bold=1
let g:oceanic_material_allow_italic=1

" Set background terminal and line number transparent
highlight clear SignColumn
hi Normal ctermbg=NONE guibg=NONE
hi VertSplit guifg=NONE guibg=NONE gui=none 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings                                                                    "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map s <Nop>
let mapleader=" "
imap jk <Esc>
map 0 ^


" Useful saving mapping
noremap <leader>w :w!<cr>
noremap <C-S> :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <Esc>:update<CR>
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>"

"Rename current file
map <Leader>rnf :call RenameFile()<cr>

vmap <C-C> "+y
vmap <leader>y "+y
nmap <leader>y "+y
nmap <leader>p "+p

" Move a line of text using ALT+[jk]
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

nmap ]<space> o<esc>
nmap [<space> O<esc>

" Turn off search highlight
map <silent> <leader><cr> :noh<cr>

" Split windows
map <leader>sv <C-W>v
map <leader>ss <C-W>s

"Chadtree
nnoremap <leader>v <cmd>CHADopen<cr>

" Run Rspec
nnoremap <Leader>rs :call RunCurrentSpecFile()<CR>
nnoremap <Leader>ra :call RunAllSpecs()<CR>
noremap <Leader>cs :call RunNearestSpec()<CR>

" Fzf
nnoremap <silent> <c-p> :Files<cr>
nnoremap <silent> <leader>b :Buffers<cr>
nnoremap <silent> <leader>fr :Rg<cr>

" Fugitive
nnoremap <silent> <leader>gb :Git blame<cr>

" Coc.nvim
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Font devicon
 set guifont=DroidSansMono\ Nerd\ Font\ 9

" ALE
map <leader>= :ALEFix<cr>
nmap <silent> [e <Plug>(ale_previous_wrap)
nmap <silent> ]e <Plug>(ale_next_wrap)

" Better warning error ALE
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '•'
highlight ALEErrorSign ctermbg=NONE ctermfg=red
highlight ALEWarningSign ctermbg=NONE ctermfg=yellow

" Edit quickly config nvim
nmap <Leader><Leader>c :e ~/.config/nvim/init.vim<CR>
noremap <Leader><Leader>r :so ~/.config/nvim/init.vim<CR>

" Indentline
let g:indentLine_char = '¦'

"Goyo markdown writing
map <leader>Go :Goyo<CR>

map <silent> s<cr> :call OpenFloatTerm()<cr>

" toggle relative numbers
function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
    set number
  else
    set relativenumber
  endif
endfunc
nnoremap <leader>nt :call NumberToggle()<CR>

" Airline config
let g:airline_theme='solarized'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tabs = 0
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9

" Buffer
map <leader>xx :Bclose<cr>
map <leader>xa :call CloseAllBuffersExceptCurrent()<cr>
map <silent> <leader>l :bnext<cr>
map <silent> <leader>h :bprevious<cr>

" Easymotion
let g:EasyMotion_smartcase = 1
map s <Plug>(easymotion-prefix)

" Ale plugin
let b:ale_linters = {
  \ 'python': ['flake8', 'pylint'],
  \ 'ruby': ['rubocop'],
  \}

let g:ale_fixers = {
  \ '*': ['remove_trailing_lines', 'trim_whitespace'],
  \ 'python': ['black', 'flake8'],
  \ 'ruby': ['rubocop'],
  \ 'javascript': ['eslint'],
  \ 'css': ['prettier'],
  \ 'json': ['prettier'],
  \ 'yaml': ['prettier'],
  \}

" Coc.nvim setting
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<S-Tab>"
let g:coc_snippet_next = '<tab>'
imap <C-l> <Plug>(coc-snippets-expand)

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Fzf config layout search
let g:fzf_layout = { 'down': '~30%' }

autocmd! FileType fzf tnoremap <buffer> <esc> <c-c>
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'Normal', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

"Function
" Don't close window when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
  let l:currentBufNum = bufnr("%")
  let l:alternateBufNum = bufnr("#")

  if buflisted(l:alternateBufNum)
    buffer #
  else
    bnext
  endif

  if bufnr("%") == l:currentBufNum
    new
  endif

  if buflisted(l:currentBufNum)
    execute("bdelete! ".l:currentBufNum)
  endif
endfunction

function! CloseAllBuffersExceptCurrent()
  let currentBuffer = bufnr("%")
  let lastBuffer = bufnr("$")
  if g:NERDTree.IsOpen()
    let nerdtreeBuffer = bufnr(t:NERDTreeBufName)
    if currentBuffer < nerdtreeBuffer
      let midBufferBefore = currentBuffer | let midBufferAfter = nerdtreeBuffer
    else
      let midBufferBefore = nerdtreeBuffer | let midBufferAfter = currentBuffer
    end
  else
    let midBufferBefore = currentBuffer
    let midBufferAfter = currentBuffer
  end

  if midBufferBefore > 1 | silent! execute "1,".(midBufferBefore-1)."bd" | endif
  if (midBufferAfter - midBufferBefore) > 2 | silent! execute (midBufferBefore+1).",".(midBufferAfter-1)."bd" | endif
  if midBufferAfter < lastBuffer | silent! execute (midBufferAfter+1).",".lastBuffer."bd" | endif
endfunction

" Rename current file
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction

function! OpenFloatTerm()
  let height = float2nr((&lines - 2) / 1.7)
  let row = float2nr((&lines - height) / 2)
  let width = float2nr(&columns / 1.7)
  let col = float2nr((&columns - width) / 2)
  " Border Window
  let border_opts = {
    \ 'relative': 'editor',
    \ 'row': row - 1,
    \ 'col': col - 2,
    \ 'width': width + 4,
    \ 'height': height + 2,
    \ 'style': 'minimal'
    \ }
  let border_buf = nvim_create_buf(v:false, v:true)
  let s:border_win = nvim_open_win(border_buf, v:true, border_opts)
  " Main Window
  let opts = {
    \ 'relative': 'editor',
    \ 'row': row,
    \ 'col': col,
    \ 'width': width,
    \ 'height': height,
    \ 'style': 'minimal'
    \ }
  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, opts)
  terminal
  startinsert
  " Hook up TermClose event to close both terminal and border windows
  autocmd TermClose * ++once :bd! | call nvim_win_close(s:border_win, v:true)
endfunction

""" PROJECTIONS
let g:rails_projections = {
\ "config/projections.json": {
\   "command": "projections"
\ },
\ "app/serializers/*_serializer.rb": {
\   "command": "serializer",
\   "affinity": "model",
\   "test": "spec/serializers/%s_spec.rb",
\   "related": "app/models/%s.rb",
\   "template": "class %SSerializer < ActiveModel::Serializer\nend"
\ },
\ "app/services/*.rb": {
\   "command": "service",
\   "affinity": "model",
\   "alternate": ["spec/services/%s_spec.rb", "unit/services/%s_spec.rb"],
\   "template": "class %S\n\n  def perform\n  end\nend"
\ },
\ "app/presenters/*_presenter.rb": {
\   "command": "presenter",
\   "affinity": "model",
\   "alternate": ["spec/presenters/%s_presenter_spec.rb", "unit/presenters/%s_presenter_spec.rb"],
\   "related": "app/models/%s.rb",
\   "template": "class %SPresenter < SimpleDelegator\n  def self.wrap(collection)\n    collection.map{open} |object| new object {close}\n  end\n\nend"
\ },
\ "spec/presenters/*_presenter.rb": {
\   "command": "specpresenter",
\   "affinity": "presenter",
\   "alternate": ["app/presenters/%s_presenter.rb"],
\   "related": "app/models/%s.rb",
\   "template": "require 'rails_helper'\n\nRSpec.describe %SPresenter, type: :presenter do\n\nend"
\ },
\ "features/cukes/*.feature": {
\   "alternate": ["features/step_definitions/%s_steps.rb", "features/steps/%s_steps.rb"],
\ },
\ "spec/factories/*s.rb": {
\   "command": "factory",
\   "affinity": "model",
\   "related": "app/models/%s.rb",
\   "template": "FactoryGirl.define do\n  factory :%s do\n  end\nend"
\ },
\ "spec/controllers/*_controller_spec.rb": {
\   "command": "speccontroller",
\   "affinity": "controller",
\   "related": "app/controllers/%s.rb",
\   "template": "require 'rails_helper'\n\nRSpec.describe %SController, type: :controller do\n\nend"
\ },
\ "spec/serializers/*_serializer_spec.rb": {
\   "command": "specserializer",
\   "affinity": "serializer",
\   "related": "app/serializers/%s.rb",
\   "template": "require 'rails_helper'\n\nRSpec.describe %SSerializer, type: :serializer do\n\nend"
\ },
\ "spec/models/*_spec.rb": {
\   "command": "spec",
\   "affinity": "model",
\   "related": "app/models/%s.rb",
\   "template": "require 'rails_helper'\n\nRSpec.describe %S, type: :model do\n\nend"
\ },
\ "spec/services/*_spec.rb": {
\   "command": "specservice",
\   "affinity": "service",
\   "related": "app/services/%s.rb",
\   "template": "require 'rails_helper'\n\nRSpec.describe %S do\n\nend"
\ },
\ "spec/workers/*_spec.rb": {
\   "command": "specworker",
\   "affinity": "worker",
\   "related": "app/workers/%s.rb",
\   "template": "require 'rails_helper'\n\nRSpec.describe %S, type: :worker do\n\nend"
\ },
\ "spec/features/*_spec.rb": {
\   "command": "specfeature",
\   "template": "require 'rails_helper'\n\nRSpec.feature '%S', type: :feature do\n\nend"
\ },
\ "spec/helpers/*_helper_spec.rb": {
\   "command": "spechelper",
\   "related": "app/helpers/%_helper.rb",
\   "affinity": "helper",
\   "template": "require 'rails_helper'\n\nRSpec.describe ApplicationHelper, type: :helper do\n\nend"
\ },
\ "lib/tasks/*.rake": {
\   "command": "rake",
\   "template": ["namespace :%s do\n  desc '%s'\n  task %s: :environment do\n\n  end\nend"],
\ },
\ "config/*.rb": { "command": "config"  },
\ "spec/support/*.rb": { "command": "support" },
\ }
