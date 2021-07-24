# Note:

There  is  a  new version coming soon with new features and multiples changes in
the         API.         Care         must         be         taken        then.

# What does it do?

This plugin is a very simple one. It does only two things:

1. Saves your `vim`/`neovim` layouts.
2. Restores your `vim`/`neovim` layouts.

# Key Mapping

You can map keys for the only two command in the plugin. I usually do as follows:

```vim
nnoremap <F9>  <esc>:VWSSaveWorkSpace 
nnoremap <F10> <esc>:VWSLoadWorkSpace 
```

vws expects you to enter the name of the Workspace. This name is required because it will name a file into directory called `.VWS`.

# Options

There are only two options you can change in your `vimrc` or `init.vim`, and only if you want:

```vim
let g:VWS#Marker = '#'
let g:VWS#Directory = './.VWS'
```

the marker global variable does the job of marking the end of a tab in the layout file. Let's say you have 3 tabs with 2 files in each tab. Then, after saving this layout, you will end up with a layout file like the following:

```markdown
#
path/to/file1
path/to/file2
#
path/to/file1
path/to/file2
#
path/to/file1
path/to/file2                                                                                   
```

so this `g:VWS#Marker` option is just a string you can change to whatever you want.

On the other hand, `g:VWS#Directory` is the directory of your layout files will be stored. This folder is a hidden folder called `.VWS` in the current directory by default - until you change it to something else.

You can create and save as many layout files as you want for the same project (root folder of g:VWS#Directory). I implemented this in case I need to open the same files in a different manner.

# Integration with [Taboo](https://github.com/gcmt/taboo.vim) Plugin

I'm using `TabooRename` feature to rename the tabs. To do that, you can just put the name you want for each tab after the pattern you chose for your `g:VWS#Marker` in the created file. For example:

```markdown
# Src
src/Math/Real.h
src/Math/Real.c
# Tests
tests/Math/TestReal.h
tests/Math/TestReal.c
# Main
src/Main.h
src/Main.c
```

# Installation

* Manual Install

Just drop the file `plugin/VWS.vim` in your `vim` or `neovim` default plugin directory. 

* With [vim-plug](https://github.com/junegunn/vim-plug) plugin manager

```vim
Plug 'iasj/vws'
```

# Limitations

This plugin does not save the size nor if it was a `split` or `vsplit` in each window in the tabs. When it is loading, it will just `vsplit` each file accordingly with the layout file you saved. I did not care to implement this feature because I use this plugin along with [vim-window-manager](https://github.com/spolu/dwm.vim) plugin. Once dwm plugin messes with the size of the windows, there was no point on trying to save it.

# Why I did it?

I did this plugin because I was using this awesome plugin called [vim-control-space](https://github.com/vim-ctrlspace/vim-ctrlspace) until I realized it was too heavy for my machine, and because I was using only its `save` and `load` functions. So, there was no point on using it anymore, either way it is a very good plugin.
