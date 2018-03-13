
              #     # ####### ####### ######  ### ######  ####### 
              ##    # #       #     # #     #  #  #     # #       
              # #   # #       #     # #     #  #  #     # #       
              #  #  # #####   #     # ######   #  ######  #####   
              #   # # #       #     # #        #  #       #       
              #    ## #       #     # #        #  #       #       
              #     # ####### ####### #       ### #       ####### 
                                                                  
Table of Contents
=================

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
* [Dependencies](#dependencies)
* [Setup](#setup)
  * [npipe\_com](#npipe_com)
  * [npipe\_type](#npipe_type)
  * [npipe\_append](#npipe_append)
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
[related plugins]: https://github.com/kana/vim-textobj-user/wiki

Introduction
============

NeoPipe allows users to send text through an external command and display the
output in the output buffer. The ':NeoPipe' command takes a range of text (the
enter file by default) and pipes it through a user-defined command. NeoPipe
defines mappings which can take an operator, work on a visual selection, or
work on a line. This allows users to work in an ordinary vim buffer and use it
as a repl, make changes to a database, etc.

Dependencies
============

NeoPipe has no dependencies, but can work with tpope's [projectionist] plugin.
If you are not familiar with [projectionist], I strongly encourage you to
check it out. It excels at project-level configuration.

NeoPipe also provides an operator-pending mapping (see [mappings] sections)
which works well with [textobj-user] by kana and the [related plugins]. If
you are not yet familiar with these plugins, they are worth your time to check
them out.

Setup
=====

Neopipe allows users to interact with their commands in one of three ways.
First, users can define a long running command through which all subsequent
text will be piped. This can be as simple as opening a shell or it could
open a database, a repl, or any other command that the user wants to keep
running for the duration of the session. Behind the scenes, this uses Neovim's
'jobstart()' function.

The second option available to NeoPipe users is to define a command that takes
each batch of text through it's stdin and which rights it's output to stdout.
In this case, NeoPipe uses the 'system()' command on each invocation.

The third options is to echo the selected lines in the output buffer. This
feature could come in handy if a user was testing a user-defined motion or
text object and wanted to make sure that the plugin selected the correct text.

Whichever method the user chooses, the NeoPipe sends the output of the command
to the output buffer. Users posses the ability to define the filetype, split,
height/width, etc. of the output buffer.

Users have the ability to set options at the buffer, projection (see
[projectionist] by Tim Pope and the [projections] section of this document),
or global level. NeoPipe will search for the options in that order and apply
the first one that it finds. The examples that follow demonstrate setting
each option at the buffer and global level. For examples of setting options
in projections, see the [projections] section of this document. The following
are the available options that collectively determine the behavior of NeoPipe.
Technically, user do not need to set any of these options, but if none are
set, the text is simply echoed to the output buffer that will be opened in a
vertical split (evenly split) buffer with no filetype.

**Important Note**

Once NeoPipe finds a variable at any level, that variable is set at the window
level. This is important because it allows us to work with different buffers
and pipe the commands to a single output buffer. Let's say for example, that I
am working on a sql project and call ':NeoPipe'. Let's further say that this
command opens a sql database in the background for use with all subsequent
commands. I send a few commands to ':NeoPipe', then I switch to a new buffer
in the same window next to the output buffer and execute another ':NeoPipe'.
It would be jarring if another output buffer opened and a separate instance
of sql (sqlite, mysql, etc.) was started. What I would most likely want is
to send commands to the existing sql instance and see the output in the
existing output buffer. If, at any time, I desire to start fresh, I simply
call ':NeoPipeClose' and when I next call ':NeoPipe', I will be starting
fresh. If I need to keep two (or more) separate 'command buffer / output
buffer' combinations going at once, I can open them in separate tabs.

npipe\_com
----------

The npipe\_com command is the actual command through which the text will be
sent, either continuously running or through a series of one-offs.

```vim
let g:npipe_com = 'zsh'
au filetype sql let b:npipe_com = 'sqlite3 ~/db/myDatabase.db'
au fileytpe mongo let b:npipe_com = 'mongo'

" with b:npipe_type='s'
au fileytpe livescript let b:npipe_com = 'lsc -cb'
```

npipe\_type
-----------

NeoPipe's most fundamental option. This options tells NeoPipe if the command
is to be run once and all subsequent text will be piped through it's output
or if each invocation of NeoPipe will send the selected text through the
command. For continuously running a command set this option to 'c', to run the
command on each invocation, set it to 's'. If npipe\_type is not set or set to
anything else, it is treated as echoing and npipe\_com will be ignored. For
example

```vim
" run the command continuously
let g:npipe_type='c'

" run the command each time
au fileytpe coffe let b:npipe_type='s'

" echo the text in the scratch buffer
au filetype txt let b:npipe_type=0
```

**Important Note**

If both npipe\_com and npipe\_type are not set, NeoPipe will simply echo the
text in the scratch buffer. These two commands collectively determine the
principle behavior of this NeoPipe. It is certainly fine to leave either/both
unset if echoing is desired, but in most cases NeoPipe's true power comes from
the skillful utilization of these two options.

npipe\_append
-------------

This variable informs NeoPipe of whether to clear the buffer for each
invocation, or to append each subsequent write of the output buffer. The text
can be appended to the top or bottom of the buffer by setting this to 'top' or
'bottom' respectively. If npipe\_append in not set, or set to anything other
than 'top' or 'bottom', then the buffer is cleared and rewritten on each
invocation.

```vim
let g:npipe_type='bottom'
au filetype mongo let b:npipe_append='top'
au filetype javascript let b:npipe_append=0
```

**Important Note**

If a user always desired to clear the buffer on each invocation, then it is
simple enough not to set this variable at all. But remember, all variables are
searched at the buffer, then projection, then global levels. If somewhere up
the "food chain" this variable was set then it would affect all lower level
buffers until overwritten by a "closer" variable. Therefore, it is often a
good idea to be explicit. Because the actual value does not matter except for
being other than 'top' or 'bottom', users can set it to number 0, to an empty
string, or to anything that helps them remember the intent (i.e. 'clear',
'new', 'foobar', etc.)

npipe\_ft
-----------

The npipe\_ft command sets the filetype of the output buffer. For example, if we are
pumping text through a mongodb database, we would likely want the output to
have json syntax highlighting.

```javascript
{
  "name": "john"
}
```

npipe\_split
------------

The npipe\_split option is 'vnew' by default. Meaning, the output buffer will
be shown in a vertically and evenly split window. As with all options, this
can be set on the buffer, projection or global levels. The option can be
either 'new', 'vnew' (default), or 'tabnew'. It's hard to imagine a use case
for 'tabnew', but it is available.

```vim
let g:npipe_split = 'new'
au filetype vim let b:npipe_split = 'vnew'
```

It is also possible to specify a height or width by supplying a number to the
split or vsplit (respectively) command. By default Vim splits each window
equally. Below are examples of more explicit splitting behavior.

```vim
let g:npipe_split = '40vnew'
au filetype coffee let b:npipe_split = '25new'
```

User can set other options and commands on the window. Check the Vim
documentation for further details:

```vim
:h vsplit
:h split
:h ++opt
:h +cmd
```

Projections
===========

As mentioned previously, this plugin has been specifically designed to integrate
smoothly with the [projectionist] plugin. If you are not familiar with
[projectionist], I strongly encourage you to give it a look. It allows for a
simple and clean method of assigning values on a per-project (or global) basis.
Using [projectionist] can save you from a lot of unnecessary autocommands
designed to handle per-project requirements. The following examples could be
included in a '.projections.json' file in the root directory of a project.

```Javascript
// compile livescript
"*.ls": {
  "npipe_com": "lsc -cbp",
  "npipe_type": "s",
  "npipe_ft": "javascript",
  "npipe_split": "30new",
  "npipe_append": "bottom"
}

//connect to a mongodb database
"*.mongo": {
  "npipe_start": "mongo",
  "npipe_type": "c",
  "npipe_ft": "javascript",
  "npipe_append": "top"
}

// connect to a sqlite3 db
"*.sql": {
  "npipe_start": "sqlite3 ~/mydb.db",
  "npipe_type": "c",
  "npipe_split": "new",
  "npipe_append": 0
}

// compile pug to html
"templates/*.pug": {
  "npipe_com": "pug",
  "npipe_type": "s",
  "npipe_ft": "html",
  "npipe_append": 0
}

// compile pug to javascript
"src/*.pug": {
  "npipe_com": "pug -c",
  "npipe_type": "s",
  "npipe_ft": "javascript",
  "npipe_append": 0
}

// connect to a mongodb instance with livescript
"*.mongo.ls": {
  "npipe_com": "lsc -cpb | mongo",
  "npipe_type": "s",
  "npipe_ft": "javascript",
  "npipe_split": "50vnew",
  "npipe_append": "bottom"
}

// view assembly for c files
"*.c": {
  "npipe_com": "gcc -S -xc -c -o - -",
  "npipe_type": "s",
  "npipe_ft": "asm",
  "npipe_append": "top"
}
```

Commands
========

The most basic command that NeoPipe provides is the ':NeoPipe' command. This is
the command that sends text from the current buffer to the output buffer. If the
output buffer is not yet created, it will automatically create it, and if the
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

" current line to bottom of the file
:.,$NeoPipe
```

NeoPipe provides two additional commands - ':NeoPipeClear' and ':NeoPipeClose'.
':NeoPipeClear', as the name implies, clears the output buffer. This is only
useful if 'npipe\_append' is one of 'top' or 'bottom', otherwise it is done on
every invocation of ':NeoPipe' anyway. ':NeoPipeClose' closes the output buffer
and if npipe\_type is 'c', it will cancel the command. Any invocation of NeoPipe
following ':NeoPipeClose' will be run from scratch.

```vim
" clear the output buffer
:NeoPipeClear

" close the output buffer
:NeoPipeClose
```

Mappings
========

NeoPipe privies a 'Plug' mapping which allows users to attach the NeoPipe
command to an operator-pending action. This allows us to very quickly send
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

" clear output buffer
nmap ,tc :NeoPipeClear

" close output buffer
nmap ,tq :NeoPipeClose

" visual selection
" would actually run as :'<,'>NeoPipe
vmap ,t :NeoPipe<cr>
```

If this is not desired simply include the following in your init.vim

```vim
let g:neopipe_do_no_mappings=1
```

Mapping Repeatability
---------------------

The operator-pending mapping and the 'current line' mapping (as defined above)
are naturally repeatable, no external plugins are required because they work
with Vim's natural motions. The other commands are not. A great deal of thought
went into this, but the rationale is as follows: it is perfectly understandable
that a user might be working with a pre-existing file and chose to move around
and send various lines/ranges to the ':NeoPipe' command. However, it is doubtful
that a user would want to send an entire file to the command twice without some
modifications in between (what would be the point). It is equally doubtful that
anyone would need to clear or close a buffer twice without intervening events.
Therefore, the two mappings that have the most (and possibly only) utility for a
repeat action are the two that are repeatable.

Worth noting, the operator-pending mode will, of course, work with any text
object, including user-defined text-objects. The [textobj-user] and [related
plugins] provide many useful text-objects combine nicely with NeoPipe's
operator mapping. If, for example, a user is looking for repeatability
for the entire file (still not sure what the use would be), I suggest the
[textobj-entire] plugin also by kana. There are many other useful user-defined
text-objects available within that ecosystem. If you are not familiar with
it, I encourage you to check out the [textobj-user] plugin and the [related
plugins] page. Even if not for repeatability, the plugins can be a great
benefit.

<!-- Summary -->
<!-- ======= -->
