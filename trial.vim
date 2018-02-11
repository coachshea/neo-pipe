function! s:match(line)
  let l:match = matchlist(a:line, '\vfile\s+(\S+)\s+line\s+(\d+)')
  if empty(l:match)
    let l:match = matchlist(a:line, '(\d)')
  endif
  exe printf('edit +%s %s', l:match[1], l:match[2])
  exe 'match Search /\%' .line('.').'l/'
endfunction

nnoremap <buffer> <Leader>x :call clearmatches()<CR>
nnoremap <buffer> <Leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>
