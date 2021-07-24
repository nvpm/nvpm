
# Introduction

NVPM  stands  for  Neovim Project Manager. It's mission is to assist the user on
managing  large quantities of files in any project. The main goal is to create a
tree-like  structure  in order to overcome the linearity of Neovim's bufferlist.
To  do  that,  the  creator was forced to totally ignore how Neovim handles each
loaded  file.  The  approach  here  is to make a plan about which files the user
wants  to  open  and   then write  what is called a  project file . Those  files
follow  the NVPM Markup Language, which was specifically created for this plugin.

Here is a quick demonstration of the plugin being used. The rest can be seen  at 
`:help nvpm`. Enjoy.

<figure>
<p  align=center>
  <img src="https://gitlab.com/nvpm/home/-/raw/main/nvpm.gif"/>
</p>
</figure>


# installation

## using `vim-plug`

```vim
Plug 'https://gitlab.com/nvpm/nvpm' , {'branch' : 'main'}
```

## using `runtimepath`

```bash
cd $HOME
git clone https://gitlab.com/nvpm/nvpm
echo "set runtimepath+=~/nvpm" >> .config/nvim/init.vim
```

## copying files with `bash`

```bash
cd $HOME
git clone https://gitlab.com/nvpm/nvpm
cp -r nvpm/{plugin,syntax,version} .config/nvim
mkdir -p .config/nvim/doc
cp  nvpm/doc/nvpm.txt .config/nvim/doc
touch .config/nvim/doc/tags
cat nvpm/doc/tags >> .config/nvim/doc/tags
```

# quick configuration

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
let g:nvpm_line_bottomcenter  = ' ⬤ %f'
let g:nvpm_line_git_info      = 1
let g:nvpm_line_git_delayms   = 1000

" Git Info Colors
hi NVPMLineGitModified guifg=#ff0000 gui=bold
hi NVPMLineGitStaged   guifg=#00ff00 gui=bold
hi NVPMLineGitClean    guifg=#77aaaa gui=bold

" Tab Colors
hi NVPMLineTabs     guifg=#777777 gui=bold
hi NVPMLineTabsSel  guibg=#337a8a guifg=#ffffff gui=bold
hi NVPMLineTabsFill guibg=none
" Buffer Colors
hi link NVPMLineBuff     NVPMLineTabs
hi link NVPMLineBuffSel  NVPMLineTabsSel
hi link NVPMLineBuffFill NVPMLineTabsFill
" Workspace Colors
hi link NVPMLineWksp     NVPMLineTabs
hi link NVPMLineWkspSel  NVPMLineTabsSel
" Project File Name Colors
hi NVPMLineProjSel   guifg=#000000 guibg=#00ffff

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
nmap ml               :call g:nvpm.line.swap()<cr>
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

# discussion and news on Telegram (in Portuguese and English)

* [group](https://t.me/nvpmuser)
* [channel](https://t.me/nvpmnews)