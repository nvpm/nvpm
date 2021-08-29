
<details>

<summary>New Version Warning</summary>

The NVPM  projects are going through a hard reset in their code paradigm and
the organizational structure. The code is being ported to an Object Oriented
paradigm, which will allow  me to solve  problems more efficiently. However,
although this does not affect the end-user,  the  plug-in structure is being
changed a bit.

The  plug-in  now  called  nvpm (this plug-in, the frozen one) will be split
into at least 3 other plug-ins. They are:

1. `flux`: plug-in will be in charge of parsing the project file syntax into
a data structure usable by the next plug-ins

2. `proj`: will be in  charge with the project management itself. It's gonna
perform  all  navigation  and  even  some new housekeeping operations in the
project's file structure. For this, proj  will  use the data structure built
by `flux`, as mentioned above.

3. `line`: will be resposible for constructing the tab and status lines with
many  more  features,  including  a new syntax that's being developed as we
speak. You see, there are many plug-ins  of  the sort out there, and all of
them  seem  to  require  the  user  learn  how  to  manipulate   VimL  data
structures  such  as  lists  and  dictionaries.  I'm  sure  that's the best
solution when performance is concerned, but it's done at the  peril  of the
begginers.  I  intend  to  attend both persons. This new syntax is gonna be
treated by the `flux` plug-in as well.

The  `zoom`  plug-in already undergone these changes and it's no longer part
of the current  (and  frozen)  nvpm. The same will happen with it's parsing,
navigation and management, and the  lines  drawing,  which  is now all being
done by nvpm alone. This is starting to get in my nerves, hence  the change.

For those who still want to use the current (and frozen) version can install
it  using  the  git  tag  `frozen`.  Using vim-plug is recommended for this,
because you can explicitly specify that by the following:

  Plug 'https://gitlab.com/nvpm/nvpm' , {'tag' : 'frozen'}

Note, only upon reinstalling the plug-in will work. If you update it, it
won't work.

Users  must  do this, because I also intend to use the repository nvpm (this
repository) as  a  pack  of  all plug-ins together. This will be perfect for
those users (myself included!) who just want to use all my plug-ins, without
having to go through the trouble  of  installing  each  and everyone of them
separately. So in the near future, those users will just  have  to  do  this

  Plug 'https://gitlab.com/nvpm/nvpm' , {'branch' : 'main'}

and have all of them will be installed. Easy hum?

Although  this  helps,  some  users  may  be concerned with unused memory by
having all plugins installed, and not using  some of them all the time. This
scenario  will never happen, because all plug-ins  are  now  making  use  of
Vim/Neovim  buil-in feature of automatic loading. In other words, nearly all
variables and functions will be loaded (occupy RAM memory) upon demand only,
except some that will be necessary to construct the command interfacing with
the user (the commands themselves). Note, the current frozen nvpm plug-in is
not making using of this awesome feature!

I appreciate your understanding.

</details>

# Introduction

NVPM  stands  for Neovim Project Manager. It's mission is to assist the user
on managing large  quantities  of  files in any project. The main goal is to
create a tree-like structure in order  to overcome the linearity of Neovim's
bufferlist. To do that, the creator was  forced to totally ignore how Neovim
handles each loaded file. The approach here  is  to  make a plan about which
files the user wants to open and then write what is called  a project file .
Those files follow the NVPM Markup Language, which was specifically  created
for this plugin.

Here is a quick demonstration of the plugin being used. The rest can be seen
at `:help nvpm`. Enjoy.

<figure>
<p  align=center>
  <img src="https://gitlab.com/nvpm/home/-/raw/main/nvpm.gif"/>
</p>
</figure>

And here is a test run in a real project.

<figure>
<p  align=center>
  <img width=85% height=85%
  src="https://gitlab.com/nvpm/home/-/raw/main/nvpm-usage.gif"/>
</p>
</figure>

# Installation

## Using `vim-plug`

```vim
Plug 'https://gitlab.com/nvpm/nvpm' , {'branch' : 'main'}
```

## Using `runtimepath`

```bash
cd $HOME
git clone https://gitlab.com/nvpm/nvpm
echo "set runtimepath+=~/nvpm" >> .config/nvim/init.vim
```

## Copying files with `bash`

```bash
cd $HOME
git clone https://gitlab.com/nvpm/nvpm
cp -r nvpm/{plugin,syntax,version} .config/nvim
mkdir -p .config/nvim/doc
cp  nvpm/doc/nvpm.txt .config/nvim/doc
touch .config/nvim/doc/tags
cat nvpm/doc/tags >> .config/nvim/doc/tags
```

# Quick configuration

I'm  not  sure  how  you will want to configure NVPM, but the following have
been known to work well  for  several users. They are kind of an agreed upon
settings. Most of them are already with their default values. Just drop them
into your `init.vim` and you should be good to go!

```vim
set termguicolors
set hidden
set showtabline=2
set laststatus=2

" Project options
let g:nvpm_new_project_edit_mode = 1
let g:nvpm_load_new_project      = 1

" directory tree
let g:nvpm_maketree = 1

" Line options for use with colors
let g:nvpm_line_closure       = 0
let g:nvpm_line_innerspace    = 0
let g:nvpm_line_show_projname = 1
let g:nvpm_line_bottomright   = '%y%m ⬤ %l,%c/%P'
let g:nvpm_line_bottomcenter  = ' ⬤ %{NVPMLINEFILENAME()}'
let g:nvpm_line_git_info      = 1
let g:nvpm_line_git_delayms   = 5000

" Git Info Colors
hi NVPMLineGitModified guifg=#aa4371 gui=bold
hi NVPMLineGitStaged   guifg=#00ff00 gui=bold
hi NVPMLineGitClean    guifg=#77aaaa gui=bold

" Tab Colors
hi NVPMLineTabs     guifg=#777777 gui=bold
hi NVPMLineTabsSel  guibg=#333a5a guifg=#ffffff gui=bold
hi NVPMLineTabsFill guibg=none
" Buffer Colors
hi link NVPMLineBuff     NVPMLineTabs
hi link NVPMLineBuffSel  NVPMLineTabsSel
hi link NVPMLineBuffFill NVPMLineTabsFill
" Workspace Colors
hi link NVPMLineWksp     NVPMLineTabs
hi link NVPMLineWkspSel  NVPMLineTabsSel
" Project File Name Colors
hi NVPMLineProjSel   guifg=#000000 guibg=#007777

nmap <silent><space>  :NVPMNext buffer<cr>
nmap <silent>m<space> :NVPMPrev buffer<cr>
nmap <silent><tab>    :NVPMNext tab<cr>
nmap <silent>m<tab>   :NVPMPrev tab<cr>
nmap <silent><c-n>    :NVPMNext workspace<cr>
nmap <silent><BS>     :NVPMNext workspace<cr>
nmap <silent><c-p>    :NVPMPrev workspace<cr>
nmap <F7>             :NVPMLoadProject<space>
nmap <F8>             :w<cr>:NVPMEditProjects<cr>
imap <F8>        <esc>:w<cr>:NVPMEditProjects<cr>
nmap <F9>             :NVPMSaveDefaultProject<space>
nmap <F10>            :NVPMNewProject<space>
nmap mt               :NVPMTerminal<cr>
nmap ml               :NVPMLineSwap<cr>
```

These mappings will translate into:

```text
<space>    : will go to the next buffer
m<space>   : will go to the previous buffer
<tab>      : will go to the next tab
m<tab>     : will go to the previous tab
control+n  : will go to the next workspace
<backspace>: will go to the next workspace (same as above)
control+p  : will go to the previous workspace
<F7>       : will load a project file
<F8>       : will save the current buffer and open the edit projects
             environment. This will work for both insert and normal
             modes.
<F9>       : will save a default project file
<F10>      : will create a new project file
mt         : will open the NVPM Terminal
ml         : will toggle the status and tab lines in and out
```

For more info, please see `:help nvpm`.

# Discussions and news on Telegram (in Portuguese and English)

* [group](https://t.me/nvpmuser)
* [channel](https://t.me/nvpmnews)
