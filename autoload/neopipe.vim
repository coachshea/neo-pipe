if exists('g:neopipe_auto')
  finish
endif
let g:neopipe_auto = 1

function! s:buffer_setup()
  let l:bufname = bufname( '%' ) . ' [NeoPipe]'
  exe g:neopipe_split
  let l:npipe_buffer = bufnr('%')
  exe 'file ' . l:bufname
  call setbufvar(l:npipe_buffer, '&swapfile', 0)
  call setbufvar(l:npipe_buffer, '&buftype', 'nofile')
  call setbufvar(l:npipe_buffer, '&bufhidden', 'wipe')
  wincmd p
  let b:child = l:npipe_buffer
endfunction

" function! s:find(var, def)
"   let l:var = get(b:, a:var, get(g:, a:var, ''))
"   if !len(l:var)
"     let l:temp = projectionist#query_scalar(a:var)
"     if !empty(l:temp)
"       let l:var = l:temp[0]
"     else
"       let l:var = a:def
"     endif
"   endif
"   return l:var
" endfunction

function! s:find(var, def)
  let l:var = get(b:, a:var, get(g:, a:var, ''))
  if len(l:var)
    return l:var
  endif
  let l:temp = projectionist#query_scalar(a:var)
  if !empty(l:temp)
    return l:temp[0]
  endif
  return a:def
endfunction

function! s:find_start()
  return s:find('npipe_start', &shell)
endfunction

function! s:find_ft()
  return s:find('npipe_ft', '')
endfunction

function! s:find_com()
  return s:find('npipe_com', '')
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
