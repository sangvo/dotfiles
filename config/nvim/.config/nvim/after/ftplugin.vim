" Set current working directory
au VimEnter * cd %:p:h

" Remove trailing whitespace on save
let g:strip_whitespace = v:true
augroup Whitespace
  au!
  au BufWritePre * if g:strip_whitespace | %s/\s\+$//e
augroup END

" Detect  Go HTML
function DetectGoHtmlTmpl()
    if expand('%:e') == "html" && search("{{") != 0
        set filetype=gohtmltmpl
    endif
endfunction

augroup filetypedetect
    au! BufRead,BufNewFile *.html call DetectGoHtmlTmpl()
augroup END

au BufNewFile,BufRead *.json.jbuilder set ft=ruby
au BufNewFile,BufRead *.json.jb set ft=ruby
