set t_Co=256
set number
set nowrapscan
set whichwrap=
set cursorline
set tags=tags;
set sessionoptions=blank,curdir,buffers,folds,help,options,tabpages,winsize
hi StatusLine ctermbg=darkgray ctermfg=black

function! GetHelp()
    let curword = expand('<cword>')
    return ":help ".curword."\<CR>"
endfunction
nnoremap <silent> <expr> <F1> GetHelp()


silent! unnoremap <space>
silent! unnoremap <c-space>


let g:highlighting = 0
function! Highlighting()
  if g:highlighting == 1 && @/ =~ '^\\<'.expand('<cword>').'\\>$'
    let g:highlighting = 0
    return ":silent nohlsearch\<CR>"
  endif
  let @/ = '\<'.expand('<cword>').'\>'
  execute "%s/".@/."//gn"
  let g:highlighting = 1
  return ":silent set hlsearch\<CR>"
endfunction
nnoremap <silent> <expr> <F2> Highlighting()



nnoremap <Tab> :bnext<cr>
nnoremap <S-Tab> :bprevious<cr>



" Specify the behavior when switching between buffers 
try
  set switchbuf=useopen,split
  set stal=1
catch
endtry


" NERDTree settings
let g:NERDTreeWinPos = "left"
let NERDTreeShowHidden=0
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let g:NERDTreeWinSize=35
noremap <leader>nn :NERDTreeToggle<cr>
noremap <leader>nb :NERDTreeFromBookmark<Space>
noremap <leader>nf :NERDTreeFind<cr>

silent! nnoremap go o <C-W>h  



function! InitNerdTreeOnVimEnter()
    if argc() == 1 && argv()[0] == '.' && !exists("s:std_in")
        NERDTree
        "if winnr() == winnr('$')
        "if len(getbufinfo({'buflisted':1})) == 0
        if !exists('g:proj_path') || !filereadable(g:proj_path.'session.vim')
            wincmd p
            enew
            wincmd p
        endif
    endif
endfunction

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * call InitNerdTreeOnVimEnter() 
"autocmd VimEnter * if argc() == 1 && argv()[0] == '.' && !exists("s:std_in") | NERDTree | wincmd p | ene | wincmd p | endif


autocmd FileType nerdtree let t:nerdtree_winnr = bufwinnr('%')
autocmd BufWinEnter * call PreventBuffersInNERDTree()

function! PreventBuffersInNERDTree()
  if bufname('#') =~ 'NERD_tree' && bufname('%') !~ 'NERD_tree'
    \ && exists('t:nerdtree_winnr') && bufwinnr('%') == t:nerdtree_winnr
    \ && &buftype == ''
    let bufnum = bufnr('%')
    silent! close
    exe 'b ' . bufnum
  endif
endfunction

" END NERDTree settings




" CtrlP settings

let g:ctrlp_working_path_mode = 0
let g:ctrlp_map = ''
"let g:ctrlp_map = '<c-p>'
noremap <leader>j :CtrlP<cr>

let g:ctrlp_max_height = 20
let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git\|^\.coffee'

"let g:ctrlp_show_hidden = 1

" END CtrlP Settings


" tagbar settings
let g:tagbar_width = 30

nnoremap <Leader>ta :TagbarToggle<CR>


" END tagbar settings


" vim-airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'

" END vim-airline setting


" vim-buftabline settings
"let g:buftabline_separators=1
let g:buftabline_indicators=1
let g:buftabline_numbers=2


nmap <leader>1 <Plug>BufTabLine.Go(1)
nmap <leader>2 <Plug>BufTabLine.Go(2)
nmap <leader>3 <Plug>BufTabLine.Go(3)
nmap <leader>4 <Plug>BufTabLine.Go(4)
nmap <leader>5 <Plug>BufTabLine.Go(5)
nmap <leader>6 <Plug>BufTabLine.Go(6)
nmap <leader>7 <Plug>BufTabLine.Go(7)
nmap <leader>8 <Plug>BufTabLine.Go(8)
nmap <leader>9 <Plug>BufTabLine.Go(9)
nmap <leader>00 <Plug>BufTabLine.Go(10)
nmap <leader>01 <Plug>BufTabLine.Go(11)
nmap <leader>02 <Plug>BufTabLine.Go(12)
nmap <leader>03 <Plug>BufTabLine.Go(13)
nmap <leader>04 <Plug>BufTabLine.Go(14)
nmap <leader>05 <Plug>BufTabLine.Go(15)
nmap <leader>06 <Plug>BufTabLine.Go(16)
nmap <leader>07 <Plug>BufTabLine.Go(17)
nmap <leader>08 <Plug>BufTabLine.Go(18)
nmap <leader>09 <Plug>BufTabLine.Go(19)

" END vim-buftabline settings


" my own maps


function! ToFile(cmd, file)
    execute "redir! >" . a:file
    execute "silent " . a:cmd
    redir END
endfunction

nnoremap <Leader>pm :call ToFile("verbose map", "~/vimmap")<CR>:e ~/vimmap<CR>
nnoremap <Leader>pa :call ToFile("verbose autocmd", "~/vimautocmd")<CR>:e ~/vimautocmd<CR>
nnoremap <Leader>pj :call ToFile("verbose jumps", "~/vimjump")<CR>:e ~/vimjump<CR>
nnoremap <Leader>d "_d
vnoremap <Leader>d "_d


function! GetSwitchFileCommand()
    let fileexp = expand("%:e")
    let fileroot = expand("%:r")
    if fileexp == 'cpp' || fileexp == 'c'
        let switchfile1 = fileroot.'.h' 
        let switchfile2 = fileroot.'.hpp' 
    elseif fileexp == 'h' || fileexp == 'hpp'
        let switchfile1 = fileroot.'.c'
        let switchfile2 = fileroot.'.cpp'
    else
        return ""
    endif


    try
        execute 'find '.switchfile1
        return 
    catch
    endtry

    try
        execute 'find '.switchfile2
        return
    catch
    endtry
    
endfunction

nnoremap <silent> <Leader>j :call GetSwitchFileCommand()<CR>


function! DoRegisterCommand()
    execute @"
endfunction

nnoremap <silent> <Leader>v :call DoRegisterCommand()

nnoremap <silent> <Leader>y ^y$

function! ViewFileInPreviewWindow()
    let filepath = expand("<cfile>")
    let line = getline('.')
    let pat = filepath.':[0-9]\+'
    silent! let matstr = matchstr(line, pat)
    let idx = match(matstr, ':[0-9]\+')
    let linenum = 1
    if idx != -1
        let idx = idx + 1
        " this has syntax error in vim with low version 
        "let linenum = matstr[idx:]
        
        execute 'let linenum = matstr['.idx.':]'
    endif

    wincmd p
    execute "find ".filepath
    execute "silent! normal zR"

    " some vim has no effect with this jump statement occassionally 
    "execute ''.linenum
    
    execute 'normal '.linenum.'gg'
    execute 'normal zz'
    wincmd p
endfunction

function! GoFileInPreviewWindow()
    let filepath = expand("<cfile>")
    let line = getline('.')
    let pat = filepath.':[0-9]\+'
    silent! let matstr = matchstr(line, pat)
    let idx = match(matstr, ':[0-9]\+')
    let linenum = 1
    if idx != -1
        let idx = idx + 1

        " this has syntax error in vim with low version 
        "let linenum = matstr[idx:]
        
        execute 'let linenum = matstr['.idx.':]'
    endif

    wincmd p
    execute "find ".filepath
    execute "silent! normal zR"

    " some vim has no effect with this jump statement occassionally 
    "execute ''.linenum
    
    execute 'normal '.linenum.'gg'
    execute 'normal zz'
endfunction

function! GoFile()
    let filepath = expand("<cfile>")
    let line = getline('.')
    let pat = filepath.':[0-9]\+'
    silent! let matstr = matchstr(line, pat)
    let idx = match(matstr, ':[0-9]\+')
    let linenum = 1
    if idx != -1
        let idx = idx + 1

        " this has syntax error in vim with low version 
        "let linenum = matstr[idx:]
        
        execute 'let linenum = matstr['.idx.':]'
    endif

    execute "find ".filepath
    execute "silent! normal zR"

    " some vim has no effect with this jump statement occassionally 
    "execute ''.linenum
    
    execute 'normal '.linenum.'gg'
    execute 'normal zz'
endfunction

nnoremap <Leader>gf :call ViewFileInPreviewWindow()<CR>
nnoremap <Leader>gg :call GoFileInPreviewWindow()<CR>
nnoremap gf :call GoFile()<CR>

" grep map
let g:grepprog = 'grep'
let g:grepop = '-nrIw'

function! MyGrep(arg)
    let grcmd = '!grep '.g:grepop.' --exclude-dir=".svn" --exclude-dir=".git" --exclude=tags '
    let gitcmd = '!git grep -nIw '
    let arglist = split(a:arg)
    let pat = get(arglist, 0)
    let path = get(arglist, 1)

    "let pat = '\b'.pat.'\b'
    let pat = ' "'.pat.'" '
    
    if len(arglist) < 2
        if exists("g:proj_path")
            let path = g:proj_path
        else
            let path = "./"
        endif
    endif
    
    if g:grepprog == 'grep'
        let g:grepcmd = grcmd.pat.path.' >~/.grepres 2>&1' 
        silent! execute g:grepcmd
    elseif g:grepprog == 'git'
        let g:grepcmd = '!cd '.path.' && git grep -nIw '.pat.' >~/.grepres 2>&1'
        silent! execute g:grepcmd 
    else 
        echo "unknown grep program"
    endif


    redraw!
    call buftabline#update(0)

    edit! ~/.grepres

    if exists('g:proj_path')
        execute '%s+'.g:proj_path.'++'
    endif
    let @/ = '\<'.arglist[0].'\>'

endfunction


command! -nargs=* -complete=dir Gr call MyGrep(<q-args>)

function! LookupRef()
    let word = expand('<cword>')

    execute 'call MyGrep("'.word.'")'
endfunction

nnoremap <F3> :call LookupRef()<CR>
nnoremap <Leader><Leader> :b#<CR>

" END my own maps



" my autocmd


" change statusline color for current buffer
autocmd BufEnter * hi StatusLine ctermbg=DarkCyan ctermfg=black
autocmd BufLeave * hi StatusLine ctermbg=DarkGray ctermfg=black

autocmd BufWinEnter * normal zR

" END my autocmd



" For project settings

if argc() == 1 && argv(0) == '.' 
    execute "silent! source proj.vim"
endif

if exists("g:proj_path")

    " Save session on quitting Vim
    autocmd VimLeave * NERDTreeClose
    autocmd VimLeave * TagbarClose
    autocmd VimLeave * execute "mksession! ".g:proj_path."session.vim"


    function! LoadSession()
        execute "silent! source session.vim" 
        execute "silent! bd ".g:proj_path[:-2]

        if  filereadable(g:proj_path."session.vim")
            execute "NERDTree ".g:proj_path
        endif
        "set background=dark
        "TagbarOpen
    endfunction

    " Load session on entering vim
    autocmd vimEnter * call LoadSession()

    " set path for gf, find, etc
    execute 'set path=.,/usr/include/**,'.g:proj_path.'**,,'

    " setting for CtrlP
    execute "silent! nnoremap <C-P> :<c-u>CtrlP ".g:proj_path."<CR>"

endif

" END For project settings
