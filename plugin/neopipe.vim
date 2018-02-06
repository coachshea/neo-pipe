nnoremap <localleader>t :set operatorfunc=<sid>PipeOperator<cr>g@
vnoremap <localleader>t :<c-u>call <sid>PipeOperator(visualmode())<cr>
nnoremap <cr> :<c-u>call <sid>PipeOperator(1)<cr>

function! s:PipeOperator(type)

    if !exists('t:child')
      let t:parent = bufnr('%')
      vsplit new
      let t:child = bufnr('%')
      call nvim_buf_set_lines(t:child, 0, -1, 0, [])
      exe t:parent . 'wincmd'
    endif
    
    let l:saved_unnamed_register = @@

    if a:type ==# 'v'
        normal! `<y`>
    elseif a:type ==# 'V'
        normal! '<y'>
    elseif a:type ==# 'char'
        normal! `[y`]
    elseif a:type ==# 'line'
        normal! '[y']
    else
       normal! yy
    endif

    call nvim_buf_set_lines(2, 0, -1, 0, [])
    let l:lines = split(@@, "\n")
    call nvim_buf_set_lines(2, 0, 0, 0, l:lines)

    let @@ = l:saved_unnamed_register
endfunction
