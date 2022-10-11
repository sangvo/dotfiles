call plug#begin('~/.config/nvim/bundle')
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-tmux-navigator'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-surround'
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-commentary'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-repeat'
" Plug 'kana/vim-textobj-user'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'vim-test/vim-test'
Plug 'justinmk/vim-sneak'
Plug 'dyng/ctrlsf.vim'
Plug 'dhruvasagar/vim-table-mode'

" Markdown Blog
Plug 'plasticboy/vim-markdown'

" Spell grammar
Plug 'kamykn/spelunker.vim'

"JS
Plug 'pangloss/vim-javascript'

" hightlight
Plug 'slim-template/vim-slim'

" For Rails
Plug 'vim-ruby/vim-ruby'
" Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-endwise'

" Go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Lua ecosystem
Plug 'glepnir/galaxyline.nvim', {'branch': 'main'}
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'akinsho/bufferline.nvim',  { 'tag': 'v2.*' }
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'hrsh7th/vim-vsnip'
Plug 'onsails/lspkind-nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'airblade/vim-gitgutter'
Plug 'rafamadriz/friendly-snippets', {'branch': 'main'}

Plug 'glepnir/zephyr-nvim', {'branch': 'main'}
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'editorconfig/editorconfig-vim'

" Debug
Plug 'dstein64/vim-startuptime'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General configs                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set encoding=UTF-8
" set history=500
" set mouse=a " enable mouse for all mode
" set noswapfile
" set backspace=indent,eol,start
" set whichwrap+=<,>,h,l
" set autoread                  " Set to auto read when a file is changed
" set clipboard=unnamed         " Use the OS clipboard by default
" set hid                       " A buffer becomes hidden when it is abandoned
filetype indent on            " Enable filetype plugins
filetype plugin on
" syntax enable
" set textwidth=120             " Text width maximum chars before wrapping
" set autoindent                " Auto-indent new lines
" set tabstop=4                 " The number of spaces a tab is
" set expandtab                 " Use spaces instead of tabs
" set shiftwidth=2              " Number of auto-indent spaces
" set smartindent               " Enable smart-indent
" set smarttab                  " Enable smart-tabs
" set softtabstop=2             " Number of spaces per Tab
" set foldmethod=indent         " Fold based on indent
" set foldnestmax=5             " Deepest fold is 5 levels
" set nofoldenable              " No fold when start
" set splitbelow                " Split below
" set splitright                " Split right
" set number relativenumber     " turn hybrid line numbers on
" set cursorline                " Highlight cursorline
" set hlsearch                  " Highlight all search results
" set smartcase                 " Enable smart-case search
" set ignorecase                " Always case-insensitive
" set incsearch                 " Searches for strings incrementally
" set so=7                      " Set 7 lines to the cursor
" set laststatus=2
" set ruler
" set wildmenu
" set nospell                   " turn off vim spell same work

" Editor UI
set termguicolors
" set fillchars+=vert:\|        " add a bar for vertical splits
" set fcs=eob:\                 " hide ~ tila
" set list
" set listchars=tab:»·,nbsp:+,trail:·,eol:¬,space:.,extends:→,precedes:←

" User neomvim config local
" Refs > https://medium.com/@dnrvs/per-project-settings-in-nvim-fc8c8877d970
set exrc
set secure

" " Auto remove trailing spaces
" autocmd BufWritePre * %s/\s\+$//e

" Scheme
set background=dark
colorscheme zephyr
let g:oceanic_material_background='ocean'
let g:oceanic_material_allow_bold=1
let g:oceanic_material_allow_italic=1

" Set background terminal and line number transparent
hi clear SignColumn
hi Normal ctermbg=NONE guibg=NONE
hi VertSplit guifg=#343D46 guibg=#343D46 gui=NONE cterm=NONE

" " Override color spell hightlight
hi SpelunkerSpellBad cterm=underline ctermfg=247 gui=underline guifg=NONE
hi SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=underline guifg=NONE

" au BufNewFile,BufRead *.json.jbuilder set ft=ruby
" au BufNewFile,BufRead *.json.jb set ft=ruby

" Lua setup config
" lua require("galaxy-line")
" lua require("buffer-line")
lua require("lsp-config")
" lua require("module-colorizer")
lua require("nvim-compe")
" lua require("module-nvim-tree")
" lua require("file-icon")
" lua require("nvim-kind")

" Load vim module
" source ~/workspace/dotfiles/config/nvim/modules/nvim-tree.vim

let g:vsnip_snippet_dir = expand('~/workspace/dotfiles/config/nvim/snips')

" Mappings
" let mapleader=" "
" imap jk <Esc>
" map 0 ^

" Dont use recording
" map q <Nop>

" nnoremap <Left> :echoe "Use h"<CR>
" nnoremap <Right> :echoe "Use l"<CR>
" nnoremap <Up> :echoe "Use k"<CR>
" nnoremap <Down> :echoe "Use j"<CR>

" Shift+H goto head of the line, Shift+L goto end of the line
" nnoremap H ^
" nnoremap L $

" Useful saving mapping
" noremap <leader>w :w!<cr>
" noremap <C-S> :update<CR>
" vnoremap <C-S> <C-C>:update<CR>
" inoremap <C-S> <Esc>:update<CR>
" command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Switch CWD to the directory of the open buffer
" map <leader>cd :cd %:p:h<cr>:pwd<cr>"

" Copy to clipboard
" vmap <C-C> "+y
" vmap <leader>y "+y
" nmap <leader>y "+y
" nmap <leader>p "+p

" Yank to end
" nnoremap Y y$

" React
" let g:vim_jsx_pretty_colorful_config = 1
let g:vim_jsx_pretty_highlight_close_tag = 1

" autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

" HTML
let g:html5_event_handler_attributes_complete = 1
let g:html5_rdfa_attributes_complete = 1
let g:html5_microdata_attributes_complete = 1
let g:html5_aria_attributes_complete = 1

" Move a line of text using ALT+[jk]
" nmap <M-j> mz:m+<cr>`z
" nmap <M-k> mz:m-2<cr>`z
" vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
" vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

" TODO: ???
" nmap ]<space> o<esc>
" nmap [<space> O<esc>

" Turn off search highlight
" map <silent> <leader><cr> :noh<cr>

" Split windows
" map <leader>sv <C-W>v
" map <leader>ss <C-W>s

" Resize panel
" nmap <C-w>[ :vertical resize -6<CR>
" nmap <C-w>] :vertical resize +6<CR>

" Nvim lua mappings
" nnoremap <Leader>1 :lua require"bufferline".go_to_buffer(1)<CR>
" nnoremap <Leader>2 :lua require"bufferline".go_to_buffer(2)<CR>
" nnoremap <Leader>3 :lua require"bufferline".go_to_buffer(3)<CR>
" nnoremap <Leader>4 :lua require"bufferline".go_to_buffer(4)<CR>
" nnoremap <Leader>5 :lua require"bufferline".go_to_buffer(5)<CR>
" nnoremap <Leader>6 :lua require"bufferline".go_to_buffer(6)<CR>
" nnoremap <Leader>7 :lua require"bufferline".go_to_buffer(7)<CR>
" nnoremap <Leader>8 :lua require"bufferline".go_to_buffer(8)<CR>
" nnoremap <Leader>9 :lua require"bufferline".go_to_buffer(9)<CR>

" Vim test
let test#strategy = "neovim"

nmap <silent> <Leader>cs :TestNearest<CR>
nmap <silent> <Leader>rs :TestFile<CR>
nmap <silent> <Leader>ra :TestSuite<CR>
nmap <silent> <Leader>rl :TestLast<CR>

" rspec
let test#ruby#rspec#options = {
  \ 'nearest': '--backtrace',
  \ 'file':    '--format documentation',
  \ 'suite':   '--tag slow',
\}

" Enable matchit for ruby textobject
runtime macros/matchit.vim

" Fzf
" nnoremap <silent> <c-p> :Files<cr>
" nnoremap <silent> <leader>b :Buffers<cr>
" nnoremap <silent> <leader>fr :Rg<cr>
" nnoremap <Leader>t :BTags<CR>

" Fugitive
"nnoremap <silent> <leader>gl :Glog<cr>
"nnoremap <silent> <Leader>gad :Git add %:p<CR>
""nnoremap <silent> <Leader>gc :Git commit<CR>
"nnoremap <silent> <Leader>gb :Git blame<CR>
"nnoremap <silent> <Leader>gf :Gfetch<CR>
"nnoremap <silent> <Leader>gs :Git<CR>
"nnoremap <silent> <Leader>gp :Gpush<CR>
" Fugitive Conflict Resolution
" nnoremap <silent> <Leader>gdf :Gvdiff!<CR>
" nnoremap gdh :diffget //2<CR>
" nnoremap gdl :diffget //3<CR>

" Vim sneak
" let g:sneak#label = 1
" map s <Plug>Sneak_s
" map S <Plug>Sneak_S
" map f <Plug>Sneak_f
" map F <Plug>Sneak_F
" map t <Plug>Sneak_t
" map T <Plug>Sneak_T

" Search word
let g:ctrlsf_backend = 'rg'
let g:ctrlsf_extra_backend_args = {
    \ 'rg': '--vimgrep --type-not sql --smart-case'
    \ }
let g:ctrlsf_auto_focus = {
  \ "at": "start"
  \ }
let g:ctrlsf_default_view_mode = 'compact'

nmap     <C-F>f <Plug>CtrlSFPrompt
vmap     <C-F>f <Plug>CtrlSFVwordPath
vmap     <C-F>F <Plug>CtrlSFVwordExec
nmap     <C-F>n <Plug>CtrlSFCwordPath
nmap     <C-F>p <Plug>CtrlSFPwordPath
nnoremap <C-F>o :CtrlSFOpen<CR>
nnoremap <C-F>t :CtrlSFToggle<CR>
inoremap <C-F>t <Esc>:CtrlSFToggle<CR>

" vim-gutentags {{ "
let g:gutentags_ctags_exclude = ['*.js', '*.ts', '*.css', '*.less', '*.sass', 'node_modules', 'dist', 'vendor']
" }}

" Vim table mode
let g:table_mode_corner_corner='|'
let g:table_mode_header_fillchar='-'

nmap <Leader>tm :TableModeToggle<CR>

inoreabbrev <expr> __
          \ <SID>isAtStartOfLine('__') ?
          \ '<c-o>:silent! TableModeDisable<cr>' : '__'

" Go (Google)
" let g:go_highlight_structs = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_functions = 1
" let g:go_highlight_operators = 1
" let g:go_highlight_build_constraints = 1
" let g:go_highlight_variable_assignments = 1
" let g:go_highlight_fields = 1
" let g:go_highlight_types = 1
" let g:go_highlight_function_calls = 1
" let g:go_highlight_function_parameters = 1
" let g:go_highlight_format_strings = 1
" let g:go_auto_type_info = 0


" ALE
map <leader>= :ALEFix<cr>
nmap <silent> [e <Plug>(ale_previous_wrap)
nmap <silent> ]e <Plug>(ale_next_wrap)

" Better warning error ALE
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '•'
highlight ALEErrorSign ctermbg=NONE ctermfg=red
highlight ALEWarningSign ctermbg=NONE ctermfg=yellow

" " Edit quickly config nvim
" nmap <Leader><Leader>c :e ~/.config/nvim/init.vim<CR>
" noremap <Leader><Leader>r :so ~/.config/nvim/init.vim<CR>

" Indentline
"let g:indentLine_char = '¦'
""Prevent hidden double quotes in json file and markdown
"let g:indentLine_setConceal = 2
"let g:indentLine_concealcursor = ""
"let g:indentLine_fileTypeExclude = ['defx']

" [rails.vim] custom commands
" command! Eroutes Einitializer
" command! Egemfile edit Gemfile
" command! Ereadme edit README.md

" SplitJoin
let g:splitjoin_join_mapping = ''
let g:splitjoin_split_mapping = ''
nmap <Leader>sj :SplitjoinJoin<CR>
nmap <Leader>sk :SplitjoinSplit<CR>

" Buffer
" map <leader>xx :Bclose<cr>
map <leader>xa :call CloseAllBuffersExceptCurrent()<cr>
" map <silent> <leader>l :bnext<cr>
" map <silent> <leader>h :bprevious<cr>

" Ale plugin
" let b:ale_linters = {
"   \ 'javascript': ['eslint'],
"   \ 'ypescript': ['eslint'],
"   \ 'ruby': ['rubocop'],
"   \}

" let g:ale_fixers = {
"   \ 'ruby': ['rubocop'],
"   \ 'javascript': ['eslint'],
"   \ 'css': ['prettier'],
"   \ 'json': ['prettier'],
"   \ 'yaml': ['prettier'],
"   \}

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

command! FZFMru call fzf#run({
\ 'source':  reverse(s:all_files()),
\ 'sink':    'edit',
\ 'options': '-m -x +s',
\ 'down':    '40%' })

function! s:all_files()
  return extend(
  \ filter(copy(v:oldfiles),
  \        "v:val !~ 'fugitive:\\|NERD_tree\\|^/tmp/\\|.git/'"),
  \ map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'))
endfunction

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
  let curr = bufnr("%")
  let last = bufnr("$")
  if curr > 1 | silent! execute "1,".(curr-1)."bd" | endif
  if curr < last | silent! execute (curr+1).",".last."bd" | endif
endfunction

" " Detect  Go HTML
" function DetectGoHtmlTmpl()
"     if expand('%:e') == "html" && search("{{") != 0
"         set filetype=gohtmltmpl
"     endif
" endfunction

" augroup filetypedetect
"     au! BufRead,BufNewFile * call DetectGoHtmlTmpl()
" augroup END

" function! s:isAtStartOfLine(mapping)
"   let text_before_cursor = getline('.')[0 : col('.')-1]
"   let mapping_pattern = '\V' . escape(a:mapping, '\')
"   let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
"   return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
" endfunction
