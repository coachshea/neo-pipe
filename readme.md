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
  * [npipe\_com](#npipe_com)
  * [npipe\_ft](#npipe_ft)
  * [Output Window](#output-window)
* [Projections](#projections)
* [Mappings](#mappings)
* [Summary](#summary)

<!-- vim-markdown-toc -->


[projectionist]: https://github.com/tpope/vim-projectionist

Introduction
============

The purpose of this plugin is to allow the user to send text through an
external command and display the output in a scratch buffer. Mappings are
defined which can take an operator, work on a visual selection, or work on a
line. This allows you to work in an ordinary vim buffer and use it as a repl,
make changes to a database, etc.

Dependencies
============

This plugin has no dependencies, but can work with tpope's [projectionist]
plugin.

Setup
=====

Neopipe has two variables that can be defined at the buffer or global level,
or as part of a projection from tpope's [projectionist] plugin. The variables
are: npipe\_com and npipe\_ft.

npipe\_start
----------------

This is the command that will be run on the first invocation (per buffer)
of the pipe comman. This can be as simple as a shell (i.e. "sh", "bash",
"zsh", etc.) which all subsesquent invocations will be run through. Or,
it could start a long running program that will be used to interpret all
further commands (i.e. "mongo", "sqlite3", "node", etc). Whatever the value
of npipe\_start, that value will be passed to the jobstart() function. All
subsequent commands will be sent to this command through the jobsend()
function. The default value for this command is the value of &shell. As with
all NeoPipe variables, this can be set at the buffer or global levels, or set
through a [projection](#projections).

```vim
let g:npipe_start = 'zsh'
au filetype sql let b:npipe_start = 'sqlite3 ~/db/myDatabase.db'
```

npipe\_ft
-----------

This com simply sets the filetype of the output. For example, if we are
pumping text through a mongodb database, we would likely want the output to be
have json syntax highlighting.

```javascript
{
  "name": "john"
}
```

Output Window
-------------

By default, the output window will be shown in a vertically split window. The
can be changed by setting the npipe\_split option. As with all options, this can
be set on the buffer or global levels, or through a projection. The option can
be either 'new', 'vnew' (default), or 'tabnew'. It's hard to imagine a use case
for 'tabnew', but it is available.

```vim
let g:npipe_split = 'new'
au filetype vim let b:npipe_split = 'vnew'
```

It is also possible to specify a height or width by supplying a number to the
split or vsplit (respectively) command. The default value of "vnew" will split
the window equally.

```vim
let g:npipe_split = '40vnew'
au filetype coffee let b:npipe_split = '25new'
```

Projections
===========

As mentioned previously, this plugin has been specifically designed to integrate
smoothly with the [projectionist] plugin.

```Javascript
// compile livescript
"*.ls": {
  "npipe_com": "lsc -cbp",
  "npipe_ft": "javascript",
  "npipe_split": "30new"
}

//compile pug to html
"templates/*.pug": {
  "npipe_com": "pug",
  "npipe_ft": "html"
}

// compile pug to javascript
"src/*.pug": {
  "npipe_com": "pug -c",
  "npipe_ft": "javascript"
}

// connect to a mongodb instance with livescript
"*.mongo": {
  "npipe_com": "lsc -cpb",
  "npipe_ft": "javascript",
  "npipe_split": "50vnew"
}

// view assembly for c files
"*.c": {
  "npipe_com": "gcc -S -xc -c -o - -",
  "npipe_ft": "asm"
}
```

Mappings
========

This plugin provides the following mappings:

```vim
<Plug>(npipe-operator)
<Plug>(npipe-line)
<Plug>(npipe-close)
<Plug>(npipe-visual)
```

As expected, the "operator" mapping leaves the user in operator-pending mode
and sends the results of the operator to neopipe\_com. The "visual" mapping
sends the viusally selected text, and the "line" mapping send the current
line. By default these will be mapped to:

```vim
nmap ,t <Plug>(npipe-operator)
nmap ,tt <Plug>(npipe-line)
nmap ,tq <Plug>(npipe-close)
vmap ,t <Plug>(npipe-visual)
```

If this is not desired simply include the following in your init.vim:

```vim
let g:neopipe_do_no_mappings=1
```

Summary
=======
