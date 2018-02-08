                     _   _ _____ ___  ____ ___ ____  _____ 
                    | \ | | ____/ _ \|  _ \_ _|  _ \| ____|
                    |  \| |  _|| | | | |_) | || |_) |  _|  
                    | |\  | |__| |_| |  __/| ||  __/| |___ 
                    |_| \_|_____\___/|_|  |___|_|   |_____|
                                                           

Table of Contents
=================

<!-- vim-markdown-toc GFM -->

* [Purpose](#purpose)
* [Usage](#usage)
* [Mappings](#mappings)
* [Summary](#summary)

<!-- vim-markdown-toc -->

Purpose
=======

The purpsoe of this plugin is to allow user to send selected text through an
external command and display the output in a scratch buffer.

Usage
=====

Mappings
========

This plugin provides the following mappings:

```vim
<Plug>(neopipe-operator)
<Plug>(neopipe-visual)
<Plug>(neopipe-line)
```

By default these will be mapped to:

```vim
nmap ,t <Plug>(neopipe-operator)
nmap ,t <Plug>(neopipe-visual)
nmap ,tt <Plug>(neopipe-line)
```

If this is not desired simply include the following in your init.vim:

```vim
let g:neopipe_do_no_mappings=0
```

Summary
=======
