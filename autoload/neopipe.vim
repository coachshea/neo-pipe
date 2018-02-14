if exists('g:neopipe_auto')
  finish
endif
let g:neopipe_auto = 1

" setup {{{
function! s:buffer_setup()
  let l:buf_ft = s:find('npipe_ft', '')
  let l:bufname = bufname( '%' ) . ' [NeoPipe]'
  exe g:neopipe_split
  let l:npipe_buffer = bufnr('%')
  exe 'file ' . l:bufname
  call setbufvar(l:npipe_buffer, '&swapfile', 0)
  call setbufvar(l:npipe_buffer, '&buftype', 'nofile')
  call setbufvar(l:npipe_buffer, '&bufhidden', 'wipe')
  call setbufvar(l:npipe_buffer, '&ft', l:buf_ft)
  wincmd p
  let b:child = l:npipe_buffer
endfunction

function! s:find(var, def)
  let l:var = get(b:, a:var, get(g:, a:var, ''))
  if len(l:var)
    return l:var
  endif
  if exists('b:projectionist')
    let l:temp = projectionist#query_scalar(a:var)
    let l:qry = projectionist#query(a:var)
    if !empty(l:temp)
      return l:temp[0]
    endif
  endif
  return a:def
endfunction

"}}}

" job {{{
function! s:stdout(id, data, event)
  echom a:id . join(a:data) . a:event
  call nvim_buf_set_lines(b:child, 0, -1, 0, a:data[:-2])
endfunction

function! s:stderr(id, data, event)
  echom a:id . join(a:data) . a:event
  call nvim_buf_set_lines(b:child, 0, -1, 0, a:data[:-2])
endfunction

function! s:exit(id, data, event)
  exe b:child . 'bw!'
  unlet! b:child
  unlet! b:job
endfunction

let s:callbacks = {
      \ 'on_stdout': function('s:stdout'),
      \ 'on_stderr': function('s:stderr'),
      \ 'on_exit': function('s:exit')
      \ }

function! s:shell()
  let l:start = s:find('npipe_start', &shell)
  let b:job = jobstart(l:start, s:callbacks)
endfunction
"}}}

function! neopipe#pipe(type)

  if !exists('b:child') || !buflisted(b:child)
    call s:buffer_setup()
  endif

  if !exists('b:job')
    call s:shell()
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

  call jobsend(b:job, @@)

  let &selection = l:sel_save
  let @@ = l:saved_unnamed_register
endfunction

function! neopipe#close()
  call jobstop(b:job)
endfunction
" vim: foldmethod=marker:
