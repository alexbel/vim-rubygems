if exists('g:rubygems_disabled') && g:rubygems_disabled == 1
  finish
endif

if globpath(&rtp, 'autoload/webapi/http.vim') == ''
  echohl ErrorMsg | echomsg "Rubygems: require 'webapi', install https://github.com/mattn/webapi-vim" | echohl None
  finish
endif

"
" Public
"
function! rubygems#Recent()
  let gem_name = s:gem_name_from_current_line()
  if empty(gem_name)
    return
  endif
  let gem_info = s:load_gem_info(gem_name)
  let output = 'Last version = '.gem_info.version
  echo output
endfunction

function! rubygems#Versions()
  let gem_name = s:gem_name_from_current_line()
  if empty(gem_name)
    return
  endif
  let gem_info = s:load_versions(gem_name)
  call s:show_versions(gem_info)
endfunction

function! rubygems#Info()
  let gem_name = s:gem_name_from_current_line()
  if empty(gem_name)
    return
  endif
  let gem_info = s:load_gem_info(gem_name)

  let str = "Last version: " . gem_info.version . "\<cr>"
  let str = str . "Authors: " . gem_info.authors . "\<cr>"
  let str = str . "Downloads: " . gem_info.version_downloads . "\<cr>"
  let str = str . "Source code uri: " . gem_info.source_code_uri . "\<cr>"
  let str = str . "Description: " . gem_info.info
  call s:render(str)
endfunction

function! rubygems#AppendVersion()
  let gem_name = s:gem_name_from_current_line()
  if empty(gem_name)
    return
  endif
  let gem_info = s:load_gem_info(gem_name)
  let gem_version = gem_info.version
  execute "normal! A, '~> ".gem_version."'"
endfunction

"
" Private
"
function! s:show_versions(info)
  let str = ''
  for v in a:info
    let str = str . v.number . " built at " . s:extract_date(v.built_at) . "\<cr>"
  endfor
  call s:render(str)
endfunction

function! s:render(str)
  silent keepalt belowright split Rubygems
  setlocal noswapfile nobuflisted nospell nowrap modifiable
  setlocal buftype=nofile bufhidden=hide
  1,$d

  execute "normal! I " . a:str

  normal! gg^h
  exec 'resize 5'
  setlocal nomodifiable filetype=rubygems
  nnoremap <silent> <buffer> q :q<CR>
endfunction

function! s:gem_name_from_current_line()
  let line = getline('.')
  let gem_name = s:extract_gem_name(line)
  return gem_name
endfunction

function! s:extract_gem_name(str)
  let str = split(a:str, ' ')
  if str[0] == 'gem'
    let gem_name = tolower(str[1])
    let gem_name = matchstr(gem_name, '[A-z-_]\+')
  else
    echohl ErrorMsg | echomsg "Can't find a gem name" | echohl None
    return
  endif
  return gem_name
endfunction

function! s:extract_date(str)
  let date = matchstr(a:str, '[0-9-]\+')
  return date
endfunction

function! s:load_gem_info(gem_name)
  let uri = 'https://rubygems.org/api/v1/gems/'.a:gem_name.'.json'
  let content = s:request(uri)
  return content
endfunction

function! s:load_versions(gem_name)
  let uri = 'https://rubygems.org/api/v1/versions/' .a:gem_name. '.json'
  let content = s:request(uri)
  return content
endfunction

function! s:request(uri)
  echomsg 'Requesting rubygems.com to look up information ...'
  let result = webapi#http#get(a:uri)
  let content = webapi#json#decode(result.content)
  redraw!
  return content
endfunction
