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

The purpsoe of this plugin is to allow the user to send text through an
external command and display the output in a scratch buffer. Mappings are
defined which can take an operator, work on a visual selection, or work on a
line.

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

As expected, the "operator" mapping leaves the user in operator-pending mode
and sends the results of the operator to the command. The "visual" mapping
sends the viusally selected text, and the "line" mapping send the current
line. By default these will be mapped to:

```vim
nmap ,t <Plug>(neopipe-operator)
nmap ,tt <Plug>(neopipe-line)
vmap ,t <Plug>(neopipe-visual)
```

If this is not desired simply include the following in your init.vim:

```vim
let g:neopipe_do_no_mappings=1
```

Summary
=======
