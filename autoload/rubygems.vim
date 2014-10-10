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

function! rubygems#Search(query)
  let uri = 'https://rubygems.org/api/v1/search.json?query=' . a:query
  let response = s:request(uri)
  let content = ''
  for gem in response
    let content = content . gem.name . ': ' . s:strip(gem.info) . "\<cr>"
  endfor
  call s:render(content)
endfunction

function! rubygems#clean_signs()
  sign unplace *
endfunction

function! rubygems#GemfileCheck()
  sign unplace *
  normal! gg
  call s:highlight_signs()
  let lines = getbufline(bufname('%'), 0, line('$'))
  let index = 0
  for line in lines
    let index += 1
    call s:update_cursor_position(index)
    let gem_name = s:extract_gem_name(line)
    let current_gem_version = s:extract_gem_version(line)

    if strlen(gem_name) < 2 || strlen(current_gem_version) < 2
      continue
    endif

    call s:hi_line(index, 'rubygem_checking')
    let gem_info = s:load_gem_info(gem_name)
    if s:compare_versions(current_gem_version, gem_info.version)
      call s:hi_line(index, 'rubygem_warning',)
    else
      exe "sign unplace ".index
    endif
  endfor
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
  setlocal nosmartindent noautoindent noswapfile nobuflisted nospell nowrap modifiable
  setlocal buftype=nofile bufhidden=hide
  1,$d

  execute "normal! I" . a:str

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
  if len(str) > 1 && str[0] == 'gem'
    let gem_name = tolower(str[1])
    let gem_name = matchstr(gem_name, '[A-z-_]\+')
    return gem_name
  else
    return
  endif
endfunction

function! s:extract_gem_version(str)
  let str = split(a:str, ' ')
  if len(str) > 2 && str[0] == 'gem'
    let gem_version = matchstr(str[-1], '[0-9.]\+')
    return gem_version
  else
    return
  endif
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

function! s:strip(input_str)
  let output_str = substitute(a:input_str, '^\s*\(.\{-}\)\s*$', '\1', '')
  let output_str = s:strip_last_new_line_char(output_str)
  return output_str
endfunction

function! s:strip_last_new_line_char(str)
  return substitute(a:str, '\n$', '', 'g')
endfunction

function! s:compare_versions(current, last)
  let current = split(a:current, '\.')
  let current_major = current[0]
  let current_minor = current[1]

  if len(current) == 3
    let current_patch = current[2]
  else
    let current_patch = 0
  end

  let last = split(a:last, '\.')
  let last_major = last[0]
  let last_minor = last[1]

  if len(last) == 3
    let last_patch = last[2]
  else
    let last_patch = 0
  endif

  if last_major > current_major
    return 1
  elseif last_minor > current_minor
    return 1
  elseif last_patch > current_patch
    return 1
  else
    return 0
  endif
endfunction

function! s:highlight_signs()
  highlight WarningSign term=standout ctermfg=yellow ctermbg=0
  highlight CheckingSign term=standout ctermfg=118 ctermbg=0
  sign define rubygem_warning text=⚠ texthl=WarningSign
  sign define rubygem_checking text=➡ texthl=CheckingSign
endfunction

function! s:hi_line(line_num, name)
  exe "sign place ".a:line_num." line=".a:line_num." name=".a:name." file=".bufname('%')
endfunction

function! s:update_cursor_position(index)
  call setpos('.', [bufname('%'), a:index, 0, 1])
  if &cursorline
    let current_cursorline_bg = synIDattr(synIDtrans(hlID('CursorLine')), 'bg')
    exe "highlight CursorLine ctermbg=".current_cursorline_bg
  endif
endfunction
