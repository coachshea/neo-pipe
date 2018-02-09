if exists('g:neopipe_auto')
  finish
endif
let g:neopipe_auto = 1

function! s:buffer_setup()
  " let l:bufname = bufname( '%' ) . ' [npipe]'
  " let l:npipe_buffer = bufnr(l:bufname, 1)
  " exe g:npipe_split . 'sbuffer ' . l:npipe_buffer
  " exe 'vsplit sbuffer ' . l:npipe_buffer
  vnew
  let l:npipe_buffer = bufnr('%')
  call setbufvar(l:npipe_buffer, '&swapfile', 0)
  call setbufvar(l:npipe_buffer, '&buftype', 'nofile')
  call setbufvar(l:npipe_buffer, '&bufhidden', 'wipe')
  let l:child = bufnr('%')
  wincmd p
  let b:child = l:npipe_buffer
endfunction

function! s:find(var, def)
  return get(b:, a:var, get(g:, a:var, a:def))
endfunction

function! s:find(var, def)
  let l:var = get(b:, a:var, get(g:, a:var, a:def))
  if empty(l:var)
    let l:temp = projectionist#query_scalar(a:var)
    if !empty(l:temp)
      let l:var = l:temp[0]
    endif
  endif
  return l:var
endfunction


function! neopipe#pipe(type)

  if !exists('b:child') || !buflisted(b:child)
    call s:buffer_setup()
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

function! neopipe#close()
  exe b:child . 'bw!'
  unlet b:child
endfunction
