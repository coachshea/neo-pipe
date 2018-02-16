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
[npipe_start]: #npipe_start

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

Neopipe allows users to interact in with their commands in one of two ways.
First, users can define a long running command through which all subsqquent test
will be piped through (defined as [npipe_start]). This can be as simple as a shell command or it could open
a database, a repl, or any other command that the user wants to keep running for
the duration of the session. Behind the scenes, this uses Neovim's jobstart
function.

The second option available to NeoPipe users is to define a command that will
take the text as stdin and which rights it's output to stdout. In
this case, the system command is used on each invocation of NeoPipe.

Whichever method the user chooses, the output of the command will be sent to a
scratch buffer.

npipe\_start
----------------

This is the command that will be run on the first invocation (per buffer)
of the pipe comman. This can be as simple as a shell (i.e. "sh", "bash",
"zsh", etc.) which all ensuing invocations will be run through. Or, it could
start a long running program that will be used to interpret all further
commands (i.e. "mongo", "sqlite3", "node", etc). Whatever the value of
npipe\_start, that value will be passed to the jobstart() function. All
ensuing commands will be sent to this command through the jobsend() function.
The default value for this command is the value of &shell. As with all NeoPipe
variables, this can be set at the buffer or global levels, or set through a
[projection](#projections).

```vim
let g:npipe_start = 'zsh'
au filetype sql let b:npipe_start = 'sqlite3 ~/db/myDatabase.db'
```

npipe\_com
----------

When NeoPipe users want to define a command that takes the chosen text through
it's stdin and pipes it's result to stdout, they simply define the npipe\_com
command.

**important note**

If neither npipe\_start nor npipe\_com are set, the text will simply be echoed
in the scracth buffer. It is unlikley that a great many use cases exist for
this behavior, save checking the functionality of user defined motions and
text-objects.

npipe\_ft
-----------

This command simply sets the filetype of the output. For example, if we are
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
split or vsplit (respectively) command. The default values of will split the
window equally.

```vim
let g:npipe_split = '40vnew'
au filetype coffee let b:npipe_split = '25new'
```

Projections
===========

As mentioned previously, this plugin has been specifically designed to integrate
smoothly with the [projectionist] plugin. If you are not familiar with
[projectionist], I stongly encourage you to give it a look. It allows for a
simple and clean method of assigning values on a per-project (or global) basis.
Using [projectionist] can save you from a lot of unneccessary autocommands
designed to handle per-project requirements.

```Javascript
// compile livescript
"*.ls": {
  "npipe_com": "lsc -cbp",
  "npipe_ft": "javascript",
  "npipe_split": "30new"
}

// connect to a sqlite3 db
"*.sql": {
  "npipe_start": "sqlite3 ~/mydb.db",
  "npipe_split": "new"
}

// compile pug to html
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
  "npipe_start": "lsc -cpb",
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
<Plug>(npipe-whole)
<Plug>(npipe-close)
<Plug>(npipe-visual)
```

As expected, the "operator" mapping leaves the user in operator-pending mode
and sends the results to neopipe\_com. The "line" mapping sends the current
line, the "whole" mapping send the entire file, and the "visual" mapping sends
the viusally selected text. By default these will be mapped to:

```vim
nmap ,t <Plug>(npipe-operator)
nmap ,tt <Plug>(npipe-line)
nmap ,tg <Plug>(npipe-whole)
nmap ,tq <Plug>(npipe-close)
vmap ,t <Plug>(npipe-visual)
```

If this is not desired simply include the following in your init.vim:

```vim
let g:neopipe_do_no_mappings=1
```

**important note about <Plug>(npipe-whole)**
In order to keep your cursor position, \<Plug>(npipe-whole) use the 'q' mark
(i.e. mq) before copying and piping the entire buffer. It then returns the
cursor with '`q'.



Summary
=======
