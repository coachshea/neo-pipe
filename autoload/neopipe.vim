if exists('g:neopipe_auto')
  finish
endif
let g:neopipe_auto = 1

" private functions {{{
function! s:buffer_setup() "{{{
   
  let l:bufname = bufname( '%' ) . ' [NeoPipe]'
  let b:child = bufnr(l:bufname, 1)

  call setbufvar(b:child, '&swapfile', 0)
  call setbufvar(b:child, '&buftype', 'nofile')
  call setbufvar(b:child, '&bufhidden', 'wipe')
  call setbufvar(b:child, '&ft', s:find('npipe_ft', ''))

  exe b:child . 'sbuffer'
  wincmd p
   
endfunction
"}}}

function! s:find(var, def) "{{{

  " buffer-local
  let l:var = get(b:, a:var, '')
  if len(l:var)
    return l:var
  endif

  " projection
  if exists('b:projectionist')
    let l:temp = projectionist#query_scalar(a:var)
    if !empty(l:temp)
      let l:var = l:temp[0]
      call setbufvar('', a:var, l:var)
      return l:var
    endif
  endif

  " global
  let l:var = get(g:, a:var, '')
  if len(l:var)
    call setbufvar('', a:var, l:var)
    return l:var
  endif

  " default
  call setbufvar('', a:var, a:def)
  return a:def

endfunction
"}}}

function! s:out(id, data, event) "{{{
  call s:apply_contents(a:data[:-2])
endfunction
"}}}

let s:callbacks = {
      \ 'on_stdout': function('s:out'),
      \ 'on_stderr': function('s:out')
      \ }

function! s:apply_contents(contents) "{{{

  let l:append = s:find('npipe_append', '')

  if l:append ==# 'top'
    call nvim_buf_set_lines(b:child, 0, 0, 0, a:contents + ['', ''])
  elseif l:append ==# 'bottom'
    call nvim_buf_set_lines(b:child, -1, -1, 0, ['', ''] + a:contents)
  else
    call nvim_buf_set_lines(b:child, 0, -1, 0, a:contents)
  endif

endfunction
"}}}
"}}}

" pubic function {{{
function! neopipe#pipe(first, last) "{{{

  let l:lines = getline(a:first, a:last) + ['']

  if !exists('b:child') || !bufexists(b:child)
    call s:buffer_setup()
  endif

  let l:com = s:find('npipe_com', '')
   
  let l:type = s:find('npipe_type', '')
   
  if l:type ==# 'c'
    if !exists('b:npipe_job')
      let b:npipe_job = jobstart(l:com, s:callbacks)
    endif
    call jobsend(b:npipe_job, l:lines)
  elseif l:type ==# 's'
    call s:apply_contents(systemlist(l:com, l:lines))
  else
    call s:apply_contents(l:lines[:-2])
  endif

endfunction
"}}}

function! neopipe#clear_buffer() "{{{

  let l:switchbuf_before = &switchbuf
  set switchbuf=useopen
  exe b:child . 'sbuffer'
  %d _
  wincmd p
  let &switchbuf = l:switchbuf_before

endfunction
"}}}

function! neopipe#close() "{{{

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
"}}}

"}}}
" vim: foldmethod=marker:
