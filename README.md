# becho-vim

[![REQUIRE: Vim 8.2-later?](https://img.shields.io/static/v1?label=plugin&message=8.2%2B&color=2a2&logo=vim)](https://www.vim.org "REQUIRE: Vim 8.2 later")&nbsp;
[![MIT License](https://img.shields.io/static/v1?label=license&message=MIT&color=28c)](LICENSE "MIT License")&nbsp;
[![plugin version 1.00](https://img.shields.io/static/v1?label=version&message=1.00&color=e62)](https://github.com/hongkong3/becho-vim/ "plugin version 1.00")&nbsp;
🍔🍙

> *This document has been prepared baded on automatic translation.  
> Please forgive me if there are some strange sentences...*  

**"becho-vim"** is the extension `:echo` command in Vim-script, as Vim-plugin.  


### This plugin provides Command the following features:

- Ease colorization of message text.  
  If there are specific **format** in the String, it will be colored as *highlight*.  
  ```vim
  :Becho "Colored as #0{comment}# and #Statement{statement}#."
  ```
  <br />

- Format and display the values of **LIST** and **DICT** variables.  
  The default setting is Enabled, but it can be Disabled.  
  ```vim
  {
    key: 'value',
    LIST: [
      1, 2, 3, 4,
      'Short contents can also be grouped together'
    ]
  }
  ```
  <br />

- Displays the Time and Argument prefixes.  
  You can chage the contents or hide them by setting options.  
  ```vim
  ==== 00:00:00 `argument` ====
  Messages.
  ```
  <br />

- The same contents as above can be output to buffer.  
  To outpt to a buffer, use the `:Belog` command.  
  <br />

 See more -> `:help Becho`  


----
## Installation
Install using your favorite package manager.  

- [**Vundle:**](https://github.com/VundleVim/Vundle.vime)  
  ```vim
  Plugin 'hongkong3/becho-vim'
  ```
- [**NeoBundle:**](https://github.com/Shougo/neobundle.vim)  
  ```vim
  NeoBundle 'hongkong3/becho-vim'
  ```
- [**VimPlug:**](https://github.com/junegunn/vim-plug)  
  ```vim
  Plug 'hongkong3/becho-vim'
  ```
- [**Pathgon:**](https://github.com/tpope/vim-pathogen)  
  ```shell
  cd ~/.view/bundle
  git clone https://github.com/hongkong3/becho-vim
  ```

----

## Usage

Use it by executing the following Command, or calling the Function.  


```vim
:Becho[!] {expr} ..
```

This is almost the same as `:echo` command.  
If there are specific format in the String, it will be colored as *highlight*.  

Depending on the option settings, it automatically displays the formatted contents of **DICT** and **LIST** type variables, and prefixes arguments, etc.  

If with the bang[**!**], it will disable them and only do *text-coloring*.  
<br />

```vim
:Belog[!] {expr} ..
```

Display the same contents as `:Becho`, in a specific **log-buffer**.  
This is a substitute command for `:echomsg`.  

Hit the `c` in log-buffer, will clear messages.  
Hit the `q` in log-buffer, will close the log-buffer window.  
<br />

#### CAUTION:  
Script local variables (`s:var`) cannot be used.  
If you want to display the value of a script local variable, asign it to temporary variable, etc...  
```vim
  :let tmp = s:var
  :Becho tmp
```

----
## OPTION

In this plugin, option values can be set in **any Scopes**.  
Different options can be set for each buffer, tab-page, etc.., according to the displaying contents.  

The priority order for each Scope is...  
(`function({options})` == `[!]bang`)  >  `b:`  >  `w:`  >  `t:`  >  `g:`  >  `s:`(default)

Also, when setting each option, please define a DICT variable in advance.  
```vim
 let g:becho = {}
 let g:becho.format = 1
```
<br />

#### OPTION LIST

```vim
  s:becho.format = 40                         " length of formated LIST/DICT (if 0 then no formated)

  s:becho.prefix = '==== %X `#arg#` ===='     " formatting-text of Prefix

  s:becho.color = [                           "  preset Colors (highlight-group)
      'Comment',
      'Constant',
      'Identifier',
      'Statement',
      'Preproc',
      'Underlined',
      'ErrorMsg',
      'Todo',
      'Pmenu',
  ]

  " below options for log-buffer (:Belog)

  s:becho.reverse = 0                         " new message to  0: add-bottom 1: insert-top
  s:becho.window = 'belowright split'         " window creation command
  s:becho.option = ''                         " additional option -> :setlocal
  s:becho.size = [0, 0]                       " keep to window size [row, col]
  s:becho.buffer = 'becho://log-%x/output'    " buffer name (%x -> tabpagenr)
```

----

*The "becho-vim" is no relationship with any real person, organization, or name.*  

