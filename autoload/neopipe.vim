if exists('g:neopipe_auto')
  finish
endif
let g:neopipe_auto = 1

" setup {{{
function! s:buffer_setup()
  let l:buf_ft = s:find('npipe_ft', '')
  let l:bufname = bufname( '%' ) . ' [NeoPipe]'
  echom 'split: ' . s:find('npipe_split', 'vnew')
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
function! s:out(id, data, event)
  echom a:id . join(a:data) . a:event
  call nvim_buf_set_lines(b:child, 0, -1, 0, a:data[:-2])
endfunction

let s:callbacks = {
      \ 'on_stdout': function('s:out'),
      \ 'on_stderr': function('s:out')
      \ }

function! s:shell()
  let l:start = s:find('npipe_start', '')
  if len(l:start)
    echom 'l:start: ' . l:start
    let b:job = jobstart(l:start, s:callbacks)
  else
    let l:com = s:find('npipe_com', '')
    if len(l:com)
      echom 'l:com: ' . l:com
      let b:com = l:com
    endif
  endif
  echom 'nothing'
endfunction
"}}}

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
  elseif a:type == 1
    normal! yy
  elseif a:type == 2
    normal! mqggVGy`q
  endif

  if exists('b:job')
    call jobsend(b:job, @@)
  elseif exists('b:com')
    call nvim_buf_set_lines(b:child, 0, -1, 0, systemlist(b:com, @@))
  else
    call s:shell()
    if exists('b:job')
      call jobsend(b:job, @@)
    elseif exists('b:com')
      call nvim_buf_set_lines(b:child, 0, -1, 0, systemlist(b:com, @@))
    else
      call nvim_buf_set_lines(b:child, 0, -1, 0, split(@@, "\n"))
    endif
  endif

  let &selection = l:sel_save
  let @@ = l:saved_unnamed_register
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
