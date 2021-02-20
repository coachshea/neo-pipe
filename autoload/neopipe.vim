if exists('g:neopipe_auto')
  finish
endif
let g:neopipe_auto = 1

" private functions {{{
function! s:buffer_setup()
   
  let l:bufname = bufname( '%' ) . ' [NeoPipe]'

  exe printf('%s %s', s:find('npipe_split', 'vsplit', 0), l:bufname)

  let l:child = bufnr('%')
  wincmd p
  let w:child = l:child

  call setbufvar(w:child, '&swapfile', 0)
  call setbufvar(w:child, '&buftype', 'nofile')
  call setbufvar(w:child, '&bufhidden', 'wipe')
  call setbufvar(w:child, '&ft', s:find('npipe_ft', '', 0))

endfunction

function! s:find(var, def, arr)

  " window-local
  if exists('w:'.a:var)
    return get(w:, a:var)
  endif

  " buffer-local
  if exists('b:'.a:var)
    let l:var = get(b:, a:var)
    call setwinvar('', a:var, l:var)
    return l:var
  endif

  " projection
  if exists('b:projectionist')
    let l:temp = projectionist#query_scalar(a:var)
    if !empty(l:temp)
      let l:var = a:arr ? l:temp : l:temp[0]
      call setwinvar('', a:var, l:var)
      return l:var
    endif
  endif

  " global
  if exists('g:'.a:var)
    let l:var = get(g:, a:var)
    call setwinvar('', a:var, l:var)
    return l:var
  endif

  " default
  call setwinvar('', a:var, a:def)
  return a:def

endfunction

function! s:err(id, data, event)
  echoerr printf('error: %s', join(a:data))
endfunction

function! s:out(id, data, event)
  call s:apply_contents(a:data[:-2])
endfunction

let s:callbacks = {
      \ 'on_stdout': function('s:out'),
      \ 'on_stderr': function('s:err'),
      \ }

function! s:apply_contents(contents)

  let l:type = s:find('npipe_type', 0, 0)

  let l:append = s:find('npipe_append', '', 0)

  if l:append ==# 'top'
    let l:sep = s:find('npipe_sep', ['', '---'], 1)
    call nvim_buf_set_lines(w:child, 0, 0, 0, l:sep + a:contents)
  elseif l:append ==# 'bottom'
    let l:sep = s:find('npipe_sep', ['', '---'], 1)
    call nvim_buf_set_lines(w:child, -1, -1, 0, a:contents + l:sep)
    let l:switchbuf_before = &switchbuf
    set switchbuf=useopen
    exe 'sbuffer' w:child
    exe line('$')
    wincmd p
    let &switchbuf = l:switchbuf_before
  else
    call nvim_buf_set_lines(w:child, 0, -1, 0, a:contents)
  endif

endfunction
"}}}

" pubic function {{{
function! neopipe#pipe(first, last)

  if s:find('npipe_pty', 0, 0)
    echoerr 'npipe_pty is depreecated'
    echoerr "set npipe_type='t'"
    let w:npipe_type = 't'
  endif

  let l:lines = getline(a:first, a:last) + ['']

  let l:type = s:find('npipe_type', '', 0)

  let l:com = s:find('npipe_com', '', 0)

  if l:type ==# 't'
    if !exists('w:npipe_job')
      let l:bufname = bufname( '%' ) . ' [NeoPipe]'

      exe printf('%s %s', s:find('npipe_split', 'vsplit', 0), l:bufname)

      let l:child = bufnr('%')
      let l:npipe_job = termopen(l:com, {'on_stderr': function('s:err') })
      au BufLeave <buffer> normal! G
      wincmd p
      let w:npipe_job = l:npipe_job
      let w:child = l:child
    endif
    call jobsend(w:npipe_job, l:lines) 
  else
    if !exists('w:child') || !buflisted(w:child)
      call s:buffer_setup()
    endif
    if l:type ==# 'c'
      if !exists('w:npipe_job')
        let w:npipe_job = jobstart(l:com, s:callbacks)
      endif
      call jobsend(w:npipe_job, l:lines)
    elseif l:type ==# 's'
      call s:apply_contents(systemlist(l:com, l:lines))
    else
      call s:apply_contents(l:lines[:-2])
    endif
  endif

endfunction

function! neopipe#clear_buffer()

  if w:npipe_type !=# 't'
    let l:switchbuf_before = &switchbuf
    set switchbuf=useopen
    exe w:child . 'sbuffer'
    %d _
    wincmd p
    let &switchbuf = l:switchbuf_before
  else
    echoerr 'cannot clear a terminal buffer'
  endif

endfunction

function! neopipe#close()

  if exists('w:npipe_job')
    call jobstop(w:npipe_job)
    unlet! w:npipe_job
  endif

  if exists('w:child')
    exe w:child . 'bw!'
    unlet! w:child
  endif

  if exists('w:npipe_com')
    unlet! w:npipe_com
  endif

  if exists('w:npipe_type')
    unlet! w:npipe_type
  endif

  if exists('w:npipe_append')
    unlet! w:npipe_append
  endif

  if exists('w:npipe_split')
    unlet! w:npipe_split
  endif

  if exists('w:npipe_sep')
    unlet! w:npipe_sep
  endif

endfunction
"}}}
" vim: foldmethod=marker:
