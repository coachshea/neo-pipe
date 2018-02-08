                     _   _ _____ ___  ____ ___ ____  _____ 
                    | \ | | ____/ _ \|  _ \_ _|  _ \| ____|
                    |  \| |  _|| | | | |_) | || |_) |  _|  
                    | |\  | |__| |_| |  __/| ||  __/| |___ 
                    |_| \_|_____\___/|_|  |___|_|   |_____|
                                                           

Table of Contents
=================


<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
* [Dependencies](#dependencies)
* [Setup](#setup)
  * [neopipe\_start](#neopipe_start)
  * [neopipe\_command](#neopipe_command)
  * [neopipe\_ft](#neopipe_ft)
* [Mappings](#mappings)
* [Summary](#summary)

<!-- vim-markdown-toc -->

[projectionsit]: https://github.com/tpope/vim-projectionist

Introduction
============

The purpsoe of this plugin is to allow the user to send text through an
external command and display the output in a scratch buffer. Mappings are
defined which can take an operator, work on a visual selection, or work on a
line.

Dependencies
============

This plugin has no depenencies, but can work with tpope's
[projectionist]
bleh
[projectionsit](https://github.com/tpope/vim-projectionist) plugin.

Setup
=====

Neopipe has three variables that can be defined at the buffer or global level,
or as part of a projection from tpope's
[projectionsit](https://github.com/tpope/vim-projectionist) plugin. The three
variables are: neopipe\_start, neopipe\_command, and neopipe\_ft.

neopipe\_start
--------------

This variable if optional and if not set, this step wil be skipped. Let's say,
for example, that we are woring on a mongo database. We could simply define
a command such as 'mongo db/clients' and pipe all of our text through that.
However, we also might want to run 'mongo' once and then run the rest of our
commands through a running instance of mongo.

neopipe\_command
----------------

neopipe\_ft
-----------

This command simply sets the filetype of the output. For example, if we are
pumping text through a mongodb database, we would likely want the output to be
have json syntax highlighting.

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
