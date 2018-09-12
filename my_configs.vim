set t_Co=256
set number
highlight LineNr ctermfg=142
set nowrapscan
set whichwrap=
set cursorline
set tags=tags;
set sessionoptions=blank,curdir,buffers,folds,help,options,tabpages,winsize
hi StatusLine ctermbg=darkgray ctermfg=black
set diffopt=filler,vertical
set complete=.,w,b,i
set foldlevel=99

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



nnoremap <C-N> :bnext<cr>
nnoremap <C-P> :bprevious<cr>



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
"autocmd BufWinEnter * call PreventBuffersInNERDTree()

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

nnoremap <Leader>pm :call ToFile("verbose map", "~/.vimtmp/vimmap")<CR>:e ~/.vimtmp/vimmap<CR>
nnoremap <Leader>pa :call ToFile("verbose autocmd", "~/.vimtmp/vimautocmd")<CR>:e ~/.vimtmp/vimautocmd<CR>
nnoremap <Leader>pj :call ToFile("verbose jumps", "~/.vimtmp/vimjump")<CR>:e ~/.vimtmp/vimjump<CR>
nnoremap <Leader>d "_d
vnoremap <Leader>d "_d

let g:cpp_source_ext = ['cpp', 'c', 'cc']
let g:cpp_header_ext = ['h', 'hpp', 'hh']
function! GetSwitchFileCommand()
    let fileexp = expand("%:e")
    let fileroot = expand("%:r")
    let word = expand("<cword>")
    let is_function = 0
    if index(g:cpp_source_ext, fileexp) >= 0
        let switchlist = g:cpp_header_ext
        let is_header_file = 0
    elseif index(g:cpp_header_ext, fileexp) >= 0
        let is_header_file = 1
        let switchlist = g:cpp_source_ext

        let line = getline(line('.'))
        let pat = word.'('
        let idx = match(line, pat)
        if idx >= 0
            let is_function = 1
        endif
    else
        return ""
    endif

    for ext in switchlist
        let filename = fileroot.'.'.ext
        try
            execute 'find '.filename
            if len(word) > 0 && !is_header_file
                call cursor(1, 1)
                call search(word)
            elseif is_function
                "let pat = word.'([^;]\{0,64})\s*{'
                let pat = word.'([^;]\{0,64})\(\s\|\n\|\r\)*{'
                call cursor(1, 1)
                call search(pat)
            endif
            return
        catch
        endtry
    endfor
    
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

    if idx != -1
        execute 'edit +'.linenum.' '.g:proj_path.filepath
    else
        execute 'find '.filepath
    endif

    " some vim has no effect with this jump statement occassionally 
    "execute ''.linenum
    
    "execute 'normal '.linenum.'gg'
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
    if idx != -1
        execute 'edit +'.linenum.' '.g:proj_path.filepath
    else
        execute 'find '.filepath
    endif

    " some vim has no effect with this jump statement occassionally 
    "execute ''.linenum
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

    if idx != -1
        execute 'edit +'.linenum.' '.g:proj_path.filepath
    else
        execute 'find '.filepath
    endif

    " some vim has no effect with this jump statement occassionally 
    "execute ''.linenum
    execute 'normal zz'
endfunction

nnoremap <Leader>gf :call ViewFileInPreviewWindow()<CR>
nnoremap <Leader>gg :call GoFileInPreviewWindow()<CR>
nnoremap gf :call GoFile()<CR>

" grep map
let g:grepprog = 'grep'
let g:grepop_default = '-nrIw'
let g:grepop = g:grepop_default

function! MyGrep(arg)
    let grcmd = '!grep '.g:grepop.' --exclude-dir=".svn" --exclude-dir=".git" --exclude=tags --exclude="session.vim"'
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
        let g:grepcmd = grcmd.pat.path.' >~/.vimtmp/grepres 2>&1' 
        silent! execute g:grepcmd
    elseif g:grepprog == 'git'
        let g:grepcmd = '!cd '.path.' && git grep -nIw '.pat.' >~/.vimtmp/grepres 2>&1'
        silent! execute g:grepcmd 
    else 
        echo "unknown grep program"
    endif


    redraw!
    call buftabline#update(0)

    edit! ~/.vimtmp/grepres

    if exists('g:proj_path')
        execute '%s+'.g:proj_path.'++'
        w
    endif

    " go to first line
    execute '1'
    let @/ = '\<'.arglist[0].'\>'

endfunction


command! -nargs=* -complete=dir Gr call MyGrep(<q-args>)

function! LookupRef()
    let word = expand('<cword>')

    execute 'call MyGrep("'.word.'")'
endfunction

nnoremap <F3> :call LookupRef()<CR>
nnoremap <Leader><Leader> :b#<CR>


let g:stat_file_ext = ['cpp', 'cc', 'c', 'h', 'hpp']
function! Statistics()
    if !g:save_session
        echo 'Statistics() must be used in a project where viminit has been run!'
        return
    endif

    "let excludedir = ['*/tmp3/*', '*/tmp2/*']
    let excludedir = []



    let filetypecmd = ' \( '
    for ext in g:stat_file_ext
        let filetypecmd = filetypecmd.'-name "*.'.ext.'" '
        if index(g:stat_file_ext, ext) != len(g:stat_file_ext) - 1
            let filetypecmd = filetypecmd.'-o '
        else
            let filetypecmd = filetypecmd.' \)'
        endif

    endfor

    let excludecmd = ''
    if (len(excludedir) > 0)
        let excludecmd = ' -and -not \( '
    endif
    for dir in excludedir
        let excludecmd = excludecmd.' -path "'.g:proj_path.dir.'" '
        if (index(excludedir, dir) != len(excludedir) - 1)
            let excludecmd = excludecmd.' -o '
        else
            let excludecmd = excludecmd.' \)'
        endif
    endfor

    let cmd = '!find '.g:proj_path. ' -type f '.filetypecmd.excludecmd.' | xargs wc -l | sort -r > ~/.vimtmp/tmp 2>&1'
    "let cmd = '!find '.g:proj_path. ' -type f '.filetypecmd.' | xargs wc -l   > ~/.vimtmp/tmp 2>&1'
    "echo cmd
    "let nouse = getchar()
    silent! execute cmd
    redraw!
    call buftabline#update(0)
    edit! ~/.vimtmp/tmp
    execute '%s+'.g:proj_path.'++'
    w

    let maxlinenr = line('$')
    let startline = maxlinenr < 50 ? maxlinenr : 50
    call cursor(startline, 1)
    let findlinenr = search('^\s*[0-9]\+ total$', 'b')
    "echo findlinenr

    let linecnt = 0
    let nr = 0
    while nr <=  findlinenr
        let line = getline(nr)
        let curcnt = matchstr(line, '[0-9]\+')
        let linecnt += str2nr(curcnt)
        
        let nr += 1
    endwhile


    " count number for files of each type
    let nr = findlinenr + 1
    let dict = {}
    let dictlines = {}
    while nr <= line('$')
        let line = getline(nr)
        let filetype = matchstr(line, '\.[a-zA-Z]\{1,3}$')
        let curcnt = matchstr(line, '[0-9]\+')
        "echo filetype
        "call getchar()
        if !has_key(dict, filetype)
            let dict[filetype] = 0
            let dictlines[filetype] = 0
        endif
        let dict[filetype] += 1
        let dictlines[filetype] += str2nr(curcnt)

        let nr += 1
    endwhile

    "echo linecnt
    execute (findlinenr + 1).',$yank'

    edit! ~/.vimtmp/report
    execute 'normal gg,dG'
    let headmsg = printf("Total files: %d\nTotal lines:%d\n", maxlinenr - findlinenr, linecnt)

    for [key, value] in items(dict)
        let headmsg = headmsg.printf("%-10s%-6d files, %-8d lines\n", key.':', value, dictlines[key])
    endfor
    " some vim has error with this
    "let headmsg = headmsg.printf("File lists:\n")
    let headmsg = headmsg.printf("File lists:\n%s", "")
    
    "echo headmsg
    0put=headmsg

    execute 'normal G' 
    execute 'normal p'
    execute '%s/^  //ge'
    execute 'normal gg'
    bd ~/.vimtmp/tmp
    w
    
    execute 'normal \<CR>'
    redraw!

endfunction

command! -nargs=* Stat call Statistics()
nnoremap <F12> :call  Statistics()<CR>




let g:project_file_ext = ['h', 'hpp', 'c', 'cpp', 'cc']
function! RenameSymbol(...)
    if !g:save_session
        echo 'RenameSymbol() must be used in a project where viminit has been run!'
        return
    endif
    
    if a:0 != 2 && a:0 != 3
        echoerr 'arguement number mismatch: a:0='.a:0
        return
    endif

    let org = a:1
    let rep = a:2
    let flag = 'gc' 
    if exists('a:3')
        let flag = 'ge'
    endif
    let g:grepop = '-nrwIl'
    call MyGrep(org)
    let g:grepop = g:grepop_default

    let linenr = 1
    let filelist = []
    while linenr <= line('$')
        let line = getline(linenr)
        if index(g:project_file_ext, fnamemodify(line, ':e')) == -1
            let linenr += 1
            continue
        endif
        
        call add(filelist, line)
        let linenr += 1
       
    endwhile


    let need_ask = exists('a:3') ? 0 : 1
    for filepath in filelist
        execute 'edit '.g:proj_path.filepath
        execute '%s/'.org.'/'.rep.'/'.flag

        if index(filelist, filepath) == len(filelist) - 1
            break
        endif

        let go_next_file = 1
        let exit_loop = 0
        while need_ask && !exit_loop
            let exit_loop = 1

            echo 'continue(y/n/a)?'
            let cmd = getchar()
            let cmd = nr2char(cmd)
            if cmd == 'a'
                let need_ask = 0
            elseif cmd == 'n'
                let go_next_file = 0
            elseif cmd == 'y'
                " do nothing
            else
                let exit_loop = 0
            endif

        endwhile

        if !go_next_file
            break
        endif
    endfor


endfunction

command! -nargs=* Rep call RenameSymbol(<f-args>)

" END my own maps



" my autocmd


" change statusline color for current buffer
autocmd BufEnter * hi StatusLine ctermbg=DarkCyan ctermfg=black
autocmd BufLeave * hi StatusLine ctermbg=DarkGray ctermfg=black

"autocmd BufWinEnter * normal zR


" this solve the bug that nerdtree shrinks after tagbar open, this bug only exists if BufWinEnter autocmd is defined 
"auto BufWinEnter * silent loadview

" END my autocmd



" For project settings
let g:proj_path = getcwd().'/'

if argc() == 1 && argv(0) == '.' 
    execute "silent! source proj.vim"
endif


" set path for gf, find, etc
execute 'set path=.,'.g:proj_path.'**,/usr/include/**,,'
"execute 'set path+=g:proj_path'
"execute 'set path+=**'

" setting for CtrlP
execute "silent! nnoremap <Leader>m :<c-u>CtrlP ".g:proj_path."<CR>"

if exists("g:save_session")

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


endif

" END For project settings


if !isdirectory($HOME.'/.vimtmp')
    call mkdir($HOME.'/.vimtmp', 'p')
endif
