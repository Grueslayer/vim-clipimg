# vim-clipimg

Saves an image from clipboard to a file and creates an image link with given description for the current filetype.

## Prerequisites

For Windows systems you need a python installation accessible from VIM and the
Python Pillow package (https://github.com/python-pillow/Pillow).

For Un*x like systems the application `xclip` will be used by default to copy
the content from the system clipboard.

MacOS X needs `pgppaste` from https://github.com/jcsalterego/pngpaste 

## Installing

Install using your favorite (or the build-in) plugin manager, e.g.

### vim-plug

Add the following configuration to your .vimrc

```vim
Plug 'grueslayer/vim-clipimg'
``` 

and install with :PlugInstall.


## Configuration

### g:clipimg_cmd

This shell command will be used to write the content from the clipboard to a
file. The placeholder `%FULLFILENAME%` will be replaced by an escaped filename
with complete path.

- Win32: `""` (Python is used)
- MacOS: `"pngpaste %FULLFILENAME"`
- Un*x:  `"xclip -selection clipboard -t image/png -o >%FULLFILENAME%"`


### g:clipimg_subdir

The images will be saved in the directory containing the current editing file.

If a string is given, the content is used as a sub directory which must
exists.

Otherwise you can use a callback funtion from type

```vim
 function subdir(filepath, title)
```

returning the relative path to the given directory.

Example:

```vim
 let g:clipimg_subdir = 'img'
```

### g:clipimg_substitutes

The filename will be generated from the title therefore non valid characters like * or ? should be replaced.

You can give a dictionary with search and replace pattern used for substitute().

Otherwise you can use a callback funtion from type

```vim
 function subst(filepath, title)
```

returning the filename.

Example:

```vim
 let l:subst = { "[ \t\n*?{}`$\\/%#'\"|!<>.-]" : '' }
```

### g:clipimg_imgtags

Contains a dictionary with filetype and a line for the current file format.

These placeholders can be used

- %FULLFILENAME% Filename with full path
- %FILENAME% Filename with extension (without path)
- %RELFILENAME% Filename with relative path
- %FULLPATH% Path without filename
- %RELPATH% Relative path without filename
- %TITLE% Description

If you want to have more control, a function with this prototyp can be used
instead of a string with placeholders returning the text:

```vim
 function imgtag(placeholderdict)
```

Example:

```vim
 let l:imgtags = { 'markdown' : '![%TITLE%](%RELFILENAME%)' }
```

## Commands

### ClipImg

```vim
    :ClipImg title
```

Saves the image content to a file using `g:clipimg_subdir` and `g:clipimg_substitutes` for building the filename and `g:clipimg_subdir` for saving.

An image link will been put at the current cursor position if defined for the current file type in `g:clipimg_imgtags`.

## Authors

See list of [contributors](https://github.com/grueslayer/vim-cliphtml/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

