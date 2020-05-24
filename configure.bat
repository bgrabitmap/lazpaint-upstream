@echo off
echo For help type: configure /?
set wantedlazdir=

:nextparam
set param=%~1
if "%param%" == "" goto endparam
if "%param%" == "--help" goto showhelp
if "%param%" == "-h" goto showhelp
if "%param%" == "/help" goto showhelp
if "%param%" == "/?" goto showhelp
if "%param:~0,9%" == "--lazdir=" (
	set wantedlazdir=%param:~9%
) else if "%param%" == "--lazdir" (
	set wantedlazdir=%~2
	shift
) else (
	echo Error: unknown option %param%
	exit /b 1
)

shift
goto nextparam
:endparam

<nul set /p ".=%wantedlazdir%" >lazdir
if "%wantedlazdir%" == "" (
	echo Using lazbuild
	lazbuild -h > NUL 2> NUL
	if errorlevel 1 (
		echo Error: Lazarus needs to be in the PATH
		exit /b 1
	)
) else (
	echo Using FPC with Lazarus source: %wantedlazdir%
	if not exist "%wantedlazdir%\" (
		echo Error: directory not found
		exit /b 1
	) else if not exist "%wantedlazdir%\lcl\" (
		echo Warning: it does not seem to be the directory of Lazarus!
	)
	fpc -h > NUL 2> NUL
	if errorlevel 1 (
		echo Error: FPC needs to be in the PATH
		exit /b 1
	)
)

echo You can now type: make
exit /b 0

:showhelp
echo Usage: configure [OPTIONS]
echo.
echo     --lazdir=BASE_DIRECTORY_OF_LAZARUS
echo         Specifies to compile with FPC using the specified Lazarus sources.
echo         Otherwise lazbuild will be used.
