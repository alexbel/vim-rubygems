if exists('g:rubygems_loaded')
  finish
endif
let g:rubygems_loaded = 1

command -nargs=0 RubygemsRecentVersion :call rubygems#Recent()
command -nargs=0 RubygemsGemInfo :call rubygems#Info()
command -nargs=0 RubygemsVersions :call rubygems#Versions()
command -nargs=0 RubygemsAppendVersion :call rubygems#AppendVersion()
