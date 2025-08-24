---
title: Vim
categories: 工具
tags:
date: 2021-12-27 09:15:01
---

## 1. 安装 git 和 curl

> yum install git curl

## 2. 安装 vim-plugin

> [参考连接](https://github.com/junegunn/vim-plug)

可以修改 hosts 文件解决访问不了 github 的问题

```bash
# github
199.232.68.133 raw.githubusercontent.com
199.232.68.133 user-images.githubusercontent.com
199.232.68.133 avatars2.githubusercontent.com
199.232.68.133 avatars1.githubusercontent.com
```

## 3. vimrc 配置文件

> vim ~/.vimrc

```bash
let mapleader=" "
syntax on

"显示行号
set number

"显示鼠标线
set cursorline
"字体不会超出视野
set wrap
"在底线显示当前命令
set showcmd
"命令提示
set wildmenu

"兼容vi
set nocompatible
"识别不同的文件模式
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on
"编辑器可以使用鼠标
set mouse=a
set encoding=utf-8
"兼容终端配色问题
"let &t_ut=''
"缩进
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
"行尾
"set list
"保持预览在上下5行之间
set scrolloff=5
"退格键可以回到行首
set backspace=indent,eol,start
"收起代码
set foldmethod=indent
set foldlevel=99
"底下状态栏等于2
set laststatus=2
set autochdir
"重新打开文件光标会显示上一次打开的位置
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"1. noremap a b | 改键位,a 键 替换 b键盘
"加快上下左右浏览的速度
noremap J 5j
noremap K 5k
noremap H 5h
noremap L 5l

"查看上/下一个搜索接口并显示在中间
noremap n nzz
noremap n nzz
"空格回车:去除搜索高亮
noremap <leader><cr> :nohlsearch<cr>

"搜索高亮
set hlsearch
"重新打开文件不会显示搜索高亮
exec "nohlsearch"
set incsearch
"忽略大小写
set ignorecase
"智能大小写
set smartcase

"2. map s :w<cr> | 快捷键
map s <nop>
"保存
map S :w<cr>
"退出
map Q :q<cr>
"更新配置文件
map R :source $MYVIMRC<cr>

"3. <operation> <motion>
"x : 删除当前字符
"d + 方向键 + number 删除方向上的 number 个字符
"y + 方向键 + number 复制方向上的 number 个字符
"c + 方向键 + number 删除并进入写入模式
"w : 移动一个词。
"ciw : 修改当前词；ci" : 将"符号内的词全部修改；
"yi" : 将"符号内的词全部复制; di" : 将"符号内的词全部删除。
"f" : 查找下一个"符号。
"df" : 删除到下一个"符号的内容；yf" : 复制到下一个"符号的内容；
"cf" : 删除到下一个"符号的内容并进入写入模式
"zz : 将当前行显示在中间

"4. :命令模式
"split : 上下分屏；vsplit : 左右分屏
map sk :set nosplitbelow<CR>:split<CR>
map sj :set splitbelow<CR>:split<CR>
map sh :set nosplitright<CR>:vsplit<CR>
map sl :set splitright<CR>:vsplit<CR>
"7. ctrl + w + 方向 : 分屏间光标切换
"空格 + 方向 : 来切切换屏幕
"上下左右屏幕切换
map <LEADER>k <C-w>k
map <LEADER>j <C-w>j
map <LEADER>h <C-w>h
map <LEADER>l <C-w>l
"8. :vertical resize-5 设置当前分屏大小
map wk :res +5<CR>
map wj :res -5<CR>
map wh :vertical resize-5<CR>
map wl :vertical resize+5<CR>
"9. :tabe 打开新的标签
map tt :tabe<CR>
"切换标签页
map tl :+tabnext<CR>
map th :-tabnext<CR>

"6. 打开文件
":e path : 打开路径下的文件

"5. v 模式：鼠标单击. shift + v : 行模式.
"control + v : 可视块模式(禅模式); 选择后按 shift + i 修改内容；再esc生效
" v 模式选择后，可以输入:normal I"，进行统一注释

call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'connorholyday/vim-snazzy'

call plug#end()

"设置颜色
colorscheme snazzy
let g:SnazzyTransparent = 1
```

## 4.安装插件

> :PlugInstall
