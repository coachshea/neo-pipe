function! s:match(line)
  let l:match = matchlist(a:line, '\vfile\s+(\S+)\s+line\s+(\d+)')
  if !empty(l:match)
    call s:move(l:match)
  else
    let l:match = matchlist(a:line, '(\d)')
    if !empty(l:match)
      call s:move(l:match)
    endif
  endif
endfunction

function! s:move(match)
  echom printf('edit +%s %s', a:match[1], a:match[2])
  " exe printf('edit +%s %s', a:match[1], a:match[2])
  " exe 'match Search /\%' .line('.').'l/'
endfunction

nnoremap <buffer> <Leader>x :call clearmatches()<CR>
nnoremap <buffer> <Leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>
