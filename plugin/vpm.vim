" MIT License                                              {
"
" Copyright (c) 2018 Itamar Soares
"
" Permission  is  hereby  granted,  free  of  charge, to any
" person  obtaining  a  copy of this software and associated
" documentation  files  (the  "Software"),  to  deal  in the
" Software without restriction, including without limitation
" the   rights   to   use,  copy,  modify,  merge,  publish,
" distribute,   sublicense,   and/or   sell  copies  of  the
" Software,    and   to   permit   persons   to   whom   the
" Software     is    furnished    to    do    so,    subject
" to                      the                      following
" conditions:
"
" The  above  copyright  notice  and  this permission notice
" shall     be     included     in     all     copies     or
" substantial       portions      of      the      Software.
"
" THE   SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT  WARRANTY
" OF   ANY   KIND,   EXPRESS   OR   IMPLIED,  INCLUDING  BUT
" NOT       LIMITED      TO      THE      WARRANTIES      OF
" MERCHANTABILITY,  FITNESS  FOR  A  PARTICULAR  PURPOSE AND
" NONINFRINGEMENT.   IN   NO  EVENT  SHALL  THE  AUTHORS  OR
" COPYRIGHT   HOLDERS  BE  LIABLE  FOR  ANY  CLAIM,  DAMAGES
" OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
" OR  OTHERWISE,  ARISING  FROM,  OUT  OF  OR  IN CONNECTION
" WITH    THE    SOFTWARE    OR    THE    USE    OR    OTHER
" DEALINGS            IN            THE            SOFTWARE.
" }

if exists('g:__VPM_SCRIPT_LOADED__')
  finish
endif

let g:__VPM_SCRIPT_LOADED__  = 1

let g:vpm                    = {}
let g:vpm.parser             = {}
let g:vpm.term               = {}
let g:vpm.term.buf           = ''
let g:vpm.dir                = get(g: , 'vpm_dir'  , '.vim/vpm')
let g:vpm.view               = {}
let g:vpm.view.zoom          = {}
let g:vpm.view.lines         = {}
let g:vpm.view.lines.visible = 0
let g:vpm.curr               = {}
let g:vpm.curr.view          = {}
let g:vpm.menu               = {}

" Functions                     {

" Dict: "g:vpm"                 {

function! g:vpm.init()                        dict "{

  let g:vpm.wl     = []

  call self.curr.init()
  call self.view.init()
  " call self.menu.init()

endfunction
" }
function! g:vpm.null()                        dict "{
  return ''
endfunction
"}
function! g:vpm.createbuffers()               dict "{

  let wlen = len(self.wl)
  for w in range(wlen)

    let tlen = len(self.wl[w].tl)

    let self.wl[w].last = self.wl[w].last % tlen

    for t in range(tlen)

      let blen = len(self.wl[w].tl[t].bl)

      let self.wl[w].tl[t].last = self.wl[w].tl[t].last % blen

      for b in range(blen)

        if has_key(self.wl[w].tl[t].bl[b],'type')

          if self.wl[w].tl[t].bl[b].type == 'term'


            let name = get(g:vpm.wl[w].tl[t].bl[b],'name','Term')
            let cwd  = get(g:vpm.wl[w].tl[t].bl[b],'cwd' ,'.')
            let cmd  = get(g:vpm.wl[w].tl[t].bl[b],'cmd' ,'/bin/bash')

            exec 'edit term://'.cwd.'//'.cmd

            let g:vpm.wl[w].tl[t].bl[b] = {
            \
            \ 'name' : name,
            \ 'cwd'  : cwd,
            \ 'cmd'  : cmd,
            \ 'path' : bufname('%'),
            \
            \}

          else

            exec 'badd ' . self.wl[w].tl[t].bl[b].path

          endif
        endif

      endfor
    endfor
  endfor

endfunction
" }
function! g:vpm.destroybuffers(windex)        dict "{

  for tab in g:vpm.wl[a:windex].tl
    for buf in tab.bl
      if bufexists(buf.path)
        exec 'bdelete! ' . buf.path
      endif
    endfor
  endfor

  call self.term.kill()

  if self.view.zoom.enabled
    call self.view.zoom.disable()
    call self.view.zoom.enable()
  endif

endfunction
" }
function! g:vpm.loadlayout(layout)            dict "{

  let fpath = g:vpm.dir . '/layouts/' . a:layout

  let lines = readfile(fpath)

  let JSON = join(lines,'')

  " JSON and VimLang compatibility
  exec 'let workspace = '.JSON

  " If Layout is Loaded, delete old Workspace
  " Structure and Reload

  let foundworkspace = 0

  for windex in range(len(g:vpm.wl))

    if workspace.name == g:vpm.wl[windex].name

      call self.destroybuffers(windex)
      let g:vpm.wl[windex] = workspace
      let foundworkspace = 1

      break

    endif

  endfor

  if !foundworkspace
    call add(g:vpm.wl,workspace)
  endif

  " Create all the buffers
  call g:vpm.createbuffers()

  " Retrieve Last Position
  call g:vpm.curr.retrieve()

  " Edit Current Buffer
  call self.curr.edit()

  " Show Top and Bottom Lines
  call self.view.lines.show()

endfunction
"}
function! g:vpm.savelayout()                  dict "{

  echo 'Saving to be Developed'

endfunction
"}
function! g:vpm.cycle(step,what)              dict "{

  " Cycle Whatever
  call self.curr.cycle(a:step,a:what)

  " Edit Buffer of New Position
  call  self.curr.edit()

endfunction
" }

" }
" Dict: "g:vpm.parser"          {

function! g:vpm.parser.list()           dict "{
  let workspaces = self.splitwksp()


endfunction
" }
function! g:vpm.parser.splitwksp()      dict "{

  let file = readfile('../menu.vpm')
  let c = 0
  let workspaces = ''

  for line in file
    let workspaces .= line."\n"
  endfor

  return split(workspaces,"workspace")

endfunction
" }
function! g:vpm.parser.splittabs()      dict "{
endfunction
" }
function! g:vpm.parser.splitbufs()      dict "{
endfunction
" }

" }
" Dict: "g:vpm.term"            {

function! g:vpm.term.make()             dict "{

  if !bufexists(self.buf)

    exec 'buffer|terminal'
    let self.buf = bufname('%')

  endif

endfunction
" }
function! g:vpm.term.kill()             dict "{

  if bufexists(self.buf)

    exec 'bdelete! ' . self.buf

    let self.buf = ''

  endif

endfunction
" }
function! g:vpm.term.edit()             dict "{

  call self.make()

  exec 'edit! ' . self.buf

endfunction
" }

" }
" Dict: "g:vpm.menu"            {

function! g:vpm.menu.init() dict         "{

  let self.struct = []

  let self.buf = g:vpm.dir . '/' . '__VPM_MENU__'

  exec 'badd '. self.buf
  
endfunction

" }
function! g:vpm.menu.make() dict         "{

  " Loop over all buffers {
  "
  "     │ ─ ━ ┃
  "
  "
  "     ┌ ┍ ┎ ┏ ▛
  "
  "     ┐ ┑ ┒ ┓
  "
  "     └ ┕ ┖ ┗
  "
  "     ┘ ┙ ┚ ┛
  "
  "     ├ ┝ ┠ ┣
  "
  "     ┤ ┥ ┨ ┫
  "     ┬ ┯ ┰ ┳
  "
  "     ┴ ┷ ┸  ┻
  "
  "     ┼ ┿ ╂ ╋
  "
  " ▀ ▄ █   ░ ▒ ▓ ■ □ ▢ ▣ ▤ ▥ ▦ ▧ ▨ ▩ ▪ ▬ ▭
  "
  "  ▐▌
  "
  " ▲ △ ▶ ▷ ▼ ▽ ◀ ◁
  "
  " ➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤➤
  " Build self.struct string }

  let line = ''
  for wsp in g:vpm.wl
    let line = '- '. wsp.name . ':'
    call add(self.struct,line)
    for tab in wsp.tl
      let line = '  - '. tab.name . ':'
      call add(self.struct,line)
      for buf in tab.bl
        let line = '    - '. buf.name . '|' . buf.path 
        call add(self.struct,line)
      endfor
    endfor
  endfor

  call writefile(self.struct,self.buf,'S')

endfunction

" }
function! g:vpm.menu.edit() dict         "{

  call self.init()
  call self.make()

  exec 'edit! ' . g:vpm.menu.buf

endfunction

" }
function! g:vpm.menu.save() dict         "{

  call self.init()
  call self.make()

  call system('python convert.py '. self.buf)

endfunction

" }

" }
" Dict: "g:vpm.view"            {

function! g:vpm.view.init()             dict "{

  call self.zoom.init()

endfunction
" }

" }
" Dict: "g:vpm.view.zoom"       {

function! g:vpm.view.zoom.init()        dict "{

  let self.enabled = get(g: , 'vpm_zoom_enabled' , 0  )
  let self.height  = get(g: , 'vpm_zoom_height'  , 20 )
  let self.width   = get(g: , 'vpm_zoom_width'   , 80 )

  let self.l       = get(g: , 'vpm_zoom_l'       , 15 )
  let self.r       = get(g: , 'vpm_zoom_r'       , 0  )
  let self.t       = get(g: , 'vpm_zoom_t'       , 1  )
  let self.b       = get(g: , 'vpm_zoom_b'       , 4  )

  let self.lbuffer = g:vpm.dir . '/__VPM__ZOOM__L__'
  let self.bbuffer = g:vpm.dir . '/__VPM__ZOOM__B__'
  let self.tbuffer = g:vpm.dir . '/__VPM__ZOOM__T__'
  let self.rbuffer = g:vpm.dir . '/__VPM__ZOOM__R__'

  let self.height = self.height >= 20 ? 20 : self.height
  let self.width  = self.width  >= 80 ? 80 : self.width

endfunction
" }
function! g:vpm.view.zoom.highlight()   dict "{

  hi StatusLine   ctermfg=15 ctermbg=14 guifg='7c7c7c' guibg=bg gui=none
  hi StatusLineNC ctermfg=15 ctermbg=14 guifg=bg       guibg=bg gui=none
  hi LineNr       ctermfg=15 ctermbg=14 guibg=bg                gui=none

  hi SignColumn ctermfg=15 ctermbg=14 guibg=bg                  gui=none
  hi VertSplit  ctermfg=15 ctermbg=14 guifg=bg guibg=bg         gui=none
  hi NonText    ctermfg=15 ctermbg=14 guifg=bg                  gui=none

  hi TabLine     ctermfg=15 ctermbg=14 guifg='7c7c00'  guibg=bg gui=none
  hi TabLineFill ctermfg=15 ctermbg=14 guifg='7c7c00'  guibg=bg gui=none
  hi TabLineSell ctermfg=15 ctermbg=14 guifg='7c7c00'  guibg=bg gui=none

  hi TagbarHighlight guibg='#4c4c4c' gui=none
  hi Search guibg='#5c5c5c' guifg='#000000' gui=bold

endfunction
" }
function! g:vpm.view.zoom.enable()      dict "{


  exec 'silent! top split '. g:vpm.view.zoom.tbuffer
  let &l:statusline='%{g:vpm.null()}'
  silent! wincmd p

  exec 'silent! bot split '. g:vpm.view.zoom.bbuffer
  let &l:statusline='%{g:vpm.null()}'
  silent! wincmd p

  exec 'silent! vsplit'. g:vpm.view.zoom.lbuffer
  let &l:statusline='%{g:vpm.null()}'
  silent! wincmd p

  exec 'silent! rightbelow vsplit '. g:vpm.view.zoom.rbuffer
  let &l:statusline='%{g:vpm.null()}'
  silent! wincmd p

  silent! wincmd h
  exec 'vertical resize ' . self.l
  silent! wincmd p
  silent! wincmd j
  exec 'resize ' . self.b
  silent! wincmd p
  exec 'resize          ' . self.height
  exec 'vertical resize ' . self.width
  silent! wincmd k
  exec 'resize ' . self.t
  silent! wincmd p

  call self.highlight()

  let self.enabled = 1

endfunction
"}
function! g:vpm.view.zoom.disable()     dict "{

  only
  let self.enabled = 0

endfunction
"}
function! g:vpm.view.zoom.toggle()      dict "{

  if self.enabled
    call self.disable()
  else
    call self.enable()
  endif

  call g:vpm.curr.focus()

endfunction

" }

" }
" Dict: "g:vpm.view.lines"      {

function! g:vpm.view.lines.top()        dict "{
  let line  = ''
  let line .= '%#VPMW#'
  let line .= ' '
  let line .= g:vpm.curr.item('w').name
  let line .= ' '

  let currtab = g:vpm.curr.item('t')

  for tab in g:vpm.curr.list('t')
    
    if tab.name == currtab.name

      let line .= '%#VPMTabSel#'

    else

      let line .= '%#VPMTab#'

    endif

    let line .= ' '
    let line .= tab.name
    let line .= ' '

  endfor

  let line .= '%#VPMTabFill#'


  return line
endfunction
" }
function! g:vpm.view.lines.bot()        dict "{
  let line  = ''

  let currbuf = g:vpm.curr.item('b')

  let line .= '%#VPMT#'
  let line .= ' '
  let line .= g:vpm.curr.item('t').name
  let line .= ' '

  let currbuf = g:vpm.curr.item('b')

  for buf in g:vpm.curr.list('b')

    if buf.name == currbuf.name

      let line .= '%#VPMBufSel#'

    else

      let line .= '%#VPMBuf#'

    endif

    let line .= ' '
    let line .= buf.name
    let line .= ' '

  endfor

  let line .= '%#VPMbufFill#'

  return line
endfunction
" }
function! g:vpm.view.lines.show()       dict "{
  set tabline=%!g:vpm.view.lines.top()
  set statusline=%!g:vpm.view.lines.bot()

  hi VPMW       ctermfg=15 ctermbg=0    guifg='#ffffff' guibg='#000000' gui=none 
  hi VPMTab     ctermfg=15 ctermbg=none guifg='#ffffff' guibg='#1c1c1c' gui=none
  hi VPMTabSel  ctermfg=0  ctermbg=37   guifg='#ffffff' guibg='#5c5c5c' gui=none
  hi VPMTabFill            ctermbg=none guifg='#1c1c1c' guibg='#1c1c1c' gui=none

  hi VPMT       ctermfg=0  ctermbg=37   guifg='#ffffff' guibg='#000000' gui=none
  hi VPMBuf     ctermfg=15 ctermbg=none guifg='#ffffff' guibg='#1c1c1c' gui=none
  hi VPMBufSel  ctermfg=0  ctermbg=15   guifg='#ffffff' guibg='#5c5c5c' gui=none
  hi VPMBufFill            ctermbg=none guifg='#1c1c1c' guibg='#1c1c1c' gui=none

  let self.visible = 1

endfunction
" }
function! g:vpm.view.lines.hide()       dict "{

  set tabline=%!g:vpm.null()
  set statusline=%!g:vpm.null()

  let self.visible = 0

endfunction
" }
function! g:vpm.view.lines.toggle()     dict "{

  if self.visible
    call self.hide()
  else
    call self.show()
  endif

endfunction
" }

" }
" Dict: "g:vpm.curr"            {

function! g:vpm.curr.init()           dict "{

  let g:vpm.curr.w = 0
  let g:vpm.curr.t = 0
  let g:vpm.curr.b = 0

endfunction
" }
function! g:vpm.curr.retrieve()       dict "{

  let self.t = self.item('w').last
  let self.b = self.item('t').last

endfunction
" }
function! g:vpm.curr.close()          dict "{

  " Check Current Position
  " Close The Current Buffer
  " Jump to the Last Buffer
  " Update Structure

endfunction
" }
function! g:vpm.curr.cycle(step,what) dict "{

  if bufname('%') != self.item('b').path

    self.edit()

  else

    let self[a:what] += a:step
    let self[a:what]  = self[a:what] % self.len(a:what)

    " Update
    if a:what == 'b'

      " Update new current buffer position after cycling
      let g:vpm.wl[self.w].tl[self.t].last = self.b

    elseif a:what == 't'

      " Update new current tab position after cycling
      let g:vpm.wl[self.w].last = self.t

      " For the new tab, retrieve last buffer position
      let self.b = self.list('t')[self.t].last

    elseif a:what == 'w'

      " Update new current Workspace position after cycling
      let g:vpm.last = self.w

      " For the new Workspace, retrieve last tab and buf positions
      let self.t = g:vpm.wl[self.w].last
      let self.b = g:vpm.wl[self.w].tl[self.t].last

    endif

  endif


endfunction
" }
function! g:vpm.curr.edit()           dict "{

  exec ':edit ' . self.list('b')[self.b].path

endfunction
" }
function! g:vpm.curr.focus()          dict "{

  if bufname('%') != g:vpm.term.buf
    exec ':buffer ' . self.list('b')[self.b].path
  endif

endfunction
" }
function! g:vpm.curr.len(what)        dict "{

  return len(self.list(a:what))

endfunction
" }
function! g:vpm.curr.list(what)       dict "{

  if a:what == 'w'

    return g:vpm.wl

  elseif a:what == 't'

    return g:vpm.wl[self.w].tl

  elseif a:what == 'b'

    return g:vpm.wl[self.w].tl[self.t].bl

  endif

endfunction

" }
function! g:vpm.curr.item(what)       dict "{

  if a:what == 'w'

    return g:vpm.wl[self.w]

  elseif a:what == 't'

    return g:vpm.wl[self.w].tl[self.t]

  elseif a:what == 'b'

    return g:vpm.wl[self.w].tl[self.t].bl[self.b]

  endif

endfunction

" }

" }

" }
" Helpers                       {

function! VPMListWorkSpaces(a,l,p) "{

  let layouts = system("ls " . g:vpm.dir . '/layouts')

  "let layouts = "one\ntwo"

  return layouts

endfunction
" }
function! g:vpm.test() dict "{

  call g:vpm.parser.list()

endfunction
" }

" }
" Commands                      {

command!
\ -complete=custom,VPMListWorkSpaces
\ -nargs=1
\ VPMLoadLayout
\ silent! call g:vpm.loadlayout("<args>")

command!
\ -complete=custom,VPMListWorkSpaces
\ -nargs=0
\ VPMSaveLayout
\ silent! call g:vpm.savelayout()

command! -nargs=0 VPMBufNext silent! call g:vpm.cycle(+1,'b')
command! -nargs=0 VPMBufPrev silent! call g:vpm.cycle(-1,'b')
command! -nargs=0 VPMTabNext silent! call g:vpm.cycle(+1,'t')
command! -nargs=0 VPMTabPrev silent! call g:vpm.cycle(-1,'t')
command! -nargs=0 VPMWspNext silent! call g:vpm.cycle(+1,'w')
command! -nargs=0 VPMWspPrev silent! call g:vpm.cycle(-1,'w')

command! -nargs=0 VPMZoomToggle         call g:vpm.view.zoom.toggle()
command! -nargs=0 VPMTestFunc           call g:vpm.test()
command! -nargs=0 VPMTerminal   silent! call g:vpm.term.edit()
command! -nargs=0 VPMMenu       silent! call g:vpm.menu.edit()
command! -nargs=0 VPMMenuSave   call g:vpm.menu.save()

command! -nargs=0 VPMLinesShow   silent! call g:vpm.view.lines.show()
command! -nargs=0 VPMLinesHide   silent! call g:vpm.view.lines.hide()
command! -nargs=0 VPMLinesToggle silent! call g:vpm.view.lines.toggle()

" }
" Autocommands                  {

" Coming soon

" }

call g:vpm.init()
