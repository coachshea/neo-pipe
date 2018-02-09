if exists('g:neopipe_plug')
  finish
endif
let g:neopipe_plug = 1

nnoremap <plug>(neopipe-operator) :set operatorfunc=neopipe#pipe<cr>g@
nnoremap <plug>(neopipe-line) :<c-u>call neopipe#pipe(1)<cr>
nnoremap <plug>(neopipe-close) :<c-u>call neopipe#close()<cr>
vnoremap <plug>(neopipe-visual) :<c-u>call neopipe#pipe(visualmode())<cr>

if !exists('g:neopipe_split')
  let g:neopipe_split = 'vnew'
endif

if !exists('g:neopipe_do_no_mappings')
  nmap ,t  <plug>(neopipe-operator)
  nmap ,tt <plug>(neopipe-line)
  nmap ,tq <plug>(neopipe-close)
  vmap ,t <plug>(neopipe-visual)
endif
