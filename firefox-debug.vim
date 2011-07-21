let g:MozreplServer="192.168.56.1 4242"
let g:MozreplDebug=0
let g:MozreplHighlightStyle = 'border: solid 2px #ff00ff !important;'

function! MozreplBuildWrapper(mozrepl_command)
  return substitute(a:mozrepl_command,'\(!\|\$\|`\|"\|\\\)','\\\1','g').';repl.quit();'
endfunction

" don't do alert() or confirm() or any other user-blocking function
function! MozreplExecute(mozrepl_command)
  if g:MozreplDebug
    exec '!echo "'.MozreplBuildWrapper(a:mozrepl_command).'" | nc '.g:MozreplServer
  else
    exec 'silent !echo "'.MozreplBuildWrapper(a:mozrepl_command).'" | nc '.g:MozreplServer.' 2>&1 >/dev/null'
  endif
endfunction

function! Refresh()
  call MozreplExecute('content.window.location.reload()')
endfunction

function! ReloadCss()
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

function! HighlightSelector(selector)
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


