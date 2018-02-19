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

function! s:find_com()
  let l:start = get(b:, 'npipe_start', '')
  if l:start != ''
    let b:job = jobstart(l:start, s:callbacks)
    return
  endif
  let l:com = get(b:, 'npipe_com', '')
  if l:com != ''
    let b:com = l:com
    return
  endif
  if exists('b:projectionist')
    let l:start = projectionist#query_scalar('npipe_start')
    if !empty(l:start)
      let b:job = jobstart(l:start[0], s:callbacks)
      return
    endif
    let l:com = projectionist#query_scalar('npipe_com')
    if !empty(l:com)
      let b:com = l:com[0]
      return
    endif
  endif
  let l:start = get(g:, 'npipe_start')
  if l:start != ''
    let b:job = jobstart(l:start, s:callbacks)
    return
  endif
  let l:com = get(g:, 'npipe_com')
  if l:com != ''
    let b:com = l:com
    return
  endif
endfunction

function! s:find(var, def)
  let l:var = get(b:, a:var, '')
  if l:var != ''
    return l:var
  endif
  if exists('b:projectionist')
    let l:var = projectionist#query_scalar(a:var)
    if !empty(l:var)
      return l:var[0]
    endif
  endif
  let l:var = get(g:, a:var, '')
  if l:var != ''
    return l:var
  endif
  return a:def
endfunction
"}}}

" job {{{
" let s:data = []
" function! s:out(id, data, event)
"   echom 'a:data (start): ' . string(a:data)
"   echom 's:data (start): ' .  string(s:data)
"   echom 'last item: ' . a:data[-1]
"   if a:data[-1] !=# ''
"     let s:data += a:data
"     echom 'a:data (mid): ' . string(a:data)
"     echom 's:data (mid): ' . string(s:data)
"   else
"     echom 'success'
"     let s:data += a:data
"     call nvim_buf_set_lines(b:child, 0, -1, 0, s:data[:-2])
"     let s:data = []
"   endif
" endfunction

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

function! neopipe#pipe(first, last)

  let l:lines = getline(a:first, a:last) + ['']

  if !exists('b:child') || !buflisted(b:child)
    call s:buffer_setup()
  endif

  if exists('b:job')
    call jobsend(b:job, l:lines)
  elseif exists('b:com')
    call nvim_buf_set_lines(b:child, 0, -1, 0, systemlist(b:com, l:lines))
  else
    call s:shell()
    if exists('b:job')
      call jobsend(b:job, l:lines)
    elseif exists('b:com')
      call nvim_buf_set_lines(b:child, 0, -1, 0, systemlist(b:com, l:lines))
    else
      call nvim_buf_set_lines(b:child, 0, -1, 0, l:lines)
    endif
  endif

endfunction

function! neopipe#trial(first, last)
  
  let l:lines = getline(a:first, a:last)

  if !exists('b:child') || !buflisted(b:child)
    call s:buffer_setup()
  endif

  if !exists('b:com')
    call s:find('com', '')
  endif
  if !exists('b:type')
    call s:find('type', '')
  endif
  if b:type ==# 'job'
    cal jobsend(b:job, l:lines)
  elseif b:type ==# 'sys'
    call nvim_buf_set_lines(b:child, 0, -1, 0, systemlist(b:com, l:lines))
  else
    call nvim_buf_set_lines(b:child, 0, -1, 0, l:lines)
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
  if exists('b:com')
    unlet! b:com
  endif
endfunction
" vim: foldmethod=marker:
