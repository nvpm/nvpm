if exists('g:nvpm_loaded')
  finish
endif

let g:nvpm_loaded = v:true

" Dictionaries {

let g:nvpm = {}
let g:nvpm.temp = {}
let g:nvpm.save = {}
let g:nvpm.edit = {}
let g:nvpm.patt = {}
let g:nvpm.line = {}
let g:nvpm.dirs = {}
let g:nvpm.zoom = {}
let g:nvpm.term = {}
let g:nvpm.data = {}
let g:nvpm.data.make = {}
let g:nvpm.data.curr = {}

" }
" Functions    {

" g:nvpm      {

function! g:nvpm.init()                    "{

  call self.dirs.init()
  call self.patt.init()
  call self.line.init()
  call self.data.init()
  call self.temp.init()
  call self.edit.init()
  call self.term.init()
  call self.zoom.init()

  let self.nvpm_new_project_edit_mode = get(g:,'nvpm_new_project_edit_mode',0)
  let self.nvpm_load_new_project      = get(g:,'nvpm_load_new_project',1)
endfunction
"}
function! g:nvpm.test()                    "{
endfunction
"}
function! g:nvpm.deft()                    "{

  let root = self.dirs.path('root')

  let file = root . 'default'

  if filereadable(file)
    let project = readfile(file)[0]
    if Found(project)
      call self.data.load(project)
    endif
  endif

  return 1

endfunction
"}
function! g:nvpm.newp(name)                "{

  call self.dirs.make()

  let path = self.dirs.path('proj').a:name

  if FoundItem(path,self.dirs.list('proj'))
    echo 'NVPM: project ['.path.'] already exists.'
    echo '      Choose another name!'
    return
  endif

  let lines  = ['']
  let lines += ['# NVPM New Project File']
  let lines += ['# ---------------------']
  let lines += ['# ']
  let lines += ['# --> '.a:name]

  let projects = g:nvpm.dirs.list('projname')
  for project in projects
    let lines += ['#     '.project]
  endfor

  " let lines += ['# ']
  " let lines += ["# To apply differencies:"]
  " let lines += ['# ']
  " let lines += ["#   :NVPMLoadProject ".a:name]
  " let lines += ['# ']
  " let lines += ['# You may delete these comments']
  " let lines += ['# -----------------------------']

  let newdeft = '/tmp/.__nvpm__new__default'
  let lines += ['']
  let lines += ['workspace workspace_name'  ]
  let lines += ['  tab tab_name'            ]
  let lines += ['    buff '.newdeft.':'.newdeft]
  "let lines += ['    term Terminal: ']

  let save  = ['']
  let save += ["This is a default file. It was created automatically after :NVPMNewProject command. Its location is at ".newdeft." by default. Please call :NVPMEditProjects to start planing your own layout."]
  let save += ['']
  let save += ["In case you wanna start already in Edit mode, please put the following in your init.vim:"]
  let save += ['']
  let save += ['   let g:nvpm_new_project_edit_mode = 1']
  let save += ['']
  let save += ['For more information, see :help nvpm']

  call writefile(lines,path)
  call writefile(save,newdeft)

  if self.nvpm_new_project_edit_mode
    call self.data.load(a:name)
    call self.edit.proj()
  elseif self.nvpm_load_new_project
    call self.data.load(a:name)
  endif

endfunction
"}
function! g:nvpm.loop(s,t)                 "{

  if !g:nvpm.data.loaded
    if a:t == 'buffer'
      if a:s < 0
        :bprev
      else
        :bnext
      endif
    elseif a:t == 'tab'
      if a:s < 0
        :tabprevious
      else
        :tabnext
      endif
    endif
    return -1
  endif
  let step = v:count1 * a:s
  call self.data.curr.loop(step,a:t[0])
  call self.data.curr.edit()
endfunction
"}

"}
" g:nvpm.data {

" g:nvpm.data.*    {

function! g:nvpm.data.init()               "{
  let self.loaded = 0
  let self.last = 0
  let self.path = ''
  call self.curr.init()
endfunction
"}
function! g:nvpm.data.show()               "{

  for wksp in self.proj
    echo 'w' wksp.name
    for tab in wksp.tabs
      echo 't  ' tab.name
      for buffer in tab.buff
        if has_key(buffer,'path')
          echo 'b    ' buffer.name buffer.path
        else
          echo 'c    ' buffer.name buffer.cmd
        endif
      endfor
    endfor
  endfor

endfunction
"}

" misc }
" g:nvpm.data.load {

function! g:nvpm.data.load(file)           "{

  " Variables                       {
  let workspaces = []
  let patt       = g:nvpm.patt.wksp

  " Edit project files
  let g:nvpm.edit.mode = a:file == g:nvpm.edit.path
  let path = g:nvpm.edit.mode ? '' : g:nvpm.dirs.path('proj')
  let path = resolve(expand(path.a:file))

  if !filereadable(path)
    echo "NVPM: default project '".path."' is unreadable or missing"
    return -1
  endif
  "}
  " Look up in file                 {

  let file = readfile(path)
  if Found(file)

    let self.path  = path
    let self.file  = file

    for i in range(len(self.file))

      let line = self.file[i]

      " Ignore comments {
      if Found(matchstr(line,'^\s*\#.*'))
        continue
      endif
      " }

      let awkspmatch = matchlist(line,patt)

      if Found(awkspmatch)
        let workspace = self.wksp(awkspmatch,i)
        if workspace.enabled
          call add(workspaces,workspace)
        endif
      endif

    endfor
    let self.proj   = workspaces
    let self.loaded = Found(workspaces)

    " Make buffers and terminals
    call self.make.proj()
    " Update Last Position
    call self.curr.last()
    " Edit Current Buffer
    call self.curr.edit()
    " Show Top and Bottom Lines

    if g:nvpm.line.visible || !get(s:,'nvpm_data_loaded',0)
      call g:nvpm.line.show()
    endif

    let s:nvpm_data_loaded = 1

  endif
  "}

endfunction
" load }
function! g:nvpm.data.wksp(match,index)    "{

  " Capture workspace meta-data                 {
  let i                = a:index
  let workspace        = {}
  let workspace.tabs   = []
  let workspace.enabled = trim(a:match[1]) == '*' ? 0 : 1
  let workspace.name   = trim(a:match[2])
  let workspace.line   = self.file[i]
  let workspace.last   = 0
  "}
  " Look for tabs until workspace               {
  for j in range(i+1,len(self.file)-1)
    " Line matching {
    let line = self.file[j]
    let awkspmatch = matchlist(line,g:nvpm.patt.wksp)
    let atabmatch  = matchlist(line,g:nvpm.patt.tabs)
    "}

    if Found(awkspmatch)
      break
    elseif Found(atabmatch)
      let tab = self.tabs(atabmatch,j)
      if tab.enabled
        call add(workspace.tabs,tab)
      endif
    endif

  endfor
  "}

  return workspace

endfunction
"}
function! g:nvpm.data.tabs(match,index)    "{

  " Capture tab meta-data                 {

  let i           = a:index
  let tab         = {}
  let tab.buff    = []
  let tab.enabled = trim(a:match[1]) == '*' ? 0 : 1
  let tab.name    = trim(a:match[2])
  let tab.line    = self.file[i]
  let tab.last    = 0

  "}
  " Look for bufs until next tab          {
  for j in range(i+1,len(self.file)-1)
    " Line matching {
    let line = self.file[j]
    let atabmatch  = matchlist(line,g:nvpm.patt.tabs)
    let abuffmatch = matchlist(line,g:nvpm.patt.buff)
    let atermmatch = matchlist(line,g:nvpm.patt.term)
    "}

    if Found(atabmatch)
      break
    elseif Found(abuffmatch)
      let buff = self.buff(abuffmatch,j)
      if buff.enabled
        call add(tab.buff,buff)
      endif
    elseif Found(atermmatch)
      let term = self.term(atermmatch,j)
      if term.enabled
        call add(tab.buff,term)
      endif
    endif

  endfor
  "}

  return tab

endfunction
"}
function! g:nvpm.data.buff(match,index)    "{

  " Capture buff meta-data {

  let buff         = {}
  let buff.enabled = trim(a:match[1]) == '*' ? 0 : 1
  let buff.name    = trim(a:match[2])
  let buff.path    = resolve(expand(trim(a:match[3])))
  let buff.line    = self.file[a:index]
  let buff.last    = 0

  "}

  return buff

endfunction
"}
function! g:nvpm.data.term(match,index)    "{

  " Capture term meta-data {

  let term         = {}
  let term.enabled = trim(a:match[1]) == '*' ? 0 : 1
  let term.name    = trim(a:match[2])
  let term.cmd     = trim(a:match[3])
  let term.line    = self.file[a:index]
  let term.last    = 0

  "}

  return term

endfunction
"}

" load }
" g:nvpm.data.make {

function! g:nvpm.data.make.proj()          "{

  let proj = g:nvpm.data.proj
  let wlen = len(proj)
  let g:nvpm.data.last %= wlen

  for w in range(wlen) "{
    let tabs = proj[w].tabs
    let tlen = len(tabs)

    let proj[w].last %= tlen

    for t in range(tlen) "{
      let buff = tabs[t].buff
      let blen = len(buff)

      let tabs[t].last %= blen

      for b in range(blen) "{
        let buffer = buff[b]

        if     has_key(buffer,'cmd')
          let path = self.term(buffer)
          let buffer.path = path
        elseif has_key(buffer,'path')
          call self.buff(buffer)
        endif

      endfor
      "}
    endfor
    "}
  endfor
  "}

endfunction
"}
function! g:nvpm.data.make.buff(b)         "{
  "exec 'badd ' . a:b.path
endfunction
"}
function! g:nvpm.data.make.term(t)         "{

  let cmd = a:t.cmd

  if Found(cmd)
    exec 'edit term://.//'.cmd
  else
    exec 'buffer|terminal'
  endif

  return bufname('%')

endfunction
"}

" make }
" g:nvpm.data.curr {

function! g:nvpm.data.curr.init()          "{
  let self.w = 0
  let self.t = 0
  let self.b = 0
  let self.nvpm_maketree = get(g:,'nvpm_maketree',1)
  let self.nvpm_rmdir    = get(g:,'nvpm_rmdir',1)
  let self.dirname       = ''
endfunction
"}
function! g:nvpm.data.curr.edit()          "{
  exec ':edit ' . self.item('b').path
  let dir = g:nvpm.dirs.path('root')
  " TODO: make it more robust with fnamemodify(...,':h')
  if !empty(matchstr(self.item('b').path,escape(dir,'./'))) && &ft != 'nvpm'
    let &ft = 'nvpm'
  endif
  let isnotterm = match(self.item('b').path,'term\:\/\/') == -1
  if self.nvpm_maketree  &&
   \!empty(self.dirname) &&
   \!filereadable(self.dirname) &&
   \isnotterm
    call mkdir(self.dirname,'p')
  endif
endfunction
"}
function! g:nvpm.data.curr.leng(t)         "{
  return len(self.list(a:t))
endfunction
"}
function! g:nvpm.data.curr.list(t)         "{

  if     a:t == 'w'
    return g:nvpm.data.proj
  elseif a:t == 't'
    return self.list('w')[self.w].tabs
  elseif a:t == 'b'
    return self.list('t')[self.t].buff
  endif

endfunction
"}
function! g:nvpm.data.curr.item(t)         "{

  if     a:t == 'w'
    return self.list('w')[self.w]
  elseif a:t == 't'
    return self.item('w').tabs[self.t]
  elseif a:t == 'b'
    let path = self.item('t').buff[self.b].path
    let self.dirname = fnamemodify(path,':h')
    return self.item('t').buff[self.b]
  endif

endfunction
"}
function! g:nvpm.data.curr.loop(s,t)       "{

  if g:nvpm.data.loaded "{

    if bufname() != self.item('b').path "{
      call self.edit()
    else
      let type  = a:t
      let step  = a:s
      let self[type] += step
      let self[type]  = self[type] % self.leng(type)

      if     type == 'b' "{
        let g:nvpm.data.proj[self.w].tabs[self.t].last = self.b
      "}
      elseif type == 't' "{
        " Update new current tab position after cycling
        let g:nvpm.data.proj[self.w].last = self.t
        " For the new tab, retrieve last buffer position
        let self.b = self.item('t').last
      "}
      elseif type == 'w' "{
        " Update new current Workspace position after cycling
        let g:nvpm.data.last = self.w
        " Update tab and buf with last positions
        let self.t = self.item('w').last
        let self.b = self.item('t').last
      endif "}

    endif   "}

  " }
  else
    echo 'Load layout first!'
    return
  endif

endfunction
"}
function! g:nvpm.data.curr.last()          "{

  let self.t = self.item('w').last
  let self.b = self.item('t').last

endfunction
"}
function! g:nvpm.data.curr.term()          "{

  if bufname('%') != g:nvpm.term.buf
    exec ':buffer ' . self.item('b').path
  endif

endfunction
" focus }

" curr}

" data}
" g:nvpm.line {

function! g:nvpm.line.init() "{

  let botr = '%y%m ⬤ %l,%c/%P'
  let botc = ' ⬤ %f'
  let self.git = ''
  let self.visible      = 0
  let self.bottomcenter = get(g: , 'nvpm_line_bottomcenter'  , botc )
  let self.bottomright  = get(g: , 'nvpm_line_bottomright'   , botr )
  let self.closure      = get(g: , 'nvpm_line_closure'       , 1    )
  let self.innerspace   = get(g: , 'nvpm_line_innerspace'    , 0    )
  let self.projname     = get(g: , 'nvpm_line_show_projname' , 0    )
  let self.gitinfo      = get(g: , 'nvpm_line_git_info'      , 0    )
  let self.gitdelayms   = get(g: , 'nvpm_line_git_delayms'   , 2000 )
  let self.gittimer     = 0

endfunction "}
function! g:nvpm.line.topl() "{

  let line    = ''
  let space   = self.innerspace ? ' ' : ''
  let currtab = g:nvpm.data.curr.item('t')

  for tab in g:nvpm.data.curr.list('t')
    let iscurr = tab.name == currtab.name
    let line  .= '%#NVPMLineTabs'
    let line  .= iscurr ? 'Sel#' : '#'
    let line  .= self.closure && iscurr ? '['.space : ' '.space
    let line  .= tab.name
    let line  .= self.closure && iscurr ? space.']' : ' '.space
  endfor

  let line .= '%#NVPMLineTabsFill#'

  let currwksp = g:nvpm.data.curr.item('w')

  let i = 0
  let workspaces = g:nvpm.data.curr.list('w')
  let w = []
  for i in range(g:nvpm.data.curr.leng('w'))
    let wksp = workspaces[i]
    let iscurr = wksp.name == currwksp.name
    let l:right = ''
    let l:right .= '%#NVPMLineWksp'
    let l:right .= iscurr ? 'Sel#' : '#'
    let l:right .= self.closure && iscurr ? '['.space : ' '.space
    let l:right .= wksp.name
    let l:right .= self.closure && iscurr ? space.']' : ' '.space
    call add(w,l:right)
  endfor

  let line .= '%='
  let line .= join(reverse(w),'')

  let proj  = split(g:nvpm.data.path,g:nvpm.dirs.path('proj'))[0]
  let proj  = '%#NVPMLineProjSel#'.' '.proj.' '
  let line .= self.projname ? proj : ''

  return line

endfunction
" }
function! g:nvpm.line.botl() "{
  let space = self.innerspace ? ' ' : ''
  let line  = ''

  let currbuf = g:nvpm.data.curr.item('b')

  for buf in g:nvpm.data.curr.list('b')
    let iscurr = buf.name == currbuf.name
    let line  .= '%#NVPMLineBuff'
    let line  .= iscurr ? 'Sel#' : '#'
    let line  .= self.closure && iscurr ? '['.space : ' '.space
    let line  .= buf.name
    let line  .= self.closure && iscurr ? space.']' : ' '.space
  endfor

  let line .= self.git
  let line .= '%#NVPMLinebuffFill#'
  let line .= self.bottomcenter
  let line .= '%='
  let line .= self.bottomright

  return line

endfunction
" }
function! g:nvpm.line.show() "{

  if self.gitinfo && !self.gittimer
    let self.gittimer = timer_start(self.gitdelayms,
          \'NVPMGITTIMER',{'repeat':-1})
  endif

  " NOTE: Don't put spaces!
  set tabline=%!g:nvpm.line.topl()
  set statusline=%!g:nvpm.line.botl()

  let self.visible = 1

endfunction
" }
function! g:nvpm.line.hide() "{

  set tabline=%#Normal#
  set statusline=%#Normal#

  let self.visible = 0

endfunction
" }
function! g:nvpm.line.swap() "{

  if !g:nvpm.data.loaded|echo 'NVPM: load a project file first'|return|endif
  if self.visible
    call self.hide()
  else
    call self.show()
  endif

endfunction
" }
function! NVPMGITTIMER(timer) "{
  let info  = ''
  if g:nvpm.line.gitinfo && executable('git')
    let branch   = trim(system('git rev-parse --abbrev-ref HEAD'))
    if empty(branch)|return ''|endif
    let modified = !empty(trim(system('git diff HEAD --shortstat')))
    let staged   = !empty(trim(system('git diff --no-ext-diff --cached --shortstat')))
    let cr = ''
    let char = ''
    let s = ' '
    if empty(matchstr(branch,'fatal: not a git repository'))
      let cr   = '%#NVPMLineGitClean#'
      if modified
        let cr    = '%#NVPMLineGitModified#'
        let char  = ' [M]'
      endif
      if staged
        let cr   = '%#NVPMLineGitStaged#'
        let char = ' [S]'
      endif
      let info = cr .' ' . branch . char
    endif
  endif
  let g:nvpm.line.git = info
endfunction
" }
function! NVPMLINEFILENAME() "{
  let termpatt = 'term://.*'
  if !empty(matchstr(bufname(),termpatt))
    return 'terminal'
  endif
  if &filetype == 'help' && !filereadable('./'.bufname())
    return resolve(expand("%:t"))
  else
    return resolve(expand("%"))
  endif
endfunction
" }

" edit }
" g:nvpm.edit {

function! g:nvpm.edit.init()               "{

  let self.path = g:nvpm.dirs.path('temp').'proj'
  let self.mode = 0
  let self.currpath = ''
  let self.currname = ''

endfunction "}
function! g:nvpm.edit.proj()               "{

  if !g:nvpm.data.loaded
    echo 'Load project first [:NVPMLoadProject]'
    return -1
  endif

  if self.mode
    call g:nvpm.data.load(self.currname)
    call self.init()
    return
  endif

  " Save loaded project name  {

  let currpath = g:nvpm.data.path
  let self.currpath = g:nvpm.data.path
  let self.currname = matchlist(self.currpath,g:nvpm.patt.edit)
  let self.currname = [currpath,self.currname[1]][Found(self.currname)]

  " }
  " Create temporary project  {

  let projects = g:nvpm.dirs.list('proj')
  if DoesNotFind(projects)
    echo 'No project files were found.'
    return -1
  endif

  let currproj = matchstr(currpath,g:nvpm.patt.edit)

  let lines = []

  " Loop over projects
  for project in projects
    if project == currproj
      continue
    endif
    let name  = matchlist(project,g:nvpm.patt.edit)
    let name  = [project,name[1]][Found(name)]
    let buff  = 'buff '.name.':'.project
    let lines = add(lines,buff)
  endfor
  "let lines = add(lines,'tab Edit-Terminal')
  "let lines = add(lines,'term Terminal:bash')

  " Give priority to current loaded project
  if Found(currpath)
    let name  = matchlist(currpath,g:nvpm.patt.edit)
    let name  = [currpath,name[1]][Found(name)]
    let lines = ['buff * '.name.':'.currpath] + lines
  endif

  " Pre-append tab and workspace lines
  let lines = ['tab       Project Files'    ] + lines
  let lines = ['workspace NVPM Edit Projects'] + lines

  call writefile(lines,self.path)

  " }
  " Load  temporary  project  {

  call g:nvpm.data.curr.init()
  call g:nvpm.data.load(self.path)

  " }

endfunction "}

" edit }
" g:nvpm.temp {

function! g:nvpm.temp.init()               "{

  let patt       = g:nvpm.patt.temp
  let self.path  = matchstr(v:servername,patt)
  let self.path  = resolve(self.path)
  let self.path .= '/nvpm/'

  if !isdirectory(self.path)
    call mkdir(self.path,"p")
  endif

  return self.path

endfunction "}

" temp }
" g:nvpm.save {

function! g:nvpm.save.deft(p)              "{

  let proj = ''
  let dest = g:nvpm.dirs.path('root') . 'default'

  " Argument takes priority
  if Found(a:p)
    let proj = a:p
  else
    let path = g:nvpm.data.path
    if filewritable(path)
      " Split: get the filename. Look for better solution
      let proj = split(path,'/')[-1]
    endif
  endif

  if writefile([proj],dest) == 0
    echo "NVPM: Saved default projet [".proj."] at location. ".dest
  else
    echo "NVPM: Failed to save default projet [".proj."] at location. ".dest"
    echo "Location is missing or doesn't have write permition"
  endif

endfunction "}

" save }
" g:nvpm.dirs {

function! g:nvpm.dirs.init()  "{
  let self.nvpm = get( g: , 'nvpm_local_dir'  , '.nvpm'  )
  let self.main = get( g: , 'nvpm_main_dir' , '~/.nvpm' )
  let self.proj = 'proj'
endfunction "}
function! g:nvpm.dirs.make()  "{
  call mkdir(self.path('proj'),"p")
  call mkdir(self.path('temp'),"p")
endfunction "}
function! g:nvpm.dirs.path(t) "{
  if     a:t == 'proj'
    return self.nvpm . '/' . self.proj . '/'
  elseif a:t == 'root'
    return resolve(self.nvpm) . '/'
  elseif a:t == 'temp'
    return resolve(g:nvpm.temp.path) . '/'
  endif
  return ''
endfunction
"}
function! g:nvpm.dirs.list(t) "{

  if a:t == 'proj'
    let projpath = self.path('proj')
    let projects = glob(projpath.'*')
    let projects = split(projects,"\n")
    return projects
  elseif a:t == 'projname'

    let projects = self.list('proj')

    let projnames = []

    if Found(projects)
      for path in projects
        let name = matchlist(path,g:nvpm.patt.tail)
        if Found(name)
          call add(projnames,name[1])
        endif
      endfor
    endif

    return projnames

  endif

endfunction
"}

" init }
" g:nvpm.term {

function! g:nvpm.term.init() "{
  let self.buf  = ''
endfunction
" }
function! g:nvpm.term.make() "{

 if !bufexists(self.buf)

   exec 'buffer|terminal'
   let self.buf = bufname('%')

 endif

endfunction
" }
function! g:nvpm.term.kill() "{

 if bufexists(self.buf)

   exec 'bdelete! ' . self.buf

   let self.buf = ''

 endif

endfunction
" }
function! g:nvpm.term.edit() "{

  call self.make()
  exec 'edit! ' . self.buf

endfunction
" }

" }
" g:nvpm.patt {

function! g:nvpm.patt.init()               "{

  let s = '\s*'
  let a = '\(.*\)'
  let f = '\/'
  let w = '\(\w*\)'
  let sa = s.a
  let sas = sa.s
  let h = '\(\**\)'
  let shs = s.h.s
  let self.term = '^'.shs.'term'.sas.':'.sas.'$'
  let self.buff = '^'.shs.'buff'.sas.':'.sas.'$'
  let self.tabs = '^'.shs.'tab' . sa         .'$'
  let self.wksp = '^'.shs.'workspace' . sa   .'$'
  let self.temp = '^'.a.f.'nvim'.w
  let self.tail = '^\/*.*\/\(.*\)$'
  let self.edit = '^'.g:nvpm.dirs.path('proj')
  let self.edit = substitute(self.edit,'\/','\\/','g')
  let self.edit .= a.'$'

endfunction
"}
function! g:nvpm.patt.show()               "{

  echo 'term -' string(self.term)
  echo 'buff -' string(self.buff)
  echo 'tabs -' string(self.tabs)
  echo 'wksp -' string(self.wksp)
  echo 'edit -' string(self.edit)

endfunction
"}

" }
" g:nvpm.zoom {

function! g:nvpm.zoom.init() "{

  let self.enabled = 0
  let self.height  = 20
  let self.width   = 80
  let self.l       = 15
  let self.r       = 0
  let self.t       = 1
  let self.b       = 4

  let self.lbuffer = '/tmp/__NVPM__ZOOM__L__'
  let self.bbuffer = '/tmp/__NVPM__ZOOM__B__'
  let self.tbuffer = '/tmp/__NVPM__ZOOM__T__'
  let self.rbuffer = '/tmp/__NVPM__ZOOM__R__'

  let self.groups = {}

  "let self.height = self.height >= 20 ? 20 : self.height
  "let self.width  = self.width  >= 80 ? 80 : self.width

endfunction " }
function! g:nvpm.zoom.highlight() "{

  hi TabLine      ctermfg=none ctermbg=none guifg=none guibg=bg gui=none
  hi TabLineFill  ctermfg=none ctermbg=none guifg=none guibg=bg gui=none
  hi TabLineSell  ctermfg=none ctermbg=none guifg=none guibg=bg gui=none
  hi StatusLine   ctermfg=none ctermbg=none guifg=none guibg=bg gui=none
  hi StatusLineNC ctermfg=none ctermbg=none guifg=bg   guibg=bg gui=none
  hi LineNr       ctermfg=none ctermbg=none guibg=bg   gui=none
  hi SignColumn   ctermfg=none ctermbg=none guibg=bg                  gui=none
  hi VertSplit    ctermfg=none ctermbg=none guifg=bg guibg=bg         gui=none
  hi NonText      ctermfg=none ctermbg=none guifg=bg                  gui=none

  "hi TagbarHighlight guibg='#4c4c4c' gui=none
  "hi Search guibg='#5c5c5c' guifg='#000000' gui=bold

endfunction " }
function! g:nvpm.zoom.enable() "{

  exec 'silent! top split '. g:nvpm.zoom.tbuffer
  let &l:statusline='%{g:nvpm.zoom.null()}'
  silent! wincmd p

  exec 'silent! bot split '. g:nvpm.zoom.bbuffer
  let &l:statusline='%{g:nvpm.zoom.null()}'
  silent! wincmd p

  exec 'silent! vsplit'. g:nvpm.zoom.lbuffer
  let &l:statusline='%{g:nvpm.zoom.null()}'
  silent! wincmd p

  exec 'silent! rightbelow vsplit '. g:nvpm.zoom.rbuffer
  let &l:statusline='%{g:nvpm.zoom.null()}'
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

  "call self.save('TabLine')
  "call self.save('TabLineFill')
  "call self.save('TabLineSell')
  "call self.save('StatusLine')
  "call self.save('StatusLineNC')
  call self.save('LineNr')
  call self.save('SignColumn')
  call self.save('VertSplit')
  call self.save('NonText')

  call self.highlight()

  let self.enabled = 1

endfunction "}
function! g:nvpm.zoom.disable() "{

  "only

  call self.bdel()
  let self.enabled = 0

  "call self.hset('TabLine')
  "call self.hset('TabLineFill')
  "call self.hset('TabLineSell')
  "call self.hset('StatusLine')
  "call self.hset('StatusLineNC')
  call self.hset('LineNr')
  call self.hset('SignColumn')
  call self.hset('VertSplit')
  call self.hset('NonText')

endfunction "}
function! g:nvpm.zoom.bdel() "{
  exec ':silent! bdel '. self.lbuffer
  exec ':silent! bdel '. self.bbuffer
  exec ':silent! bdel '. self.tbuffer
  exec ':silent! bdel '. self.rbuffer
endfu " }
function! g:nvpm.zoom.null() "{
  return ''
endfunction "}
function! g:nvpm.zoom.swap() "{

  if !g:nvpm.data.loaded|return|endif

  if self.enabled
    call self.disable()
  else
    call self.enable()
  endif

  let termpatt = 'term://(.{-}//(\d+:)?)?\zs.*'
  if !empty(matchstr(bufname(),termpatt))
    call g:nvpm.data.curr.edit()
  endif

endfunction " }
function! g:nvpm.zoom.rset() "{

  let self.enabled = 0
  call self.bdel()
  call self.swap()

endfunction " }

fu! g:nvpm.zoom.save(group)

  let output = execute('hi '.a:group)

  let self.groups[a:group] = {}

  let items  = []
  let items += ['cterm']
  let items += ['start']
  let items += ['stop']
  let items += ['ctermfg']
  let items += ['ctermbg']
  let items += ['gui']
  let items += ['guifg']
  let items += ['guibg']
  let items += ['guisp']
  let items += ['blend']

  for item in items
    let self.groups[a:group][item] = matchstr(output , item.'=\zs\S*')
  endfor

endfu
fu! g:nvpm.zoom.hset(group)
  let input = ''
  for item in keys(self.groups[a:group])
    if !empty(self.groups[a:group][item])
      let input .= item.'='.self.groups[a:group][item].' '
    endif
  endfor
  "execute 'hi clear '.a:group
  execute 'hi '.a:group.' '.input
endfu


" }

" func}
" Helpers      {

function! NVPMNextPrev(a,l,p)

 return "workspace\nbuffer\ntab"

endfunction
function! NVPMListProjects(a,l,p)

 return join(g:nvpm.dirs.list('projname'),"\n")

endfunction
function! FoundItem(item,list)
    let found = 0

    for element in a:list
      if element == a:item
        let found = 1
        break
      endif
    endfor

    return found
endfunction
function! Found(x)
  return !empty(a:x)
endfunction
function! DoesNotFind(x)
  return !Found(a:x)
endfunction
fu! s:handlehelpandman()
  let HelpFilePath=bufname()
  if !empty(matchstr(bufname(),'man:\/\/.*'))
    close
    let enabled = g:nvpm.zoom.enabled
    if enabled
      call g:nvpm.zoom.disable()
      exec 'edit '. HelpFilePath
      call g:nvpm.zoom.enable()
    else
      exec 'edit '. HelpFilePath
    endif
  elseif &filetype == 'help' && !filereadable('./'.bufname())
    bdel
    exec 'edit '. HelpFilePath
  endif
endfu
fu! s:handlequitcurrbuff()
  call g:nvpm.zoom.disable()
  "if g:nvpm.data.loaded
    "if bufname() == g:nvpm.data.curr.item('b').path && g:nvpm.zoom.enabled
      "call g:nvpm.zoom.disable()
    "endif
  "endif
endfu

"}
" Init         {
call g:nvpm.init()
if get(g: ,'nvpm_load_default',1) && !argc()
  call g:nvpm.deft()
endif
let s:version = readfile(resolve(expand("<sfile>:p:h"))."/../version")
let s:version = len(s:version)?s:version[0]:''
" init }
" Commands     {

" For Help Feature
" command! -nargs=1 -complete=help H :enew | :set buftype=help | :h <args>

command!
\ -complete=custom,NVPMListProjects
\ -nargs=1
\ NVPMNewProject
\ call g:nvpm.newp("<args>")
command!
\ -complete=custom,NVPMListProjects
\ -nargs=1
\ NVPMLoadProject
\ call g:nvpm.data.load("<args>")

command!
\ -complete=custom,NVPMListProjects
\ -nargs=*
\ NVPMSaveDefaultProject
\ call g:nvpm.save.deft("<args>")

command! -count -complete=custom,NVPMNextPrev -nargs=1 NVPMNext call g:nvpm.loop(+1,"<args>")
command! -count -complete=custom,NVPMNextPrev -nargs=1 NVPMPrev call g:nvpm.loop(-1,"<args>")

command! NVPMTerminal     call g:nvpm.term.edit()
command! NVPMEditProjects call g:nvpm.edit.proj()
command! NVPMLineSwap     call g:nvpm.line.swap()
command! NVPMZoomSwap     call g:nvpm.zoom.swap()
command! NVPMVersion      echo s:version

" }
" AutoCommands {

if get(g:,'nvpm_zoom_aufix_terminal',1)

  let au  = 'au WinEnter '
  let au .= g:nvpm.zoom.lbuffer
  let au .= ','
  let au .= g:nvpm.zoom.bbuffer
  let au .= ','
  let au .= g:nvpm.zoom.tbuffer
  let au .= ','
  let au .= g:nvpm.zoom.rbuffer
  let au .= ' '
  let au .= 'if g:nvpm.zoom.enabled|call g:nvpm.zoom.rset()|endif'
  exec au

  " See help and man without split
  au BufWinEnter * call s:handlehelpandman()

  au QuitPre * call s:handlequitcurrbuff()

endif

" Set project files filetype as nvpm
"execute 'au BufEnter *'. g:nvpm.dirs.path("proj") .'* set ft=nvpm'

" AutoCommands }
