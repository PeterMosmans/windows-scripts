# windows-scripts
Various short Windows command shell scripts. GPLv3 licensed, so feel free to use them as you see fit.

## start_emacs.cmd
Command shell script to start Emacs. When called from git, it will wait until the commit message has been saved.
This means that you can use it as editor for git, eg.:

`git config --global core.editor=c:/scripts/start_emacs.cmd`

The script also works when called from another shell, like MSYS or MSYS2.

Emacs shell extensions for textfiles can be created by using the `--install` option

```
usage: "start_emacs.cmd" inputfile

options: --help     Show usage
         --install  Create Windows startup bindings for textfiles
         --kill     Force server to stop (without saving)
```