if exists('g:neopipe_auto')
  finish
endif
let g:neopipe_auto = 1

function! s:buffer_setup()
  let l:buf_ft = s:find('npipe_ft', '')
  let l:bufname = bufname( '%' ) . ' [NeoPipe]'
  exe s:find('npipe_split', 'vnew')
  let l:npipe_buffer = bufnr('%')
  exe 'file ' . l:bufname
  " let l:npipe_buffer = bufnr(l:bufname, 1)
  call setbufvar(l:npipe_buffer, '&swapfile', 0)
  call setbufvar(l:npipe_buffer, '&buftype', 'nofile')
  call setbufvar(l:npipe_buffer, '&bufhidden', 'wipe')
  call setbufvar(l:npipe_buffer, '&ft', l:buf_ft)
  wincmd p
  let b:child = l:npipe_buffer
endfunction

function! s:find(var, def)

  " projection
  if exists('b:projectionist')
    let l:var = projectionist#query_scalar(a:var)
    if !empty(l:var)
      return l:var[0]
    endif
  endif

  " global
  let l:var = get(g:, a:var, '')
  if len(l:var)
    return l:var
  endif

  " default
  return a:def

endfunction

function! s:out(id, data, event)
  call s:apply_contents(a:data[:-2])
endfunction

let s:callbacks = {
      \ 'on_stdout': function('s:out'),
      \ 'on_stderr': function('s:out')
      \ }

function! neopipe#pipe(first, last)

  let l:lines = getline(a:first, a:last) + ['']

  if !exists('b:child') || !bufexists(b:child)
    call s:buffer_setup()
  endif

  if !exists('b:npipe_com')
    let b:npipe_com = s:find('npipe_com', '')
  endif
   
  if !exists('b:npipe_type')
    let b:npipe_type = s:find('npipe_type', '')
  endif
   
  if b:npipe_type ==# 'c'
    if !exists('b:npipe_job')
      let b:npipe_job = jobstart(b:npipe_com, s:callbacks)
    endif
    call jobsend(b:npipe_job, l:lines)
  elseif b:npipe_type ==# 's'
    call s:apply_contents(systemlist(b:npipe_com, l:lines))
  else
    call s:apply_contents(l:lines[:-2])
  endif


endfunction

function! s:apply_contents(contents)
  
  if !exists('b:npipe_append')
    let b:npipe_append = s:find('npipe_append', 0)
  endif

  if b:npipe_append
    let l:switchbuf_before = &switchbuf
    set switchbuf=useopen

    exe b:child . 'sbuffer'
    call append(line('$'), ['', ''] + a:contents)
    exe line('$')
    wincmd p

    let &switchbuf = l:switchbuf_before
  else
    call nvim_buf_set_lines(b:child, 0, -1, 0, a:contents)
  endif

endfunction

function! neopipe#clear_buffer()
  let l:switchbuf_before = &switchbuf
  set switchbuf=useopen
  exe b:child . 'sbuffer'
  %d _
  wincmd p
  let &switchbuf = l:switchbuf_before
endfunction

function! neopipe#close()
   
  if exists('b:child')
    exe b:child . 'bw!'
    unlet! b:child
  endif
   
  if exists('b:npipe_job')
    call jobstop(b:npipe_job)
    unlet! b:npipe_job
  endif
   
  if exists('b:npipe_com')
    unlet! b:npipe_com
  endif

  if exists('b:npipe_type')
    unlet! b:npipe_type
  endif

  if exists('b:npipe_append')
    unlet! b:npipe_append
  endif

endfunction
" vim: foldmethod=marker:
