if ((has('win32') || has('win64')) && has('pythonx'))
	let s:FuncSaveClipboardImageWin32 = 1
	function! s:SaveClipboardImageWin32(filename)
pythonx <<ENDOFPYTHON
import vim
from PIL import ImageGrab
from PIL import Image
ret = -1
try:
	filename = vim.eval('a:filename')
	im = ImageGrab.grabclipboard()
	if isinstance(im,Image.Image):
		im.save(filename,'PNG')
		ret = 0
except:
	ret = -1
ENDOFPYTHON
		return pyxeval('ret')
	endfunction
endif

function! s:SubstituteByDict(text, dict, escspecial, escshell)
	let l:ret = a:text
	for [l:key,l:val] in items(a:dict)
		if a:escspecial
			let l:val = substitute(l:val,'\\','\\\\','g') 
			let l:val = substitute(l:val,'&','\\\&','g') 
			let l:val = substitute(l:val,'\~','\\\~','g') 
			let l:val = substitute(l:val,'\r','\\\r','g') 
			let l:val = substitute(l:val,'\n','\\\n','g') 
		endif
		if a:escshell
			let l:val = shellescape(l:val)
		endif
		let l:ret = substitute(l:ret,l:key,l:val,'g')
	endfor
	return l:ret
endfunc

function! s:SaveClipboardImage(cmd, placeholder) abort
	let l:cmd = s:SubstituteByDict(a:cmd,a:placeholder,1,1)
	silent call system(l:cmd)
	return v:shell_error
endfunction

function! s:ClipImg(title, bang) abort
	if !empty(a:title)
		let l:title = a:title
	else
		let l:title = input('Title: ') 
	endif
	
	let l:filepath = expand('%:p:h')
	let l:subdir = ''
	if exists('g:clipimg_subdir')
		if type(g:clipimg_subdir) == v:t_func
			let l:subdir = g:clipimg_subdir(l:filepath,l:title)
		else
			let l:subdir = g:clipimg_subdir
		endif
	endif

	let l:filename = l:title
	if exists('g:clipimg_substitutes')
		let l:subst = g:clipimg_substitutes
	else
		let l:subst = { "[ \t\n*?{}`$\\/%#'\"|!<>.-]" : '' }
	endif
	if type(l:subst) == v:t_func
      let l:filename = l:subst(l:filepath, l:title)
	else
		let l:filename = s:SubstituteByDict(l:filename, l:subst, 0, 0)
	endif

	if l:subdir != ''
		let l:fullpath = l:filepath.'/'.l:subdir.'/'
		let l:relpath = l:subdir.'/'
	else
		let l:fullpath = l:filepath.'/' 
		let l:relpath = ''
	endif

	if !empty(glob(l:fullpath.l:filename.'.png'))
		let l:suffix = 1
		while !empty(glob(l:fullpath.l:filename.l:suffix.'.png'))
			let suffix = suffix+1
		endwhile
		let l:filename = l:filename.l:suffix
	endif

	let l:filename = l:filename.'.png'
	let l:fullfilename = l:fullpath.l:filename
	let l:relfilename = l:relpath.l:filename

	let l:placeholder = { '%FILENAME%' : l:filename, '%FULLFILENAME%' : l:fullfilename, '%RELFILENAME%' : l:relfilename, '%FULLPATH%' : l:fullpath, '%RELPATH%' : l:relpath, '%TITLE%' : a:title }

	let l:pngcliperr = -1
	if exists('g:clipimg_cmd') && !empty(g:clipimg_cmd)
		let l:pngcliperr = s:SaveClipboardImage(g:clipimg_cmd, l:placeholder)
	elseif exists('s:FuncSaveClipboardImageWin32')
		let l:pngcliperr = s:SaveClipboardImageWin32(l:fullfilename)
	elseif has('mac') && executable('pngpaste')
		let l:pngcliperr = s:SaveClipboardImage('pngpaste %FULLFILENAME%', l:placeholder)
	elseif executable('xclip')
		let l:pngcliperr = s:SaveClipboardImage('xclip -selection clipboard -t image/png -o >%FULLFILENAME%', l:placeholder)
	else
		echoerr 'Clipboard application not found'
	endif

	if l:pngcliperr == 0
		if exists('g:clipimg_imgtags')
			let l:imgtags = g:clipimg_imgtags
		else
			let l:imgtags = { 'markdown' : '![%TITLE%](%RELFILENAME%)' }
		endif

		let l:ft = &filetype
		if has_key(l:imgtags, l:ft)
			let l:imgtag = l:imgtags[l:ft]

			if type(l:imgtag) == v:t_func
				let l:imgtag = l:imgtag(l:placeholder)
			else
				let l:imgtag = s:SubstituteByDict(l:imgtag, l:placeholder, 1, 0)
			endif
			if l:imgtag != ''
				let l:regsave = @a
				let @a = l:imgtag
				if !a:bang
					put a
				else
					put! a
				endif
				let @a = l:regsave
			endif
		endif
	else
		echoerr 'No image found on clipboard'
	endif
endfunc

command! -nargs=* -bang ClipImg call <SID>ClipImg(<q-args>, <q-bang>=='!')
