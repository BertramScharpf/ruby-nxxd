" Vim syntax file
"
" Language:     Hexdump output
" Author:       Bertram Scharpf <software@bertram-scharpf.de>
" Last Change:  2019-09-28
" Version:      1

if exists("b:current_syntax")
  finish
endif


syn match xxdEmpty    +^\*$+
syn match xxdComment  +^\s*#.*+

syn match xxdAddress  +^\%(0x\)\?\x\+: *+ contains=xxdSepHex nextgroup=xxdHex
syn match xxdSepHex   +:+ contained

syn match xxdHex      +\%(\x\x \?\)\++ contained contains=xxdNull,xxdCrLf,xxdMbr nextgroup=xxdSepPlain
syn match xxdNull     +\c00\ze\%(\x\x\)*\>+    contained
syn match xxdCrLf     +\c0[ad]\ze\%(\x\x\)*\>+ contained
syn match xxdMbr      +\c55aa\ze \X+           contained

syn match xxdSepPlain + *\%(| *\)\?+ contained nextgroup=xxdMagic,xxdPlain

syn match xxdPlain    +.\++ contained contains=xxdDot
syn match xxdDot      +\.+ contained
syn match xxdMagic    +\%1l\%(\.ELF\|\w\+\|#!\%(/[a-zA-Z_0-9-]\+\)\+\)+ contained nextgroup=xxdPlain


hi def link xxdComment  Comment
hi def link xxdEmpty    Type
hi def link xxdAddress  Constant
hi def link xxdSepHex   Comment
hi def link xxdHex      Identifier
hi def link xxdNull     Whitespace
hi def link xxdCrLf     Special
hi def link xxdMbr      PreProc
hi def link xxdSepPlain Comment
hi def link xxdPlain    Statement
hi def link xxdMagic    Type
hi def link xxdDot      Whitespace


let b:current_syntax = "xxd"

" vim: ts=8 sw=2
