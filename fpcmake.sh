#!/bin/bash

if [ "$1" == "" ]; then
	echo "Utility to make the binaries without lazbuild."
	echo "Usage: ./fpcmake.sh [LAZARUS SOURCE DIRECTORY]"
	echo ""
	echo "To remove compiled files, type: make clean"
	exit 0
fi

LAZ=$1

if [ ! -d "$LAZ" ]; then
	echo "Lazarus directory not found"
fi

#creating resource
lazpaintrc="lazpaint/lazpaint.rc"
lazpaintres="lazpaint/lazpaint.res"
if [ ! -f "$lazpaintres" ]; then
	if [ "$(which windres)" != "" ]; then
		windres=windres
	elif [ "$(which i686-w64-mingw32-windres)" != "" ]; then
		windres=i686-w64-mingw32-windres
	elif [ "$(which x86_64-w64-mingw32-windres)" != "" ]; then
		windres=x86_64-w64-mingw32-windres
	else
		echo windres is necessary and is going to be installed.
		sudo apt-get install binutils-mingw-w64-i686
		if [ "$(which i686-w64-mingw32-windres)" != "" ]; then
			windres=i686-w64-mingw32-windres
		else
			echo windres is missing. Did you cancel the installation?
			exit 1
		fi
	fi
	echo "Generating $lazpaintres..."
	$($windres $lazpaintrc $lazpaintres --preprocessor cat)
	if [ ! -f "$lazpaintres" ]; then
		echo "Failed to generate $lazpaintres"
		exit 1
	fi
fi

#compiling

mkdir "lazpaint/release/lib"
pushd lazpaint
fpc -orelease/lazpaint -Fu./buttons -Fi./buttons -Fl./buttons -Fo./buttons -Fu./image -Fi./image -Fl./image -Fo./image -Fu./cursors -Fi./cursors -Fl./cursors -Fo./cursors -Fu./buttons -Fi./buttons -Fl./buttons -Fo./buttons -Fu./* -Fi./* -Fl./* -Fo./* -Fu../bgracontrols -Fi../bgracontrols -Fl../bgracontrols -Fo../bgracontrols -Fu../bgrabitmap -Fi../bgrabitmap -Fl../bgrabitmap -Fo../bgrabitmap -Fu$LAZ/* -Fi$LAZ/* -Fl$LAZ/* -Fo$LAZ/* -Fu$LAZ/components/printers/unix -Fi$LAZ/components/printers/unix -Fl$LAZ/components/printers/unix -Fo$LAZ/components/printers/unix -Fu$LAZ/packager/registration -Fi$LAZ/packager/registration -Fl$LAZ/packager/registration -Fo$LAZ/packager/registration -Fu$LAZ/components/* -Fi$LAZ/components/* -Fl$LAZ/components/* -Fo$LAZ/components/* -Fu$LAZ/lcl/forms -Fi$LAZ/lcl/forms -Fl$LAZ/lcl/forms -Fo$LAZ/lcl/forms -Fu$LAZ/lcl/widgetset -Fi$LAZ/lcl/widgetset -Fl$LAZ/lcl/widgetset -Fo$LAZ/lcl/widgetset -Fu$LAZ/interfaces/* -Fi$LAZ/interfaces/* -Fl$LAZ/interfaces/* -Fo$LAZ/interfaces/* -Fu$LAZ/lcl/nonwin32 -Fi$LAZ/lcl/nonwin32 -Fl$LAZ/lcl/nonwin32 -Fo$LAZ/lcl/nonwin32 -Fu$LAZ/lcl/interfaces/gtk2 -Fi$LAZ/lcl/interfaces/gtk2 -Fl$LAZ/lcl/interfaces/gtk2 -Fo$LAZ/lcl/interfaces/gtk2 -Fu$LAZ/lcl/components/* -Fi$LAZ/lcl/components/* -Fl$LAZ/lcl/components/* -Fo$LAZ/lcl/components/* -Fu$LAZ/lcl/include -Fi$LAZ/lcl/include -Fl$LAZ/lcl/include -Fo$LAZ/lcl/include -Fu$LAZ/lcl -Fi$LAZ/lcl -Fl$LAZ/lcl -Fo$LAZ/lcl -MObjFPC -Scgi -Cg -OoREGVAR -Xs -XX -l -vewnhibq -O3 -XX -CX -Xs -vi -FUrelease/lib/ -dLCL -dLCLgtk2 lazpaint.lpr
popd

