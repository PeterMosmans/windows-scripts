@echo off
setlocal enabledelayedexpansion

REM start_emacs - Starts Emacs (either the server or a client)

REM Copyright (C) 2013-2015 Peter Mosmans
REM                         <support AT go-forward.net>
REM
REM This program is free software: you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.

REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
REM GNU General Public License for more details.

REM You should have received a copy of the GNU General Public License
REM along with this program. If not, see http://www.gnu.org/licenses/.


set NAME=start_emacs

REM Use defaults if global settings aren't set
if /i "%EMACSDIR%"=="" set EMACSDIR=%PROGRAMFILES%\Emacs\bin

set CLIENTPROGRAM="%EMACSDIR%\emacsclientw.exe"
set SERVERPROGRAM="%EMACSDIR%\runemacs.exe"
set PARAMETERS=-q -a %SERVERPROGRAM%
set SERVERFILE="%APPDATA%\.emacs.d\server\server"
set SERVER=%SERVERPROGRAM% %EMACSVARIABLES%
set SCRIPTNAME="%~dp0%0"


:PARSEOPTIONS
if "%1"=="--help" (
    call :SHOWHELP
    goto EXIT
)
call :CHECKPREREQUISITES
if "%1"=="--install" (
    call :INSTALL
    goto EXIT
)
if "%1"=="--kill" (
    call :KILLSERVER
    goto EXIT
)

:STARTEMACS
if not exist %SERVERFILE% (
    REM make sure that the Emacs server is running
    start "" %SERVER% %*
) else (
    if "%1"=="" (
        REM create a new frame if no parameters were given
        %CLIENTPROGRAM% -c
    ) else (
        %CLIENTPROGRAM% %*
    )
    if %ERRORLEVEL% GTR 0 (
        echo Emacs server is running ^(use --kill to kill serverfile^)
    )
)
goto EXIT

REM subroutines
:CHECKPERMISSIONS
net session >nul 2>&1
if %errorlevel%==0 set ADMINISTRATOR=TRUE
exit /b

REM check all the prerequisites...
:CHECKPREREQUISITES
if not exist %CLIENTPROGRAM% (
    echo Could not find %CLIENTPROGRAM%
    echo Make sure to set the ^(global^) variable EMACSDIR and point it to the
    echo directory where the Emacs binaries reside.
    echo exiting...
    goto EXIT
)
REM check if the script is called from within a subshell (eg. bash/MSYS)
if not "%SHELL%"=="" (
    set SCRIPTNAME="%0"
)
REM check if the script is called by Git
if "%GIT_AUTHOR_EMAIL%"=="" (
    REM if not, assume it's not interactive so do not wait for Emacs to finish
    set CLIENTPROGRAM=!CLIENTPROGRAM! -n
)
exit /b

:INSTALL
echo current file type association for txtfile:
ftype txtfile
call :CHECKPERMISSIONS
if "%ADMINISTRATOR%"=="TRUE" (
    ftype txtfile=%SCRIPTNAME% "%%1" 2>nul
    echo new file type association for txtfile:
    ftype txtfile
) else (
    echo You need to be administrator to change file type associations...
)
exit /B

:KILLSERVER
if exist %SERVERFILE% (
    %CLIENTPROGRAM% -e "(kill-emacs)"
    sleep 2
    if exist %SERVERFILE% (
        del /f /q %SERVERFILE%
        echo removed serverfile %SERVERFILE%
    )
)
exit /B

:SHOWHELP
echo usage: %SCRIPTNAME% inputfile
echo.
echo options: --help     Show usage
echo          --install  Create Windows startup bindings for textfiles
echo          --kill     Force server to stop ^(without saving^)
exit /B


:EXIT
if %ERRORLEVEL% GTR 0 (
    echo Something went wrong...
)
endlocal
