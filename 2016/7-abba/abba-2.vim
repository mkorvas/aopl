set nogdefault
" Double each line.
%s/.*/\0\r\0
" Keep only hypernet sequences on odd lines.
for lineno in range(1, line("$"), 2)
	exe lineno . 's#\%(^\|[]]\)[^[]*\%([[]\|$\)#:#g'
endfor
" Keep only supernet sequences on even lines.
for lineno in range(2, line("$"), 2)
	exe lineno . 's#[[][^]]*[]]#:#g'
endfor
" Join the lines again.
%s/^\(.*\)\n/\1\t
" Count the SSL IPs.
%s#\([^:]\)\(\1\@![^:]\)\1.*\t.*\2\1\2##n
