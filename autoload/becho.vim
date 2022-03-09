scriptencoding utf-8
" ========================================================================{{{1
" Plugin:     becho-vim
" LastChange: 2022/02/17  v0.93
" License:    MIT license
" Filenames:  %/../../plugin/becho.vim
"             becho.vim
" ________________________________________________________________________{{{2
" ========================================================================}}}1

let s:n = expand('<sfile>:t:r')
let s:t_cpo = &cpo | set cpo&vim

" OPTION: ================================================================{{{1
let s:{s:n} = {}

let s:{s:n}.prefix = '==== %X `#arg#` ===='
let s:{s:n}.format = 40
" let s:{s:n}.bang = 0 "
let s:{s:n}.reverse = 0
let s:{s:n}.buffer = s:n..'://log-%x/output'
let s:{s:n}.window = 'bel sp'
let s:{s:n}.option = ''
let s:{s:n}.size = [0, 0]

let s:{s:n}.color = [
  \   'Comment',
  \   'Constant',
  \   'Identifier',
  \   'Statement',
  \   'Preproc',
  \   'Underlined',
  \   'ErrorMsg',
  \   'ToDo',
  \   'Pmenu',
  \ ]

" MODULE: ================================================================{{{1
  " ______________________________________________________________________{{{2
  fu! s:is(...) abort " (a, b) = (a === b)
    let [a, b] = [get(a:, 1), get(a:, 2, 0zff00ff)]
    return (type(a)==type(b) && a==b) ? 1 : 0
  endfu

  " ______________________________________________________________________{{{2
  fu! s:get(...) abort " (var, {key/idx...}, [default=0]) = value  @deepget()
    if a:0<1 | return 0 | elseif a:0<2 | return arg[0] | endif
    let [r, d] = [a:1, get(a:, 3)]
    let k = split(''..a:2, '\v\s*[\[\]\.''"]+\s*')

    let _gf = {
      \   '1': {a,b-> strlen(a)>b ? a[b] : 0z00ff},
      \   '2': {a,b-> get(a, b, 0z00ff)},
      \   '3': {a,b-> len(a)>b ? a[b] : 0z00ff},
      \   '4': {a,b-> has_key(a, b) ? a[b] : 0z00ff},
      \  '10': {a,b-> get(a, b, 0z00ff)},
      \ }

    for c in k
      let r = has_key(_gf, type(r)) ? _gf[type(r)](r, c) : 0z00ff
      if s:is(r, 0z00ff) | let r = d | break | endif
    endfor

    return r
  endfu

  " ________________________________________________________________________{{{2
  fu! s:esc(...) abort " ('str', [flg=0:pat 1:sub]) = 'escaped-string'
    return escape(a:1, get(a:, 2)==0 ? '$%&()-=^~\|@[{;*]}<.>?' : '$%&()^\|@[{+*]}<>?') 
  endfu

  " ________________________________________________________________________{{{2
  fu! s:replace(...) abort " ('str', [[pat, sub]...], [loop=0]) = 'replaced-string'
    let a = flattennew(a:000) | let f = 0
    if type(a[-1])==0 | let f = a[-1]!=0 ? 1: 0 | let a = a[:-2] | endif
    let r = a[0] | if len(a)<2 | return r | endif

    let [re, p] = [[], '\[ze']
    for i in range(1, len(a)-1, 2)
      if a[i]=~'\v\c^\\[os]' | let a[i] = a[i][2:] | let q = '' | else |  let q = 'g' | endif
      call add(re, [a[i], a[i+1], q])
    endfor

    while p!=r | let p = r
      for rr in re | let r = substitute(r, rr[0], rr[1], rr[2]) | endfor
      if f==0 | break | endif
    endwhile

    return r
  endfu

  " ______________________________________________________________________{{{2
  fu! s:force(...) abort " (lnum, [lnum2], 'text', [bufNr=0]) @modify buffer-lines
    let buf = (a:0>0 && type(get(a:, a:0, ''))==0) ? a:000[-1] : bufnr('%')
    let ll = getbufinfo(buf)[0].linecount
    let ln = [type(get(a:, 1, ''))==0 ? a:1 : line('.'), 0]
    let ln[1] = type(get(a:, 2, ''))==0 ? a:2 : ln[0]
    call map(ln, {_,v-> v<0 ? ll+v+2 : v})
    if ln[1]<ln[0] | let ln = [ln[1], ln[0]] | endif
    let mr = [getbufvar(buf, '&modifiable'), getbufvar(buf, '&readonly')]

    let txt = flatten(map(filter(copy(a:000), {_,v-> type(v)==1}), {_,v-> split(v, '\v\s*\n')}))

    call setbufvar(buf, '&modifiable', 1) | call setbufvar(buf, '&readonly', 0)
    silent call deletebufline(buf, max([0, ln[0]]), max([0, ln[1]]))
    if len(txt)
      if (line('$')== 1 && getline(1)=='')
        silent call setbufline(buf, 1, txt)
      else
        silent let @a= appendbufline(buf, min([line('$'), ln[0]]), txt)
      endif
    endif

    call setbufvar(buf, '&modifiable', mr[0]) | call setbufvar(buf, '&readonly', mr[1])
    return getbufinfo(buf)[0].linecount
  endfu

  " ________________________________________________________________________{{{2
  fu! s:windivision(...) abort "([winID = 0]) = window-divison['col/row']
    let wid = get(a:, 1)
    if wid<1000 | let wid = win_getid(wid) | if wid<1000 | let wid = win_getid() | endif | endif
    let tnr = win_id2tabwin(wid)[0]

    let [d, ret] = [string(winlayout(tnr)), '']
    fu! s:_dw(...) closure abort " () @分割判定 - - - - - - - - - - - - - - -{{{
      let a = a:1 | let l = substitute(a[0], '\v[^\-]', '', 'g')
      let ret = a[1][0]..len(l)..ret | return a[2]
    endfu " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}}}

    let d = s:replace(d, ['\v\c["'']|leaf', ''], ['\v(\d+)', {r-> r[1]==wid ? wid : ''}])
    let d = s:replace(d, ['\v\[[^0-9\[]{-}\]', '-'], 1)
    let d = s:replace(d, ['\v\c\[*(col|row)\W{-}(\d+)', {r-> s:_dw(r)}], 1)
  " ec d ret
    return ret
  endfu

" SUB: ==================================================================={{{1
" ________________________________________________________________________{{{2
fu! s:getopt(...) abort " () = {options}  (b: > w: > t: > g: > s:(default))
  let o = deepcopy(s:{s:n})
  for [k, v] in items(o)
    for s in [b:, w:, t:, g:]
      let p = s:get(s, printf('%s.%s', s:n, k), 0zff)
      if !s:is(p, 0zff) | let o[k] = p | break | endif
    endfor
  endfor

  return o
endfu

" ________________________________________________________________________{{{2
fu! s:normalize(...) abort " ('msg', 'q-args', [{opt}]) = 'msg'  @書式整形等
  if (type(a:1)==1 && v:errmsg==matchstr(a:1, '\v\w.*$')) | return v:null | endif
  let m = get(a:, 1) | if type(m)!=1 | let m = string(m) | endif
  if m=='' | return v:null | endif | let m = substitute(m, '\v^\n+', '', '')

  let _c = "\n\x01\x02"
  let _d = repeat(' ', shiftwidth())
  let _e = ['\\', '\"', '\''']
  let _a = get(a:, 2, '')

  let opt = s:getopt()
  if type(get(a:, 3))==4 | let a = get(a:, 3)
    for [k, v] in items(opt) | let opt[k] = get(a, k, v) | endfor
  endif

  fu! s:_es(...) closure " () @escape-string - - - - - - - - - - - - -{{{
    let s = get(a:, 1, '')
    call add(_e, printf((opt.bang ? '%s' : '#1{%s}#'), tr(s, '#', "\x05")))
    return printf('%s%s%s%s', _c[1], repeat(' ', len(s)-2), len(_e)-1, _c[1])
  endfu " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}}}
  fu! s:_rs(...) closure " () @restore-string - - - - - - - - - - - - - {{{
    return _e[get(a:, 1)-0]
  endfu " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}}}
  fu! s:_eb(...) closure abort " () @escape-bracket - - - - - - - - - - - -{{{
    if strwidth(a:1)<(opt.format-2) && a:1!~'\v\n'
      let p = substitute(a:1, '\v\,', "\x05", 'g')
    else
      let [p, q, j] = [map(split(a:1, '\v\,\s*'), {_,v-> v.."\x05"}), [''], 0]
      let p[-1] = p[-1][:-2]
      for i in range(len(p))
        if i==0 || (p[i]!~'\v\n' && q[j]!~'\v\n' && (strwidth(q[j])+strwidth(p[i]))<=opt.format)
          let q[j]..= p[i]..' '
        else
          call add(q, p[i]..' ') | let j = len(q)-1
        endif
      endfor
      let p = _c[0]..join(q, _c[0]).._c[0]
    endif
    return "\x03"..p.."\x04"
  endfu " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}}}
  fu! s:_nc(...) closure abort " () @nested-colors - - - - - - - - - - - - {{{
    return a:2=~'\v\#\w+\{\_.+' ?
      \ printf('#%s{%s#%s{', a:1, substitute(a:2, '\v^(\_.{-})\#(\w+)\{(\_.*)$', {r-> r[1]..'}#'..s:_nc(r[2], r[3])}, ''), a:1) :
      \ printf('%s%s%s%s%s%s', _c[1:2], a:1, _c[1], a:2, _c[1], _c[1])
  endfu " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}}}

  " escape-strings
  let m = s:replace(m, map(range(3), {i-> [s:esc(_e[i]), _c[1]..i.._c[1]]}))
  let m = s:replace(m, ['\v((["''])\_.{-}\2)', {r-> s:_es(r[1])}], 1)

  " formatting
  if (opt.format>0 && opt.bang==0)
    for i in range(0, 4, 2) " @nest <cr>
      let b = '[]{}()'[i:i+1]
      let m = s:replace(m, [printf('\v\%s([^\%s\%s]{-})\%s', b[0], b[0], b[1], b[1]), {r-> s:_eb(r[1])}], 1)
      let m = s:replace(m, ['\v%x03', b[0]], ['\v%x04', b[1]], 1)
    endfor
    let m = substitute(m, '\v%x05', ',', 'g')
    let [p, d] = [split(m, '\v\n+\s*'), 0]
    for i in range(len(p)) " @indent
      let d-= max([0, p[i]=~'\v^\s*[\]\}\)]' ? 1 : 0])
      let p[i] = repeat(_d, d)..p[i]
      let d+= p[i]=~'\v[\[\{\(]\s*$' ? 1: 0
    endfor
    let m = join(p, "\n")
  endif

  " prefix
  if (opt.prefix!='' && opt.bang==0)
    let _a = s:esc(s:replace(_a, ['{', "\x03"], ['}', "\x04"], 1), 1)
    let p = substitute(strftime(opt.prefix), '\v\c\#arg%[ument]s?\#', _a, 'g')
    let m = printf('#0{%s}#%s%s', p, _c[0], m)
  endif

  " restore-strings
  let m = s:replace(m, [printf('\v%s\s*(\d+)%s', _c[1], _c[1]), {r-> s:_rs(r[1])}], 1)

  " colors
  if xor(opt.format>0, opt.bang)
    let m = substitute(m, '\v\#1\{(["''])([^"'']{-})\1\}\#:', '#2{\2}#:', 'g')
  endif
  let m = s:replace(m, '\s\v\#(\w+)\{(\_.{-})\}\#', {r-> s:_nc(r[1], r[2])}, 1)
  let m = s:replace(m, ['\v%x01%x02\w+%x01%x01%x01', ''], 1)
  let m = substitute(m, '\v(%x01%x02)\s*(\d+)(%x01)', {r-> r[1]..opt.color[(r[2]-0)%len(opt.color)]..r[3]}, 'g')
  let m = s:replace(m, ["\x03", '{'], ["\x04", '}'], ["\x05", '#'])

  return m
endfu

" ________________________________________________________________________{{{2
fu! s:logbuf(...) abort " ('buf-name', {option}) = bufnr  @ログ用バッファ作成
  let [bn, opt] = [get(a:, 1, ''), get(a:, 2)]
  let nw = !bufexists(bn) | execute opt.window bn
  if nw
    setlocal bt=nofile ft=output scl=no fdc=0 cocu=nvc cole=2 nobl nolist nocuc ro noma
    noremap <silent><buffer> <Plug>(log-quit) <Cmd>q<CR>
    noremap <silent><buffer> <Plug>(log-clear) <Cmd>call <SID>force(1,line('$'),'')<CR>
    syntax clear
    hi! link LogConceal Conceal
    sy match LogConceal /\v%x01%x02\w+%x01|%x01%x01/ conceal contained

    map <nowait><buffer> q <Plug>(log-quit)
    map <nowait><buffer> c <Plug>(log-clear)
  endif
  let b:{s:n}_hl = get(b:, s:n..'_hl', [])
  if opt.option!='' | call execute('setlocal '..opt.option) | endif

  return bufnr("%")
endfu

" MAIN: =================================================================={{{1
" ________________________________________________________________________{{{2
fu! {s:n}#echo(...) abort " ('msg', 'q-args', [bang=0])  @カラー整形メッセージ
  let s:{s:n}.bang = type(get(a:, 3))==0 && get(a:, 3)!=0
  let m = s:normalize(get(a:, 1), get(a:, 2, ''), get(a:, 3))
  if s:is(m, v:null) | return -1 | endif

  let p = split(m, "\x01") | redraw | ec ""
  for pp in p " put put put...
    if pp[0]=="\x02"
      call execute('echohl '..pp[1:])
    elseif pp==""
      call execute('echohl NONE')
    else
      execute printf('echon %s', string(pp))
    endif
  endfor
endfu

" ________________________________________________________________________{{{2
fu! {s:n}#log(...) abort " ('msg', 'q-args', [bang=0]) @ログ
  let s:{s:n}.bang = type(get(a:, 3))==0 && get(a:, 3)!=0
  let m = s:normalize(get(a:, 1), get(a:, 2, ''), get(a:, 3))
  if s:is(m, v:null) | return -1 | endif

  " let opt = deepcopy(s:{s:n})
  let opt = s:getopt()
  if type(get(a:, 3))==4 | let a = get(a:, 3)
    for [k, v] in items(opt) | let opt[k] = get(a, k, v) | endfor
  endif

  let cid = win_getid()
  let bn = get(t:, s:n..'_log', '')
  if bn==''
    if opt.buffer=~'\v\c\%[a-z]'
      let i = tabpagenr() | let n = printf('%x', i)
      let s = substitute(opt.buffer, '\v\c\%[a-z]', n, 'g')
      while bufnr(s)>=0
        let i+= 1 | let n = printf('%x', i) | let s = substitute(opt.buffer, '\v\c\%[a-z]', n, 'g')
      endwhile
      let bn = s
    else | let bn = opt.buffer | endif
    let t:{s:n}_log = bn
  endif
  let [lb, wid] = [bufnr(bn), bufwinid(bn)]
  if (lb<0 || wid<0) | let [lb, wid] = [s:logbuf(bn, opt), bufwinid(bn)] | endif
  call win_gotoid(wid)

  fu! s:_hl() closure abort " () @add-syntax - - - - - - - - - - - - - - - {{{
    let [hl, sy] = [get(b:, s:n..'_hl', []), []]
    call substitute(m, '\v%x01%x02(\w+)%x01', {r-> len(add(sy, r[1]))}, 'g')
    call sort(sy)->uniq()
    for s in sy | let l = tolower(s)
      if index(hl, l)<0 | call add(hl, l)
        execute printf('sy match %s /\v\c%%x01%%x02%s%%x01\_.{-}%%x01%%x01/ contains=LogConceal', s, s)
      endif
    endfor
    let b:{s:n}_hl = hl
  endfu " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}}}

  call s:_hl() " ハイライト登録

  let a = matchstr(s:windivision(wid), '\v\a+\d+$')
  if a[0]=='r' && opt.size[1]>0
     execute 'vert resize '..opt.size[1]
  elseif a[0]=='c' && opt.size[0]>0
     execute 'resize '..opt.size[0]
  endif

  let pl = (line('$')==1 && getline(1)=='') ? [1,-1] : (opt.reverse? 0 : -1)
  let pl = (opt.reverse? 0 : line('$')+1)

  call s:force(pl, m, lb)
  call cursor(max([1, pl]), 0)
  normal! z.

  return win_gotoid(cid)
endfu


" ========================================================================}}}1

let &cpo = s:t_cpo | unlet s:t_cpo
" vim:set ft=vim fenc=utf-8 norl:                             Author: HongKong
