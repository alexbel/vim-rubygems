if exists('b:current_syntax')
  finish
endif

setlocal iskeyword+=:
syn case ignore

syn match name "[A-Za-z ]\+:\s"
syn match valueNumber "\d\+"

highlight link name Statement
highlight link valueNumber Number

let b:current_syntax = 'rubygems'
