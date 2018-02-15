if exists('g:neopipe_auto')
  finish
endif
let g:neopipe_auto = 1

" setup {{{
function! s:buffer_setup()
  let l:buf_ft = s:find('npipe_ft')
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

function! s:find(var)
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
  return ''
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

" function! s:exit(id, data, event)
"   exe b:child . 'bw!'
"   unlet! b:child
"   unlet! b:job
"   unlet! b:com
" endfunction

let s:callbacks = {
      \ 'on_stdout': function('s:stdout'),
      \ 'on_stderr': function('s:stderr')
      \ }

function! s:shell()
  let l:start = s:find('npipe_start')
  if len(l:start)
    let b:job = jobstart(l:start, s:callbacks)
  else
    let l:com = s:find('npipe_com')
    if len(l:com)
      let b:com = l:com
    endif
  endif
endfunction
"}}}

function! neopipe#pipe(type)

  if !exists('b:child') || !buflisted(b:child)
    call s:buffer_setup()
  endif

  if !exists('b:job') && !exists('b:com')
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
  elseif a:type == 1
    normal! yy
  elseif a:type == 2
    normal! mqggVGy`q
  endif

  if exists('b:job')
    call jobsend(b:job, @@)
  elseif exists('b:com')
    " let l:lines = systemlist(b:com, @@)
    " call nvim_buf_set_lines(b:child, 0, -1, 0, l:lines)
    call nvim_buf_set_lines(b:child, 0, -1, 0, systemlist(b:com, @@))
  else
    call s:shell()
    if exists('b:job')
      call jobsend(b:job, @@)
    elseif exists('b:com')
      " let l:lines = systemlist(b:com, @@)
      " call nvim_buf_set_lines(b:child, 0, -1, 0, l:lines)
      call nvim_buf_set_lines(b:child, 0, -1, 0, systemlist(b:com, @@))
    else
      call nvim_buf_set_lines(b:child, 0, -1, 0, split(@@, "\n"))
    endif
  endif

  let &selection = l:sel_save
  let @@ = l:saved_unnamed_register
endfunction

function! neopipe#close()
  exe b:child . 'bw!'
  unlet! b:child
  if exists('b:job')
    call jobstop(b:job)
    unlet! b:job
  endif
  if exists('b:com')
    unlet! b:com
  endif
endfunction
" vim: foldmethod=marker:
