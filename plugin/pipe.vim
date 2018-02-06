
nnoremap <localleader>t :set operatorfunc=<sid>PipeOperator<cr>g@
vnoremap <localleader>t :<c-u>call <sid>PipeOperator(visualmode())<cr>
nnoremap <cr> :<c-u>call <sid>PipeOperator(1)<cr>

function! s:PipeOperator(type)

    " if !exists("b:scratchbuf")
    "   let w:parent = bufnr("%")
    "   vsplit new
    "   let w:child = bufnr("%")
    "   call nvim_buf_set_lines(w:child, 0, -1, 0, [])
    "   exe w:parent . "wincmd"
    " endif
    let l:saved_unnamed_register = @@

    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'V'
        normal! '<y'>
    elseif a:type ==# 'char'
        normal! `[y`]
    elseif a:type ==# 'line'
        normal! '[y']
    else
       normal! yy
    endif

    " echom shellescape(@@)
    call nvim_buf_set_lines(2, 0, -1, 0, [])
    let l:lines = split(@@, "\n")
    call nvim_buf_set_lines(2, 0, 0, 0, l:lines)
    " silent execute "grep! -R " . shellescape(@@) . " ."
    " copen

    let @@ = l:saved_unnamed_register
endfunction
