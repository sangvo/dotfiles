"Plugin
call plug#begin('~/.config/nvim/bundle')
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-tmux-navigator'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-surround'
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-commentary'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-repeat'
Plug 'honza/vim-snippets'
Plug 'kana/vim-textobj-user'
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'AndrewRadev/splitjoin.vim'
Plug 'godlygeek/tabular'
Plug 'kristijanhusak/defx-icons'
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
Plug 'ludovicchabant/vim-gutentags'
Plug 'vim-test/vim-test'
Plug 'justinmk/vim-sneak'

" Markdown Blog
Plug 'plasticboy/vim-markdown'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'cespare/vim-toml'

" Spell grammar
Plug 'kamykn/spelunker.vim'

" For Rails
Plug 'vim-ruby/vim-ruby'
Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'tpope/vim-rails'
Plug 'neoclide/coc-solargraph', {'do': 'yarn install --frozen-lockfile'}
Plug 'tpope/vim-endwise'
Plug 'dyng/ctrlsf.vim'

" Go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" React
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'jparise/vim-graphql'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'HerringtonDarkholme/yats.vim'

"HTML
Plug 'othree/html5.vim'

"UI
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General configs                                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=UTF-8
set history=500
set mouse=a " enable mouse for all mode
set noswapfile
set backspace=indent,eol,start
set whichwrap+=<,>,h,l
set autoread                  " Set to auto read when a file is changed
set clipboard=unnamed         " Use the OS clipboard by default
set hid                       " A buffer becomes hidden when it is abandoned
filetype indent on            " Enable filetype plugins
filetype plugin on
syntax enable
set textwidth=120             " Text width maximum chars before wrapping
set autoindent                " Auto-indent new lines
set tabstop=4                 " The number of spaces a tab is
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
set nospell                   " turn off vim spell same work

" Editor UI
set termguicolors
set fillchars+=vert:\|        " add a bar for vertical splits
set fcs=eob:\                 " hide ~ tila
set list
set listchars=tab:»·,nbsp:+,trail:·,extends:→,precedes:←

" Auto remove trailing spaces
autocmd BufWritePre * %s/\s\+$//e

" Scheme
set background=dark
colorscheme oceanic_material
let g:oceanic_material_background='ocean'
let g:oceanic_material_allow_bold=1
let g:oceanic_material_allow_italic=1

" Set background terminal and line number transparent
highlight clear SignColumn
hi Normal ctermbg=NONE guibg=NONE
hi VertSplit guifg=grey guibg=NONE gui=NONE cterm=NONE

" Override color spell hightlight
highlight SpelunkerSpellBad cterm=underline ctermfg=247 gui=underline guifg=NONE
highlight SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=underline guifg=NONE

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings                                                                    "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader=" "
imap jk <Esc>
map 0 ^
" Dont use recording
map q <Nop>

nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Useful saving mapping
noremap <leader>w :w!<cr>
noremap <C-S> :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <Esc>:update<CR>
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>"

"Copy to clipboard"
vmap <C-C> "+y
vmap <leader>y "+y
nmap <leader>y "+y
nmap <leader>p "+p

"yank to end
nnoremap Y y$

" React
" let g:vim_jsx_pretty_colorful_config = 1
let g:vim_jsx_pretty_highlight_close_tag = 1

" HTML
let g:html5_event_handler_attributes_complete = 0
let g:html5_rdfa_attributes_complete = 0
let g:html5_microdata_attributes_complete = 0
let g:html5_aria_attributes_complete = 0

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

"  Resize panel
nmap <C-w>[ :vertical resize -3<CR>
nmap <C-w>] :vertical resize +3<CR>

" Buffer tab
map <leader>tc :tabnew<cr>
map <leader>tx :tabclose<cr>

"Tabular
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a: :Tabularize /:\zs<CR>
vmap <Leader>a: :Tabularize /:\zs<CR>

" Vim test
nmap <silent> <Leader>cs :TestNearest<CR>
nmap <silent> <Leader>rs :TestFile<CR>
nmap <silent> <Leader>ra :TestSuite<CR>
nmap <silent> <Leader>rl :TestLast<CR>

let test#ruby#rspec#options = {
  \ 'nearest': '--backtrace',
  \ 'file':    '--format documentation',
  \ 'suite':   '--tag ~slow',
\}

" Enable matchit for ruby textobject
runtime macros/matchit.vim

" Fzf
nnoremap <silent> <c-p> :Files<cr>
nnoremap <silent> <leader>b :Buffers<cr>
nnoremap <silent> <leader>fr :Rg<cr>
nnoremap <Leader>t :BTags<CR>

" Ack
nnoremap <leader>a :Ack!<Space>
vnoremap <leader>a :call VisualSelection('gv', '')<CR>

let g:ackprg = "rg --vimgrep --type-not sql --smart-case"
let g:ack_mappings = {
  \ 'h': '<C-W>k<C-W>l<C-W>l<C-W>s<C-W>j<CR>',
  \ 'v': '<C-W><CR><C-W>L<C-W>p<C-W>J<C-W>p',
  \ 'gv': '<C-W><CR><C-W>L<C-W>p<C-W>J',
  \ 'q': '<C-W>p' }

" Fugitive
nnoremap <silent> <leader>gl :Glog<cr>
nnoremap <silent> <Leader>gad :Git add %:p<CR>
"nnoremap <silent> <Leader>gc :Git commit<CR>
nnoremap <silent> <Leader>gb :Git blame<CR>
nnoremap <silent> <Leader>gf :Gfetch<CR>
nnoremap <silent> <Leader>gs :Git<CR>
nnoremap <silent> <Leader>gp :Gpush<CR>
" Fugitive Conflict Resolution
nnoremap <silent> <Leader>gdf :Gvdiff!<CR>
nnoremap gdh :diffget //2<CR>
nnoremap gdl :diffget //3<CR>

" Vim sneak
let g:sneak#label = 1
map s <Plug>Sneak_s
map S <Plug>Sneak_S
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" Coc.nvim
" nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gd :call <SID>GoToDefinition()<CR>
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
nnoremap  <Leader>fz :<C-u>CocSearch -w<Space>
nnoremap <silent>K :call <SID>show_documentation()<CR>

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

" Go (Google)
let g:go_highlight_structs = 1
let g:go_highlight_methods = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_format_strings = 1
let g:go_auto_type_info = 0

autocmd FileType go
                   \  let b:coc_pairs_disabled = ['<']
                   \ | let b:coc_root_patterns = ['.git', 'go.mod']

autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')

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
"Prevent hidden double quotes in json file and markdown
let g:indentLine_setConceal = 2
let g:indentLine_concealcursor = ""
let g:indentLine_fileTypeExclude = ['defx']

" [rails.vim] custom commands
command! Eroutes Einitializer
command! Egemfile edit Gemfile
command! Ereadme edit README.md

" Vim color highlighting
let g:Hexokinase_v2 = 0
let g:Hexokinase_highlighters = ['virtual']
let g:Hexokinase_virtualText = '▩'
let g:Hexokinase_optInPatterns = [
\     'full_hex',
\     'triple_hex',
\     'rgb',
\     'rgba',
\     'hsl',
\     'hsla',
\     'colour_names'
\ ]
" Maping
nmap <Leader>co :HexokinaseToggle<CR>

" SplitJoin
let g:splitjoin_join_mapping = ''
let g:splitjoin_split_mapping = ''
nmap <Leader>sj :SplitjoinJoin<CR>
nmap <Leader>sk :SplitjoinSplit<CR>

" Defx
augroup vimrc_defx
  autocmd!
  autocmd FileType defx call s:defx_mappings()
  autocmd VimEnter * call s:setup_defx()
augroup END

nnoremap <silent> <Leader>e
  \ :<C-u>Defx -resume -toggle -buffer-name=tab`tabpagenr()`<CR>
nnoremap <silent> <Leader>F
  \ :<C-u>Defx -resume -toggle=0 -buffer-name=tab`tabpagenr()` -search=`expand('%:p')`<CR>
let s:default_columns = 'mark:indent:icons:filename'


function! s:defx_mappings() abort
  nnoremap <silent><buffer><expr> o <sid>defx_toggle_tree()
  nnoremap <silent><buffer><expr> O defx#do_action('open_tree_recursive')
  nnoremap <silent><buffer><expr> <CR> <sid>defx_toggle_tree()
  nnoremap <silent><buffer><expr> <2-LeftMouse> <sid>defx_toggle_tree()
  nnoremap <silent><buffer><expr> C defx#is_directory() ? defx#do_action('multi', ['open', 'change_vim_cwd']) : 'C'
  nnoremap <silent><buffer><expr> s defx#do_action('open', 'botright vsplit')
  nnoremap <silent><buffer><expr> R defx#do_action('redraw')
  nnoremap <silent><buffer><expr> U defx#do_action('multi', [['cd', '..'], 'change_vim_cwd'])
  nnoremap <silent><buffer><expr> H defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> <Space> defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> j line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> yy defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> a defx#do_action('new_multiple_files')
  nnoremap <silent><buffer><expr> r defx#do_action('rename')
  nnoremap <nowait><silent><buffer><expr> c defx#do_action('copy')
  nnoremap <silent><buffer><expr> x defx#do_action('move')
  nnoremap <silent><buffer><expr> X defx#do_action('execute_system')
  nnoremap <silent><buffer><expr> p defx#do_action('paste')
  nnoremap <nowait><silent><buffer><expr> d defx#do_action('remove')
  nnoremap <silent><buffer><expr> q defx#do_action('quit')
  nnoremap <silent><buffer><expr> P defx#do_action('preview')
  nnoremap <silent><buffer><expr> v defx#do_action('toggle_select')
  nnoremap <silent><buffer><expr> V defx#do_action('clear_select_all')
  nnoremap <silent><buffer><expr> * defx#do_action('toggle_select_all')
  nnoremap <silent><buffer><expr> ~ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> K defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> <Leader>n defx#do_action('quit')
  silent exe 'nnoremap <silent><buffer><expr> tt defx#do_action("toggle_columns", "'.s:default_columns.':size:time")'
endfunction

"Goyo markdown writing
map <leader>G :Goyo<CR>

" Goyo Commands {{{
augroup user_plugin_goyo
	autocmd!
	autocmd! User GoyoEnter
	autocmd! User GoyoLeave
	autocmd  User GoyoEnter nested call <SID>goyo_enter()
    autocmd User GoyoLeave nested source $MYVIMRC |
	autocmd  User GoyoLeave nested call <SID>goyo_leave()
augroup END

" Limelight
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'

let g:vim_markdown_folding_level = 1
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_auto_insert_bullets = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_edit_url_in = 'vsplit'
let g:markdown_fenced_languages = [
      \'html',
      \'css',
      \'scss',
      \'sql',
      \'javascript',
      \'go',
      \'py=python',
      \'bash=sh',
      \'ruby',
      \'js=javascript', 'json=javascript', 'jsx=javascriptreact', 'tsx=typescriptreact'
      \'docker=Dockerfile']

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
  let curr = bufnr("%")
  let last = bufnr("$")
  if curr > 1 | silent! execute "1,".(curr-1)."bd" | endif
  if curr < last | silent! execute (curr+1).",".last."bd" | endif
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

" Detect  Go HTML
function DetectGoHtmlTmpl()
    if expand('%:e') == "html" && search("{{") != 0
        set filetype=gohtmltmpl
    endif
endfunction

augroup filetypedetect
    au! BufRead,BufNewFile * call DetectGoHtmlTmpl()
augroup END

" Defx
function! s:setup_defx() abort
  silent! call defx#custom#option('_', {
        \ 'columns': s:default_columns,
        \ 'winwidth': 35,
        \ 'direction': 'topleft',
        \ 'split': 'vertical',
        \ 'resume': v:false,
        \ 'toggle': v:true
        \ })

  silent! call defx#custom#column('filename', {
        \ 'min_width': 80,
        \ 'max_width': 80,
        \ })

  silent! call defx#custom#column('icon', {
      \ 'directory_icon': '▸',
      \ 'opened_icon': '▾',
      \ 'root_icon': '',
      \ })

  silent! call defx#custom#column('mark', {
        \ 'readonly_icon': '✗',
        \ 'selected_icon': '⚫',
        \ })

  call s:defx_open({ 'dir': expand('<afile>') })
endfunction

function s:get_project_root() abort
  let l:git_root = ''
  let l:path = expand('%:p:h')
  let l:cmd = systemlist('cd '.l:path.' && git rev-parse --show-toplevel')
  if !v:shell_error && !empty(l:cmd)
    let l:git_root = fnamemodify(l:cmd[0], ':p:h')
  endif

  if !empty(l:git_root)
    return l:git_root
  endif

  return getcwd()
endfunction

function! s:defx_open(...) abort
  let l:opts = get(a:, 1, {})
  let l:is_file = has_key(l:opts, 'dir') && !isdirectory(l:opts.dir)

  if  &filetype ==? 'defx' || l:is_file
    return
  endif

  let l:path = s:get_project_root()

  if has_key(l:opts, 'dir') && isdirectory(l:opts.dir)
    let l:path = l:opts.dir
  endif

  if has_key(l:opts, 'find_current_file')
    call execute(printf('Defx -search=%s %s', expand('%:p'), l:path))
  else
    call execute(printf('Defx -toggle %s', l:path))
    call execute('wincmd p')
  endif

  return execute("norm!\<C-w>=")
endfunction

function s:defx_toggle_tree() abort
  if defx#is_directory()
    return defx#do_action('open_or_close_tree')
  endif
  return defx#do_action('drop')
endfunction

function! s:goyo_enter()
	if has('gui_running')
		" Gui fullscreen
		set fullscreen
		set linespace=7
	elseif exists('$TMUX')
		" Hide tmux status
		silent !tmux set status off
	endif

	" Activate Limelight
	Limelight
endfunction

" }}}
" s:goyo_leave() "{{{
" Enable visuals when leaving Goyo mode
function! s:goyo_leave()
	if has('gui_running')
		" Gui exit fullscreen
		set nofullscreen
		set background=dark
		set linespace=0
	elseif exists('$TMUX')
		" Show tmux status
		silent !tmux set status on
	endif

	" De-activate Limelight
	Limelight!
endfunction
" }}}

function! s:GoToDefinition()
  if CocAction('jumpDefinition')
    return v:true
  endif

  let ret = execute("silent! normal \<C-]>")
  if ret[:5] =~ "Error"
    call searchdecl(expand('<cword>'))
  endif
endfunction

function! CmdLine(str)
  call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
  let l:saved_reg = @"
  execute "normal! vgvy"

  let l:pattern = escape(@", "\\/.*'$^~[]")
  let l:pattern = substitute(l:pattern, "\n$", "", "")

  if a:direction == 'gv'
    call CmdLine("Ack '" . l:pattern . "' " )
  endif

  let @/ = l:pattern
  let @" = l:saved_reg
endfunction
