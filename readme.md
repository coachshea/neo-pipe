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
  * [npipe\_type](#npipe_type)
  * [npipe\_append](#npipe_append)
  * [npipe\_com](#npipe_com)
  * [npipe\_ft](#npipe_ft)
  * [npipe\_split](#npipe_split)
* [Projections](#projections)
* [Commands](#commands)
* [Mappings](#mappings)
  * [Default Mappings](#default-mappings)
  * [Mapping Repeatability](#mapping-repeatability)

<!-- vim-markdown-toc -->

[projectionist]: https://github.com/tpope/vim-projectionist
[npipe_start]: #npipe_start
[npipe_com]: #npipe_com
[npipe_ft]: #npipe_ft
[mappings]: #mappings
[projections]: #projections
[textobj-user]: https://github.com/kana/vim-textobj-user
[textobj-entire]: https://github.com/kana/vim-textobj-entire

Introduction
============

The purpose of this plugin is to allow the user to send text through an
external command and display the output in a scratch buffer. Mappings are
defined which can take an operator, work on a visual selection, or work on a
line. This allows you to work in an ordinary vim buffer and use it as a repl,
make changes to a database, etc.

Dependencies
============

NeoPipe has no dependencies, but can work with tpope's [projectionist] plugin.
If you are not familiar with [projectionist], I strongly encourage you to
check it out. It excels at project-level configuration. NeoPipe also provides
an operator-pending mapping (see [mappings] sections) which works well with
[textobj-user] by kana and all of the related plugins.

Setup
=====

Neopipe allows users to interact with their commands in one of three ways.
First, users can define a long running command through which all subsqquent
text will be piped (defined as [npipe_start]). This can be as simple as
opening a shell command or it could open a database, a repl, or any other
command that the user wants to keep running for the duration of the session.
Behind the scenes, this uses Neovim's jobstart function.

The second option available to NeoPipe users is to define a command that will
take the text as stdin and which rights it's output to stdout. In
this case, the system command is used on each invocation of NeoPipe.

The third options is to simply echo the selected lines in the scratch buffer.
This feature could come in handy if a user was testing a userdefined motion or
text object and wanted to make sure that they correct text was being selected.

Whichever method the user chooses, the output of the command will be sent to a
scratch buffer.

All variables can be set at the buffer, projection (see [projectionist] by Tim
Pope and the [projections] section of this document), or global level. NeoPipe
will search for the variables in that order and apply the first one that it
finds. The examples that follow demonstrate setting each variable at the
buffer and global level. For examples of setting variables in projections, see
the [projections] section of this document. The following are the available
variables that collectively determine the behavior of NeoPipe.

npipe\_type
-----------

NeoPipe's most fundamental command. This variable tells NeoPipe if the command
is to be run once and all subsequent text will be piped through it's output or
if each invocation of NeoPipe will send the selected text through the command.
For example

**Important Note**

If type is not set, NeoPipe will ignore npipe\_com and simply send the text to
the scracth buffer verbatim.

```vim
let g:npipe_type='c'
au fileytpe coffe let b:npipe_type='s'
au filetype txt let b:npipe_type=0
```

npipe\_append
-------------

This variable informs NeoPipe of whether to clear the buffer for each
invocation, or to appand each subsequent write of the scratch buffer. The text
can be appended to the top or bottom of the buffer by seeting this to 'top' or
'bottom' respectively.

```vim
let g:npipe_type='bottom'
au filetype mongo let b:npipe_type='top'
au filetype javascript let b:npipe_type=0
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

```vim
let g:npipe_com = 'zsh'
au filetype sql let b:npipe_com = 'sqlite3 ~/db/myDatabase.db'
au fileytpe mongo let b:npipe_com = 'mongo'

" with b:npipe_type='s'
au fileytpe livescript let b:npipe_com = 'lsc -cb'
```

npipe\_ft
-----------

This command simply sets the filetype of the output. For example, if we are
pumping text through a mongodb database, we would likely want the output to
have json syntax highlighting.

```javascript
{
  "name": "john"
}
```

npipe\_split
------------

By default, the scratch buffer will be shown in a vertically split window. The
npipe\_split option. As with all options, this can be set on the buffer or
global levels, or through a projection. The option can be either 'new', 'vnew'
(default), or 'tabnew'. It's hard to imagine a use case for 'tabnew', but it
is available.

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
designed to handle per-project requirements. The follwoing examples could be
included in a '.projections.json' file in the root directory of a project.

```Javascript
// compile livescript
"*.ls": {
  "npipe_com": "lsc -cbp",
  "npipe_ft": "javascript",
  "npipe_split": "30new"
}

//connect to a mongodb database
"*.mongo": {
  "npipe_start": "mongo",
  "npipe_ft": "javascript"
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
"*.mongo.ls": {
  "npipe_com": "lsc -cpb | mongo",
  "npipe_ft": "javascript",
  "npipe_split": "50vnew"
}

// view assembly for c files
"*.c": {
  "npipe_com": "gcc -S -xc -c -o - -",
  "npipe_ft": "asm"
}
```

Commands
========

The most basic command that NeoPipe provides is the ':NeoPipe' command. This is
the command that sends text from the current buffer to a scratch buffer. If the
scratch buffer is not yet created, it will automatically create it, and if the
command type (i.e. npipe\_type) is 'c' (i.e. continuous), the ':NeoPipe' command
will take care of all of that for us.

```vim
" whole file
:NeoPipe

" current line
:.NeoPipe

" line 52
:52NeoPipe

" line range (13-26)
:13,26NeoPipe
```

NeoPipe provides two additional commands - ':NeoPipeClear' and ':NeoPipeClose'.
':NeoPipeClear', as the name implies, clears the scratch buffer. This is only
useful if 'npipe\_append' is one of 'top' or 'bottom', otherwise it is done on
every invocation of ':NeoPipe' anyway.

```vim
" clear the scratch buffer
:NeoPipeClear

" close the scratch buffer
:NeoPipeClose
```

Mappings
========

NeoPipe privies on 'Plug' mapping which allows users to attach the NeoPipe
command to an operator-pending action. This allows us to very quicly sned
arbitrary regions of text to the command.

```vim
<Plug>(npipe-operator)
```


**Important Note**

Neopipe is inherently a line-based command. Therefore when using an operator
pending action it is important to realize that while character-wise motions are
acceptable, any line that is touched by the motion or text object will be
included -- in full -- in the command. This is also true for visual mode. You
can perform a character-wise visual mode selection, but any line touch by the
selection is included in full.

Default Mappings
----------------

By defualt, NeoPipe provides the following convenience mappings:


```vim
" operator-pending
nmap ,t <Plug>(npipe-operator)

" current line
nmap ,tt <Plug>(npipe-operator)_

" whole file
nmap ,tg :NeoPipe<cr>

" clear scratch buffer
nmap ,tc :NeoPipeClear

" close scratch buffer
nmap ,tq :NeoPipeClose

" visual selection
vmap ,t :NeoPipe<cr>
```

If this is not desired simply include the following in your init.vim

```vim
let g:neopipe_do_no_mappings=1
```

Mapping Repeatability
---------------------

The operator-pending mapping and the 'current line' mapping (as defined above)
are naturally repeatable, no external plugins are requried because they work
with Vim's natural motions. The other commands are not. A great deal of thought
went into this, but the rationale is as follows: it is perfectly understandable
that a user might be working with a pre-existing file and chose to move around
and send various lines/ranges to the ':NeoPipe' command. However, it is doubtful
that a user would want to send an entire file to the command twice without some
modifications in between (what would be the point). It is equally doubtful that
anyone would need to clear or close a buffer twice without intervening events.
Therefore, the two mappings that have the most (and possibly only) utility for a
repeat motion are the two that are repeatable.

Worth noting, the operator-pending mode will, of course, work with any
text object, in including user-defined text-objects. The [textobj-user]
and related plugins provide many useful text-objects which can be combined
with the NeoPipe operator mapping. If a user is looking for repeatability
for the entire file (still not sure what the use would be), I suggest the
[textobj-entire] plugin also by kana.

<!-- Summary -->
<!-- ======= -->
