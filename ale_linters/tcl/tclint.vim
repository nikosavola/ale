" Author: Niko Savola <niko.savola@gmail.com>
" Description: tclint linter for tcl files

call ale#Set('tcl_tclint_executable', 'tclint')
call ale#Set('tcl_tclint_options', '')

function! ale_linters#tcl#tclint#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'tcl_tclint_options')

    return '%e' . ale#Pad(l:options) . ' -'
endfunction

function! ale_linters#tcl#tclint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " stdin:1:6: unnecessary command substitution within expression [redundant-expr]
    " stdin:2:3: too many args for puts: got 5, expected no more than 3 [command-args]
    let l:pattern = '\v^[^:]+:(\d+):(\d+): (.+) \[([^\]]+)\]$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \   'code': l:match[4],
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('tcl', {
\   'name': 'tclint',
\   'output_stream': 'stdout',
\   'executable': {b -> ale#Var(b, 'tcl_tclint_executable')},
\   'command': function('ale_linters#tcl#tclint#GetCommand'),
\   'callback': 'ale_linters#tcl#tclint#Handle',
\})
