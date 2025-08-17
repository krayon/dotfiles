" We no longer use custom vim it seems?
"" Set vim runtime path (needed since we're using our own binary)
"":set runtimepath=~/.vim,/usr/share/vim/vimfiles,/usr/share/vim/vim80,/usr/share/vim/vim74,/usr/share/vim/vim73,/usr/share/vim/vimfiles/after,~/.vim/after

" Setting background to dark
:set background=dark

" Set binary mode so vim won't auto append EOL etc
" http://stackoverflow.com/a/4631956
:set binary

" Set no EOL on new files by default
au BufNewFile * set noeol

" Set Tab stop, and shift width, to 4
":set tabstop=4
":set shiftwidth=4
":set expandtab

" Highlight the column after 'textwidth'
:set cc=+1

" Syntax highlighting
:syntax enable
:syntax on

" Don't create those pesky backup files (<FILE>~)
:set nobackup

" The mouse is NOT for vim
:set mouse=
:set ttymouse=

" 100% vi compatibility, ttymouse= screws up otherwise
":set compatible

" VIM, X11-clipboard is NOT for you asshole!
:set clipboard=

" It's important to know your history
:set history=10000

" Always have line numbers
:set number

" Always highlight on search
:set hlsearch

" English (/Australian) spelling, not 'merican
:set spelllang=en_au

" Read modeline's in files for formatting
:set modeline

" Tags filename
"   DEFaULT: tags=./tags,./TAGS,tags,TAGS
"   (excluding uppercase as BlogMess uses this)
:set tags=./tags,tags

" Folding
:set foldlevel=0
:set foldminlines=3

" rxvt-unicode (urxvt) supports 256 colours
":set t_Co=256
:set t_Co=64
":set t_Co=16

" Make 'set list' show tabs and some other chars look betterer
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

" Always show at least 2 lines above and below the cursor
:set scrolloff=2

"autocmd FileType c set omnifunc=ccomplete#Complete
filetype plugin on

" Make %% expand to the current file's parent directory
cabbr <expr> %% expand('%:h')

" Map <leader>gu to navigate to parent directory
nmap <leader>gu :e %%

" Show a lil' menu of function declarations when omni-completing
" (<C-x>, <C-o>)
" longest - ensures popup menu doesn't select the first completion item, but
" rather just inserts the longest common text of all matches
" preview - shows a preview window of function declarations
" (similar to what <C-w>, '}' would show (but that's full blown version))
"
" Preview window is special window, can be closed with:
"   <C-w>, 'z'
"   <C-w>, <C-z>
"   <C-w>, <C-w>, <C-w>, 'q'
"   :pc[lose][!]    Close any "Preview" window currently open.
"
" Can also show definition of current function in preview window using:
"   <C-w>, '}'
:set completeopt=longest,menuone,preview

" NOTE: echofunc plugin also shows function declaration in the status line.
"   ... To ensure it doesn't get clobbered, we set the statusline:
:set statusline+="%{EchoFuncGetStatusLine()}"

" Set my mapleader character
let mapleader=","

:let g:acp_behaviorKeywordCommand = "\<C-x>\<C-o>"

" Search for visually highlighted text
"   - press // in visual mode, will:
"     1. Yank highlighted ( 'y'           )
"     2. Initiate search  (  '/'          )
"     3. CTRL-R           (   '<C-R>'     )
"     4. Double-Quote     (        '"'    )
"         (CTRL-R " == PASTE YANKED)
"     5. Return           (         '<CR>')
vnoremap // y/<C-R>"<CR>

" Turn off highlight and paste mode from search on ENTER (in command mode)
:noremap <CR> :nohlsearch<CR>:set nopaste<CR>/<BS><CR>

" Map CTRL-[jkhl] to Window navigation (only L was used for redraw)
" ( :help index to see a complete list of default mappings )
" TODO: As of patch 8.1.1140 we can use winnr('l') to determine if there's a
" window to our right for this:
:nmap <expr> <C-l> winnr('#')>1 ? '<C-w>l' : ':redraw!<CR>'
:nmap        <C-j> winnr('#')>1 ? '<C-w>j'
:nmap        <C-k> winnr('#')>1 ? '<C-k>j'
:nmap        <C-h> winnr('#')>1 ? '<C-h>j'

" Mappings for opening file under cursor
"
" gf             == Open file under cursor in current window
" CTRL-w, f      == Open file in new horizontal split window
" CTRL-w, CTRL-f == Open file in new vertical   split window (defined below)
" CTRL-w, gf     == Open file in new tab

" Map CTRL-w,CTRL-f to open the file/path the cursor is currently on, in a new
" split (vertical) window
:noremap <C-w><C-f> <C-w>v<C-w>lgf

" Remap <Enter> to <C-y> when popup menu is visible (to select highlighted
" item) (in insert mode (_i_noremap))
" https://vim.fandom.com/wiki/Make_Vim_completion_popup_menu_work_just_like_in_an_IDE
:inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Remap <C-n> (in insert mode) to do a down arrow when popup menu is visible
" (to select highlighted item)
" https://vim.fandom.com/wiki/Make_Vim_completion_popup_menu_work_just_like_in_an_IDE
:inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

" Show help for my leader based shortcuts when you press ',?'
nmap <silent> <leader>? :map ,<CR>

" Toggle text wrapping mode
nmap <silent> <leader>w :set invwrap<CR>:set wrap?<CR>

" Command Map: w!! = Force writing through sudo
"     Thanks to: http://stackoverflow.com/a/7078429
cmap w!! %!sudo tee >/dev/null "%"

" Set up retabbing on a source file
"nmap <silent> <leader>rr :1,$retab<CR>

" cd to the directory containing the file in the buffer
nmap <silent> <leader>cd :lcd %:h<CR> 
   
" Make the directory that contains the file in the current buffer.
" This is useful when you edit a file in a directory that doesn't
" (yet) exist
nmap <silent> <leader>md :!mkdir -p %:p:h<CR>

" Map <leader>-p to do:
"   - "_d == delete visually selected stuff to underscore register (gone baby)
"   - P   == paste our register contents
"   - If you don't do this, when you paste the replaced text gets put in the
"     register
xnoremap <leader>p "_dP



hi StatusLine   ctermfg=Yellow ctermbg=Blue gui=bold term=bold cterm=bold guifg=Yellow guibg=Blue
hi StatusLineNC ctermfg=Yellow ctermbg=Blue gui=bold term=bold cterm=bold guifg=Yellow guibg=Blue
"""""""""" DOESN'T WORK :(

" " Status line - changes colors depending on insert mode
" " ( stolen from http://crshd.heroku.com/ who stole it from somewhere else :P )
" set noshowmode        " don't display mode, it's already in the status line
" set laststatus=2      " always show statusline
" hi StatusLine     guifg=#666666   guibg=#1b1b1b   gui=none
" hi StatusLineNC   guifg=#444444   guibg=#1b1b1b   gui=none
" function! InsertStatuslineColor(mode)
"   if a:mode == 'i'
"     hi statusline guifg=#DA4939   guibg=#1b1b1b   gui=none
"   elseif a:mode == 'r'
"     hi statusline guifg=#0b0b0b   guibg=#DA4939   gui=none
"   else
"     hi statusline guifg=#666666   guibg=#1b1b1b   gui=none
"   endif
" endfunction
" au InsertEnter * call InsertStatuslineColor(v:insertmode)
" au InsertLeave * hi statusline    guifg=#666666   guibg=#1b1b1b   gui=none
" " Status line {{{
"   set laststatus=2      " always show statusline
" 
"   " Generic Statusline {{{
"   function! SetStatus()
"     setl statusline+=
"           \%1*\ %f
"           \%H%M%R%W%7*\
"           \%2*\ %Y\ <<<\ %{&ff}%7*
"   endfunction
" 
"   function! SetRightStatus()
"     setl statusline+=
"           \%5*\ %{StatusFileencoding()}%7*\
"           \%5*\ %{StatusBuffersize()}%7*\
"           \%=%<%7*\
"           \%5*\ %{StatusWrapON()}
"           \%6*%{StatusWrapOFF()}\ %7*
"           \%5*\ %{StatusInvisiblesON()}
"           \%6*%{StatusInvisiblesOFF()}\ %7*
"           \%5*\ %{StatusExpandtabON()}
"           \%6*%{StatusExpandtabOFF()}\ %7*
"           \%5*\ w%{StatusTabstop()}\ %7*
"           \%3*\ %l,%c\ >>>\ %P
"           \\ 
"   endfunction " }}}
" 
"   " Update when leaving Buffer {{{
"   function! SetStatusLeaveBuffer()
"     setl statusline=""
"     call SetStatus()
"   endfunction
"   au BufLeave * call SetStatusLeaveBuffer() " }}}
" 
"   " Update when switching mode {{{
"   function! SetStatusInsertMode(mode)
"     setl statusline=%4*
"     if a:mode == 'i'
"       setl statusline+=[I]
"     elseif a:mode == 'r'
"       setl statusline+=[R]
"     elseif a:mode == 'normal'
"       setl statusline+=\ \ \ 
"     endif
"     call SetStatus()
"     call SetRightStatus()
"   endfunction
" 
"   au VimEnter     * call SetStatusInsertMode('normal')
"   au InsertEnter  * call SetStatusInsertMode(v:insertmode)
"   au InsertLeave  * call SetStatusInsertMode('normal')
"   au BufEnter     * call SetStatusInsertMode('normal') " }}}
" 
"   " Some Functions shamelessly ripped and modified from Cream
"   "fileencoding (three characters only) {{{
"   function! StatusFileencoding()
"     if &fileencoding == ""
"       if &encoding != ""
"         return &encoding
"       else
"         return " -- "
"       endif
"     else
"       return &fileencoding
"     endif
"   endfunc " }}}
"   " &expandtab {{{
"   function! StatusExpandtabON()
"     if &expandtab == 0
"       return "tabs"
"     else
"       return ""
"     endif
"   endfunction "
"   function! StatusExpandtabOFF()
"     if &expandtab == 0
"       return ""
"     else
"       return "tabs"
"     endif
"   endfunction " }}}
"   " tabstop and softtabstop {{{
"   function! StatusTabstop()
" 
"     " show by Vim option, not Cream global (modelines)
"     let str = "" . &tabstop
"     " show softtabstop or shiftwidth if not equal tabstop
"     if   (&softtabstop && (&softtabstop != &tabstop))
"     \ || (&shiftwidth  && (&shiftwidth  != &tabstop))
"       if &softtabstop
"         let str = str . ":sts" . &softtabstop
"       endif
"       if &shiftwidth != &tabstop
"         let str = str . ":sw" . &shiftwidth
"       endif
"     endif
"     return str
" 
"   endfunction " }}}
"   " Buffer Size {{{
"   function! StatusBuffersize()
"     let bufsize = line2byte(line("$") + 1) - 1
"     " prevent negative numbers (non-existant buffers)
"     if bufsize < 0
"       let bufsize = 0
"     endif
"     " add commas
"     let remain = bufsize
"     let bufsize = ""
"     while strlen(remain) > 3
"       let bufsize = "," . strpart(remain, strlen(remain) - 3) . bufsize
"       let remain = strpart(remain, 0, strlen(remain) - 3)
"     endwhile
"     let bufsize = remain . bufsize
"     " too bad we can't use "¿" (nr2char(1068)) :)
"     let char = "b"
"     return bufsize . char
"   endfunction " }}}
"   " Show Invisibles {{{
"   function! StatusInvisiblesON()
"     "if exists("g:LIST") && g:LIST == 1
"     if &list
"       return "$"
"     else
"       return ""
"     endif
"   endfunction
"   function! StatusInvisiblesOFF()
"     "if exists("g:LIST") && g:LIST == 1
"     if &list
"       return ""
"     else
"       return "$"
"     endif
"   endfunction " }}}
"   " Wrap Enabled {{{
"   function! StatusWrapON()
"     if &wrap
"       return "wrap"
"     else
"       return ""
"     endif
"   endfunction
"   function! StatusWrapOFF()
"     if &wrap
"       return ""
"     else
"       return "wrap"
"     endif
"   endfunction
"   " }}}
" " }}}






" Hex2Dec
" Usage: hover over some hex ( eg 0x20 ), now run:
" :call Hex2Dec()
" Result: Changes to decimal value ( eg 0x20 -> 32 )
function! Hex2Dec()
    let lstr = getline(".")
    let hexstr = matchstr(lstr, '0x[a-fA-F0-9]\+')
    while hexstr != ""
        let hexstr = hexstr + 0
        exe 's#0x[a-fA-F0-9]\+#'.hexstr."#"
        let lstr = substitute(lstr, '0x[a-fA-F0-9]\+', hexstr, "")
        let hexstr = matchstr(lstr, '0x[a-fA-F0-9]\+')
    endwhile
endfunction



" :setf[iletype] {filetype}			*:setf* *:setfiletype*
" 			Set the 'filetype' option to {filetype}, but only if
" 			not done yet in a sequence of (nested) autocommands.
" 			This is short for: >



""""""""""
" JSON files
""""""""""
" pretty-print JSON files
autocmd BufRead,BufNewFile *.json setfiletype json
" json.vim is here: http://www.vim.org/scripts/script.php?script_id=1945
autocmd Syntax json sou ~/.vim/syntax/json.vim
" json_reformat is part of yajl: http://lloyd.github.com/yajl/
autocmd FileType json setlocal equalprg=json_reformat
" NOTE: To run reformatter, select text and press '='
" NOTE: To run reformatter on whole file, use 'go=<ENTER>'



""""""""""
" iCal files
""""""""""
" pretty-print iCal files
autocmd BufRead,BufNewFile *.ics setfiletype icalendar

""""""""""
" diff preferences
""""""""""
if &diff "{
    " Show a line on your current cursor position
    set cursorline

    " ]c (next difference) and [c (prev difference) are too difficult to type
    " :P
    map ]] ]c
    map [[ [c

    " do == diff obtain (from other file to this one)
    " dp == diff put    (from this file to the other)
    " zo == open  folded text
    " zc == close folded text
endif "}



""""""""""
" Tag files
""""""""""
"autocmd BufRead,BufNewFile *.c,*.h setfiletype c
autocmd FileType c   setlocal tags+=~/.vim/tags/c
"autocmd BufRead,BufNewFile *.cpp,*.hpp setfiletype cpp
autocmd FileType cpp setlocal tags+=~/.vim/tags/cpp



" autocmd that will set up the w:created variable
:autocmd VimEnter * autocmd WinEnter * let w:created=1

" Consider this one, since WinEnter doesn't fire on the first window created
" when Vim launches.
" You'll need to set any options for the first window in your vimrc,
" or in an earlier VimEnter autocmd if you include this
:autocmd VimEnter * let w:created=1

" Example of how to use w:created in an autocmd to initialize a window-local option
"   autocmd WinEnter * if !exists('w:created') | setlocal nu | endif

if v:progname =~ "vimdiff" "{

" Don't do nuffin

else "} {

if v:progname =~ "DISABLED_DO_NOT_NEED_AS_WE_HAVE_CC" "{

:autocmd WinEnter * if !exists('w:created')             |
\    let w:m1=matchadd('Search',   '\%<81v.\%>77v', -1) |
\    let w:m2=matchadd('ErrorMsg', '\%>80v.\+'    , -1) |
\ endif

:autocmd BufWinEnter * if !exists('w:created')          |
\    let w:m1=matchadd('Search',   '\%<81v.\%>77v', -1) |
\    let w:m2=matchadd('ErrorMsg', '\%>80v.\+'    , -1) |
\ endif

" Highlighting can be disabled using:
"   :call matchdelete(w:m1)
"   :call matchdelete(w:m2)

endif " DISABLED_DO_NOT_NEED_AS_WE_HAVE_CC "}

endif "}

"PRETTY DAMN AWESOME... but hard to get used to :(
"":source ~/.vim/autoclose.vim

"FIXME: CAUSES GVIM TO FAIL FROM CLAWS :S
":source ~/.vim/showmarks.vim
":ShowMarksOn

" GUI Options
if has("gui_running") "{
    "set guioptions-=T
    "set guioptions+=e
    "set t_Co=256
    "set guitablabel=%M\ %t

    " Set the font
    "set guifont=Terminal\ 8
    "Droid Sans REPLACED?!
    "set guifont=Droid\ Sans\ Mono\ 10
    set guifont=Noto\ Mono\ 10
    "set guifont=Fira\ Code\ Regular\ 10

    " Have GUI based tabs (labelled "<MODIFIED STATUS CHAR> <TITLE>")
    set guioptions+=e
    set guitablabel=%M\ %t
endif "}

if (has('termguicolors') && &termguicolors) || has('gui_running') "{

    " Colour Schemes:
    "     darkblue
    "     desert
    "     koehler
    "     pablo
    "     slate

    " This colour scheme is nice...
    colorscheme evening

    " This is better
    colorscheme darkblue

    " This is light
    colorscheme morning

    colorscheme slate
endif "}

" Debug mapping by outputting to a file
" :redir! > /tmp/vim_maps.txt
" :silent verbose map
" :redir END
