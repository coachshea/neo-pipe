nnoremap <plug>(neopipe-operator) :set operatorfunc=neopipe#pipe<cr>g@
vnoremap <plug>(neopipe-visual) :<c-u>call neopipe#pipe(visualmode())<cr>
nnoremap <plug>(neopipe-line) :<c-u>call neopipe#pipe(1)<cr>
