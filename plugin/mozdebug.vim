" Vim plugin for webpage debugging with MozRepl and Firefox
" Last change: 2011-07-21
" Maintainer: Leonid Shevtsov <leonid@shevtsov.me>
" License: WTFPL

""" SETUP """

let s:save_cpo = &cpoptions
set cpoptions&vim

" if exists("g:loaded_mozdebug")
"   finish
" endif
" let g:loaded_mozdebug=1

""" GLOBAL VARIABLES """

let g:MozreplServer="192.168.56.1 4242"
let g:MozreplDebug=0
let g:MozreplHighlightStyle = 'border: solid 2px #ff00ff !important;'

""" COMMAND BINDINGS """

if !exists(':Mozrepl')
  command -nargs=1 Mozrepl :call MozreplExecute(<q-args>)
endif

if !exists(':MozReload')
  command MozReload :call MozReload()
end

if !exists(':MozReloadCss')
  command MozReloadCss :call MozReloadCss()
end

""" PUBLIC FUNCTIONS """

" don't do alert() or confirm() or any other user-blocking function
function! MozreplExecute(mozrepl_command)
  if g:MozreplDebug
    exec '!echo "'.s:MozreplBuildWrapper(a:mozrepl_command).'" | nc '.g:MozreplServer
  else
    exec 'silent !echo "'.s:MozreplBuildWrapper(a:mozrepl_command).'" | nc -w 5 '.g:MozreplServer.' 2>&1 >/dev/null'
  endif
  if v:shell_error
    echo "Mozrepl @ ".g:MozreplServer." did not accept connection. Start Firefox, or check value of g:MozreplServer."
  end
endfunction

function! MozReload()
  call MozreplExecute('content.window.location.reload()')
endfunction

function! MozReloadCss()
  call MozreplExecute(
        \    'var  i,a,s;'.
        \    'a=content.document.getElementsByTagName("link");'.
        \    'for(i=0;i<a.length;i++){'.
        \      's=a[i];'.
        \      'if(s.rel.toLowerCase().indexOf("stylesheet")>=0 && s.href) {'.
        \        'var  h = s.href.replace( /(&|\?)forceReload=\d+/, "");'.
        \        's.href=h+(h.indexOf("?")>=0?"&":"?")+"forceReload="+(new  Date().valueOf())'.
        \      '}'.
        \    '}'
        \  )
endfunction

function! MozHighlightSelector(selector)
  call MozreplExecute(
        \    'var style=content.document.getElementById("vim-highlight-selector-style");'.
        \    'if (!style) {'.
        \      'style = content.document.createElement("STYLE");'.
        \      'style.type = "text/css";'.
        \      'style.id = "vim-highlight-selector-style";'.
        \      'content.document.getElementsByTagName("HEAD")[0].appendChild(style);'.
        \    '}'.
        \    'style.innerHTML = "'.a:selector.' { '. substitute(g:MozreplHighlightStyle,'#','\\#','g').' }";'
        \  )
endfunction

""" PRIVATE FUNCTIONS """

function! s:MozreplBuildWrapper(mozrepl_command)
  return substitute(a:mozrepl_command,'\(!\|\$\|`\|"\|\\\)','\\\1','g').';repl.quit();'
endfunction

""" TEARDOWN """

let &cpoptions = s:save_cpo
