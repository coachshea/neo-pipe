if exists('g:neopipe_plug')
  finish
endif
let g:neopipe_plug = 1

function! s:pipe(type)
  '[, ']NeoPipe
endfunction

command! -range=% NeoPipe call neopipe#pipe(<line1>,<line2>)
command! NeoPipeClear call neopipe#clear_buffer()
command! NeoPipeClose call neopipe#close()

nnoremap <plug>(neopipe-operator) :set operatorfunc=<sid>pipe<cr>g@

if !exists('g:neopipe_do_no_mappings')
  nnoremap ,t  :set operatorfunc=<sid>pipe<cr>g@
  nmap     ,tt ,t_
  nnoremap ,tg :NeoPipe<cr>
  nnoremap ,tq :call neopipe#close()<cr>
  nnoremap ,tc :call neopipe#clear_buffer()<cr>
  xnoremap ,t  :NeoPipe<cr>
endif
