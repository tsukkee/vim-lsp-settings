function! s:get_current_ts_path() abort
  let ts_path = '/node_modules/typescript/lib'

  let project_dir = lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'package.json')
  let tsserverlibrary_path = project_dir .. ts_path

  let server_dir = lsp_settings#servers_dir() .. '/volar-server'
  let fallback_path = server_dir . ts_path

  let path = filereadable(tsserverlibrary_path) ? tsserverlibrary_path : fallback_path
  return {
  \   'tsdk': path,
  \ }
endfunction

function! Vim_lsp_settings_volar_setup_ts_path(options) abort
  let initialization_options = deepcopy(a:options)
  let initialization_options['typescript'] = s:get_current_ts_path()
  return initialization_options
endfunction

" cf. https://github.com/johnsoncodehk/volar/blob/master/packages/language-server/src/types.ts#L102
let g:vim_lsp_settings_volar_options = {
\   'textDocumentSync': 2,
\   'typescript': {
\     'tsdk': '',
\   },
\ }

augroup vim_lsp_settings_volar_server
  au!
  LspRegisterServer {
  \ 'name': 'volar-server',
  \ 'cmd': {server_info->lsp_settings#get('volar-server', 'cmd', [lsp_settings#exec_path('volar-server')]+lsp_settings#get('volar-server', 'args', ['--stdio']))},
  \ 'root_uri':{server_info->lsp_settings#get('volar-server', 'root_uri', lsp_settings#root_uri('volar-server'))},
  \ 'initialization_options': lsp_settings#get('volar-server', 'initialization_options', Vim_lsp_settings_volar_setup_ts_path(g:vim_lsp_settings_volar_options)),
  \ 'allowlist': lsp_settings#get('volar-server', 'allowlist', ['vue', 'typescript']),
  \ 'blocklist': lsp_settings#get('volar-server', 'blocklist', []),
  \ 'config': lsp_settings#get('volar-server', 'config', lsp_settings#server_config('volar-server')),
  \ }
augroup END

function! s:on_lsp_buffer_enabled() abort
  " check typescript-language-server
  let ts_server_dir = lsp_settings#servers_dir() .. '/typescript-language-server'
  if !isdirectory(ts_server_dir)
    call lsp_settings#utils#warning('Please install typescript-language-server to enable Vue support')
  endif

  " check the filetype setting
  if !exists('g:lsp_settings_filetype_vue') ||
  \ index(g:lsp_settings_filetype_vue, 'volar-server') == -1 ||
  \ index(g:lsp_settings_filetype_vue, 'typescript-language-server') == -1
    call lsp_settings#utils#warning('Both ''volar-server'' and ''typescript-language-server'' should be included in g:lsp_settings_filetype_vue to enable Vue support')
  endif
endfunction

augroup lsp_install_volar_server
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
