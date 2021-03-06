" Stuff for early dev
"map <leader><leader>j :TwoNote<enter>
"map <leader><leader>k :call TwoNoteInit()<enter>

source $HOME/.vim/bundle/twonote-vim/plugin/config.vim

" Start plugin
augroup _twonote_init
autocmd!
execute "autocmd BufReadPost " . g:_twonote_path . "* :TwoNoteHook"
execute "autocmd BufReadPre " . g:_twonote_path . "* call TwoNotePre()"
augroup END

" Creating commands for commands to be used externally
command! TwoNote call TwoNote()
command! TwoNoteInit call TwoNoteInit()
command! TwoNoteHook call TwoNoteHook()

" Call to create a new note.
" TwoNoteInit must have been called prior to calling
" Creates a new note in the YYYY/MM/DD/ folder with name RFC3222.md
" Adds this note to the note repo and commits it
" Then it opens this note in a new buffer
function! TwoNote()
	let _twonote_datepath=strftime("%Y/%m/%d/")
	let _twonote_RFC3339=strftime("%FT%T%z")
	let _twonote_note_path = g:_twonote_path . _twonote_datepath . _twonote_RFC3339 . ".md"
	execute ":silent !mkdir -p " . g:_twonote_path  . _twonote_datepath
	execute ":redraw!"
	execute ":silent !touch " . _twonote_note_path
	execute ":redraw!"


	let _twonote_gitadd = "git add " . _twonote_note_path . ";"

	let _twonote_utc = strftime("%s")
	execute ":silent !cd " . g:_twonote_path . ";" . _twonote_gitadd . "git commit -m \"" . _twonote_RFC3339 . ".md created at " . _twonote_utc . "\""
	execute ":redraw!"
	execute ":e " . _twonote_note_path
endfunction


function! TwoNoteInit()
	execute ":silent !mkdir -p " . g:_twonote_path
	execute "lcd " . g:_twonote_path
	execute ":silent !git init"
	execute ":silent !git remote add origin ". g:_notes_remotes
	execute ":silent !git remote set-url origin ". g:_notes_remotes
	execute ":silent silent !git pull -u origin master"
	execute ":!git branch --set-upstream-to=origin/master master"
	execute ":redraw!"
endfunction

function! TwoNoteUtil()
endfunction

function! TwoNoteHook()
	let _twonote_note_path=expand('%:p')
	let _twonote_RFC3339_md=expand('%:t')
	lcd %:p:h
	let _twonote_gitadd = "git add " . _twonote_note_path . ";"
	let autoWriteCMD="silent ! " . _twonote_gitadd . "git commit -m 'Updating " . _twonote_RFC3339_md . "'"
	execute ":autocmd BufWritePost " . _twonote_note_path . " :execute \"" . autoWriteCMD . "\""
	execute "autocmd BufWritePost " . _twonote_note_path . " :execute 'redraw!'"
	execute "autocmd BufUnload " . g:_twonote_path . "* call TwoNotePost()"
endfunction

function! TwoNotePre()
	echom 'pulling notes... '
	execute ":silent ! cd " . g:_twonote_path
	let g:_twonote_message = system("cd " . g:_twonote_path . "; git pull")
	execute ":redraw!"
	echom g:_twonote_message
endfunction

function! TwoNotePost()
	echom 'pushing notes... '
	execute ":silent ! cd " . g:_twonote_path . "; git push"
	execute ":redraw!"
endfunction
