if exists('g:neopipe_auto')
  finish
endif
let g:neopipe_auto = 1


function! neopipe#pipe(type)

  if !exists('b:child') || !bufexists(b:child)
    let l:parent = bufnr('%')
    vsplit new
    let l:child = bufnr('%')
    exe l:parent . 'wincmd'
    let b:child = l:child
  endif

  let l:sel_save = &selection
  let &selection = 'inclusive'
  let l:saved_unnamed_register = @@

  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'V'
    normal! '<V'>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  elseif a:type ==# 'line'
    normal! '[V']y
  else
    normal! yy
  endif

  call nvim_buf_set_lines(b:child, 0, -1, 0, split(@@, "\n"))

  let &selection = l:sel_save
  let @@ = l:saved_unnamed_register
endfunction
