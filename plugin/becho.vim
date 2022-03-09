scriptencoding utf-8
" ========================================================================{{{1
" Plugin:     becho-vim
" LastChange: 2022/02/26  v1.00
" License:    MIT license
" Filenames:  becho.vim
"             %/../../autoload/becho.vim
" ========================================================================}}}1

let s:n = expand('<sfile>:t:r')
if get(g:, 'loaded_'..s:n)>=0.10
  finish
endif
let g:loaded_{s:n} = 0.10
let s:t_cpo = &cpo | set cpo&vim

" COMMAND: ==============================================================={{{1
com! -nargs=* -complete=expression -bang Becho call {s:n}#echo(execute('echo '..<q-args>), <q-args>, '<bang>'!='')
com! -nargs=* -complete=expression -bang Belog call {s:n}#log(execute('echo '..<q-args>), <q-args>, '<bang>'!='')
" ========================================================================}}}1
let &cpo = s:t_cpo | unlet s:t_cpo
" vim:set ft=vim fenc=utf-8 norl:                             Author: HongKong
