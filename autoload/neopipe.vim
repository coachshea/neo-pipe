if exists('g:neopipe_auto')
  finish
endif
let g:neopipe_auto = 1

" setup {{{
function! s:buffer_setup()
  let l:buf_ft = s:find('npipe_ft', '')
  let l:bufname = bufname( '%' ) . ' [NeoPipe]'
  exe s:find('npipe_split', 'vnew')
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
  let l:var = get(b:, a:var, '')
  if l:var !=# ''
    return l:var
  endif
  if exists('b:projectionist')
    let l:var = projectionist#query_scalar(a:var)
    if !empty(l:var)
      return l:var[0]
    endif
  endif
  let l:var = get(g:, a:var, '')
  if l:var !=# ''
    return l:var
  endif
  return a:def
endfunction
"}}}

function! s:out(id, data, event)
  call nvim_buf_set_lines(b:child, 0, -1, 0, a:data[:-2])
endfunction

let s:callbacks = {
      \ 'on_stdout': function('s:out'),
      \ 'on_stderr': function('s:out')
      \ }

function! s:shell()
  let l:start = s:find('npipe_start', '')
  if len(l:start)
    let b:job = jobstart(l:start, s:callbacks)
  else
    let l:com = s:find('npipe_com', '')
    if len(l:com)
      let b:com = l:com
    endif
  endif
endfunction
"}}}

" function! neopipe#pipe(first, last)

"   let l:lines = getline(a:first, a:last) + ['']

"   if !exists('b:child') || !buflisted(b:child)
"     call s:buffer_setup()
"   endif

"   if exists('b:job')
"     call jobsend(b:job, l:lines)
"   elseif exists('b:com')
"     call nvim_buf_set_lines(b:child, 0, -1, 0, systemlist(b:com, l:lines))
"   else
"     call s:shell()
"     if exists('b:job')
"       call jobsend(b:job, l:lines)
"     elseif exists('b:com')
"       call nvim_buf_set_lines(b:child, 0, -1, 0, systemlist(b:com, l:lines))
"     else
"       call nvim_buf_set_lines(b:child, 0, -1, 0, l:lines[:-2])
"     endif
"   endif

" endfunction

function! neopipe#pipe(first, last)

  echom 'entered'
  
  let l:lines = getline(a:first, a:last) + ['']

  echom 'lines' . string(l:lines)

  if !exists('b:child') || !buflisted(b:child)
    call s:buffer_setup()
  endif

  echom 'buffer set'

  if !exists('b:npipe_com')
    let b:npipe_com = s:find('npipe_com', '')
    echom 'b:com initialized: ' . b:npipe_com
  endif
   
  if !exists('b:npipe_type')
    let b:npipe_type = s:find('npipe_type', '')
    echom 'b:type initialized: ' . b:npipe_type
  endif

  echom 'b:com: ' . b:npipe_com
  echom 'b:type: ' . b:npipe_type
   
  if b:npipe_type ==# 'c'
    if !exists(b:npipe_job)
      let b:npipe_job = jobstart(b:npipe_com, s:callbacks)
    endif
    cal jobsend(b:npipe_job, l:lines)
  elseif b:npipe_type ==# 's'
    call nvim_buf_set_lines(b:child, 0, -1, 0, systemlist(b:com, l:lines))
  else
    call nvim_buf_set_lines(b:child, 0, -1, 0, l:lines[:-2])
  endif

endfunction

function! neopipe#close()
  if exists('b:child')
    exe b:child . 'bw!'
    unlet! b:child
  endif
  if exists('b:job')
    call jobstop(b:job)
    unlet! b:job
  endif
  if exists('b:npipe_job')
    call jobstop(b:npipe_job)
    unlet! b:npipe_job
  endif
  if exists('b:com')
    unlet! b:com
  endif
  if exists('b:npipe_com')
    unlet! b:npipe_com
  endif
  if exists('b:npipe_type')
    unlet! b:npipe_type
  endif
endfunction
" vim: foldmethod=marker:
