" Plugin: https://github.com/sudo-NithishKarthik/nvim_whid
" Description: My first custom plugin
" Maintainer: Nithish <https://github.com/sudo-NithishKarthik>

if exists("g:loaded_whid") | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! whid lua require'whid'.whid()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_whid = 1
