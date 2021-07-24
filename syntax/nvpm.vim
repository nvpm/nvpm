syntax match nvpmprojwksp  '^\s*workspace'
syntax match nvpmprojtabs  '^\s*tab'
syntax match nvpmprojbuff  '^\s*buff'
syntax match nvpmprojterm  '^\s*term'

" syntax match nvpmdwksp '^\s*\*\s*workspace\s*\(.*\)'
" syntax match nvpmdtabs '^\s*\*\s*tab\s*\(.*\)'
syntax region nvpmprojdwksp start=/^\s*\*\s*workspace/ end=/^\s*workspace/me=s-9
syntax region nvpmprojdtabs start=/^\s*\*\s*tab/ end=/^\s*tab\|workspace/me=s-9
syntax match  nvpmprojdbuff '^\s*\*\s*buff\s*\(.*\)'
syntax match  nvpmprojdterm '^\s*\*\s*term\s*\(.*\)'

" syntax match  nvpmprojcomment '^\/\/.*$'
syntax match  nvpmprojcomment '^\s*\#.*'
 

syntax match nvpmprojcommentnotes /\/\/\sNote:/he=e-1

syntax match nvpmprojpath  '\s*:\s*\(\~*\/*\.*\-*\w*\s*\w*\)*\/*\w*\.*\w*\s*$'

hi default link nvpmprojwksp  Include
hi default link nvpmprojtabs  Include
hi default link nvpmprojbuff  Include
hi default link nvpmprojterm  Include

hi default link nvpmprojdwksp Comment
hi default link nvpmprojdtabs Comment
hi default link nvpmprojdbuff Comment
hi default link nvpmprojdterm Comment
hi default link nvpmprojcomment Comment

hi default link nvpmprojcommentnotes Todo

hi default link nvpmprojpath  Operator

let b:current_syntax = "nvpm"
