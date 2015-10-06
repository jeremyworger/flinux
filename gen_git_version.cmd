@echo off

rem 
rem This file is part of Foreign Linux.
rem 
rem Copyright (C) 2014, 2015 Xiangyan Sun <wishstudio@gmail.com>
rem 
rem This program is free software: you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation, either version 3 of the License, or
rem (at your option) any later version.
rem 
rem This program is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem GNU General Public License for more details.
rem 
rem You should have received a copy of the GNU General Public License
rem along with this program. If not, see <http://www.gnu.org/licenses/>.
rem 

setlocal ENABLEDELAYEDEXPANSION

set HEADER_FILE=%~p0\src\version.h

if not defined GIT (
	set GIT="git"
)

call !GIT! describe --tags > NUL 2> NUL
if errorlevel 1 (
	rem git not in path and GIT environment variable not set.
	rem Try default msysgit installation location.
	set GIT="%ProgramFiles(x86)%\Git\bin\git.exe"
	call !GIT! describe --tags > NUL 2> NUL
	if errorlevel 1 (
		rem Potential x64 version...
		rem Visual Studio runs in 32bit mode, so %ProgramFiles%
		rem points to "Program Files (x86)" which won't work.
		rem Therefore we use a hack here.
		set GIT="%ProgramFiles%\..\Program Files\Git\bin\git.exe"
	)
)

call !GIT! describe --tags > NUL 2> NUL
if errorlevel 1 (
	echo Git not found. Cannot update git_version.h file.
	echo Make sure git is in your path or set the GIT environment variable.
	echo We will now build as an unknown verison.
	set VERSION=unknown-version
) else (
	for /F %%i in ('call !GIT! describe --tags') do set VERSION=%%i
)

rem Don't modify the header if it already contains the current version
if exist "%HEADER_FILE%" (
	findstr /C:"%VERSION%" "%HEADER_FILE%" > NUL 2> NUL
	if not errorlevel 1 (
		goto done
	)
)

rem Generate the header file

echo /* Automatically generated by gen_git_version.cmd, do not modify */ > "%HEADER_FILE%"
echo #define GIT_VERSION "%VERSION%" >> "%HEADER_FILE%"

:done
