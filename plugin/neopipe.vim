if exists('g:neopipe_plug')
  finish
endif
let g:neopipe_plug = 1

function! s:pipe(type)
  '[, ']NeoPipe
endfunction

command! -range=% NeoPipe call neopipe#pipe(<line1>,<line2>)

nnoremap <plug>(neopipe-operator) :set operatorfunc=<sid>pipe<cr>g@

if !exists('g:neopipe_do_no_mappings')
  nnoremap ,t  :set operatorfunc=<sid>pipe<cr>g@
  nnoremap ,tt :.NeoPipe<cr>
  nnoremap ,tg :NeoPipe<cr>
  nnoremap ,tq :call neopipe#close()<cr>
  xnoremap ,t :NeoPipe<cr>
endif
