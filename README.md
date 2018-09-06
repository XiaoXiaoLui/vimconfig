## installation
you'd better backup your previous .vimrc and .vim
mv ~/.vim ~/.vim-bak
mv ~/.vimrc ~/.vimrc-bak
and use this vim config
mv vimconfig/.vimrc ~/.vimrc
chmod +x vimconfig/viminit
mv vimconfig/viminit /usr/loca/bin  # or put to any path in $PATH
mv vimconfig ~/.vim

## get to start
use viminit to generate root path infomation for a code base
cd codebaserootpath
viminit  # proj.vim is generated under codebaserootpath

several functions base on codebaserootpath on proj.vim, you need to start with "vim ." to enable this functions.
Including:
1) always use codebaserootpath to recursively search file(find, gf,etc.)
2) auto save session on vim exit, and auto load session on vim enter.
3) lookup reference of a symbol in files whose path begin with codebaserootpath
4) ctrl-p use codebaserootpath as root directory


## commonly used maps
mode    key             function
n       ,pm             " view all maps
n       ,pa             " view all autocmds
n       ,nn             " nerdtree toggle
n       ,ta             " tagbar toggle
n       ,j              " switch between header and source files
n       ,1              " show first buffer in tabline, similar for ,2~,9
n       ,00             " show 10th buffer in tabline
n       ,01             " show 11th buffer in tabline, similar for ,02~,09
n       ,bd             " close current buffer without closing current window
n       <tab>           " show next buffer
n       <s-tab>         " show previous buffer
n       0               " ^
n       gf              " go to file under cursor, if the file ends with pattern ':[0-9]\+' also go to corresponding line.
n       ,gg             " similar to gf, but open in previous window
n       ,gf             " similar to ,gg, but cursor remains in current window
n       <F1>            " open vim help doc for word under cursor
n       <F2>            " highlight(search) word under cursor, or cancel highlight if already highlighted.
n       <F3>            " lookup reference of word under cursor
n       <c-l>           " same as <c-w>l
n       <c-j>           " same as <c-w>j
n       <c-k>           " same as <c-w>k
n       <c-h>           " same as <c-w>h

## plugins
all plugins are put under vimconfig/bunder
nerdtree
ctrlp
buftabline
tagbar


