ifeq ($(OS),Windows_NT)     # true for Windows_NT or later
  SHELL := C:/Windows/System32/cmd.exe /c
  UNAME := Windows
  COPY := winmake\copyfile
  REMOVE := winmake\remove
  REMOVEDIR := winmake\removedir
  CREATEDIR := winmake\createdir
  ECHOFILE := type
  THEN := &
  RUN :=
else
  SHELL := /bin/bash
  UNAME := $(shell uname)
  COPY := cp
  REMOVE := rm -f
  REMOVEDIR := rm -rf
  CREATEDIR := mkdir -p
  ECHOFILE := cat
  THEN := ;
  RUN := ./
endif

lazdir := $(shell $(ECHOFILE) lazdir)
fpcbin = $(shell $(ECHOFILE) fpcbin)

ifeq ($(UNAME),Linux)
  prefix := $(shell $(ECHOFILE) prefix)
  USER_DIR = $(DESTDIR)$(prefix)
  BIN_DIR = $(USER_DIR)/bin
  SHARE_DIR=$(USER_DIR)/share
  RESOURCE_DIR=$(SHARE_DIR)/lazpaint
  DOC_DIR=$(SHARE_DIR)/doc/lazpaint
  ICON_DIR=$(SHARE_DIR)/icons/hicolor
  SOURCE_BIN_DIR=lazpaint/release
  SOURCE_DEBIAN_DIR=debian
  PO_FILES:=$(shell find "$(SOURCE_BIN_DIR)/i18n" -maxdepth 1 -type f -name *.po -printf "\"%f\" ")
  MODEL_FILES:=$(shell find "$(SOURCE_BIN_DIR)/models" -maxdepth 1 -type f -printf "\"%f\" ")
  ICON:=lazpaint/lazpaint.ico
  ICONS:=$(shell identify $(ICON) | awk -F '[[]|[]] | ' '{ printf "[%s]=%s ", $$2, $$4 }')
  INTERFACE:=LCLgtk2
  LAZARUSDIRECTORIES:="-Fu$(lazdir)/*" "-Fi$(lazdir)/*" "-Fu$(lazdir)/components/printers/unix" "-Fi$(lazdir)/components/printers/unix" "-Fu$(lazdir)/packager/registration" "-Fi$(lazdir)/packager/registration" "-Fu$(lazdir)/components/*" "-Fi$(lazdir)/components/*" "-Fu$(lazdir)/lcl/forms" "-Fi$(lazdir)/lcl/forms" "-Fu$(lazdir)/lcl/widgetset" "-Fi$(lazdir)/lcl/widgetset" "-Fu$(lazdir)/interfaces/*" "-Fi$(lazdir)/interfaces/*" "-Fu$(lazdir)/lcl/nonwin32" "-Fi$(lazdir)/lcl/nonwin32" "-Fu$(lazdir)/lcl/interfaces/gtk2" "-Fi$(lazdir)/lcl/interfaces/gtk2" "-Fu$(lazdir)/lcl/components/*" "-Fi$(lazdir)/lcl/components/*" "-Fu$(lazdir)/lcl/include" "-Fi$(lazdir)/lcl/include" "-Fu$(lazdir)/lcl" "-Fi$(lazdir)/lcl"
endif

ifeq ($(UNAME),FreeBSD)
  INTERFACE:=LCLgtk2
  LAZARUSDIRECTORIES:="-Fu$(lazdir)/*" "-Fi$(lazdir)/*" "-Fu$(lazdir)/components/printers/unix" "-Fi$(lazdir)/components/printers/unix" "-Fu$(lazdir)/packager/registration" "-Fi$(lazdir)/packager/registration" "-Fu$(lazdir)/components/*" "-Fi$(lazdir)/components/*" "-Fu$(lazdir)/lcl/forms" "-Fi$(lazdir)/lcl/forms" "-Fu$(lazdir)/lcl/widgetset" "-Fi$(lazdir)/lcl/widgetset" "-Fu$(lazdir)/interfaces/*" "-Fi$(lazdir)/interfaces/*" "-Fu$(lazdir)/lcl/nonwin32" "-Fi$(lazdir)/lcl/nonwin32" "-Fu$(lazdir)/lcl/interfaces/gtk2" "-Fi$(lazdir)/lcl/interfaces/gtk2" "-Fu$(lazdir)/lcl/components/*" "-Fi$(lazdir)/lcl/components/*" "-Fu$(lazdir)/lcl/include" "-Fi$(lazdir)/lcl/include" "-Fu$(lazdir)/lcl" "-Fi$(lazdir)/lcl"
endif

ifeq ($(UNAME),Windows)
  INTERFACE:=LCLwin32
  LAZARUSDIRECTORIES:="-Fu$(lazdir)/*" "-Fi$(lazdir)/*" "-Fu$(lazdir)/components/printers/win32" "-Fi$(lazdir)/components/printers/win32" "-Fu$(lazdir)/packager/registration" "-Fi$(lazdir)/packager/registration" "-Fu$(lazdir)/components/*" "-Fi$(lazdir)/components/*" "-Fu$(lazdir)/lcl/forms" "-Fi$(lazdir)/lcl/forms" "-Fu$(lazdir)/lcl/widgetset" "-Fi$(lazdir)/lcl/widgetset" "-Fu$(lazdir)/interfaces/*" "-Fi$(lazdir)/interfaces/*" "-Fu$(lazdir)/lcl/interfaces/win32" "-Fi$(lazdir)/lcl/interfaces/win32" "-Fu$(lazdir)/lcl/components/*" "-Fi$(lazdir)/lcl/components/*" "-Fu$(lazdir)/lcl/include" "-Fi$(lazdir)/lcl/include" "-Fu$(lazdir)/lcl" "-Fi$(lazdir)/lcl"
endif

all: compile

install: prefix
ifeq ($(UNAME),Windows) 
	echo "Use installation made by InnoSetup with \"lazpaint\lazpaint.iss\""
endif

ifeq ($(UNAME),Linux)
	install -D "$(SOURCE_BIN_DIR)/lazpaint" "$(BIN_DIR)/lazpaint"
	for f in $(PO_FILES); do install -D --mode=0644 "$(SOURCE_BIN_DIR)/i18n/$$f" "${RESOURCE_DIR}/i18n/$$f"; done
	for f in $(MODEL_FILES); do install -D --mode=0644 "$(SOURCE_BIN_DIR)/models/$$f" "${RESOURCE_DIR}/models/$$f"; done
	install -D "$(SOURCE_DEBIAN_DIR)/applications/lazpaint.desktop" "$(SHARE_DIR)/applications/lazpaint.desktop"
	install -D "$(SOURCE_DEBIAN_DIR)/pixmaps/lazpaint.png" "$(SHARE_DIR)/pixmaps/lazpaint.png"
	declare -A icons=($(ICONS)); for s in "$${icons[@]}"; do install -D --mode=0644 icons/$$s.png $(ICON_DIR)/$$s/apps/lazpaint.png; done
	install -d "$(SHARE_DIR)/man/man1"
	gzip -9 -n -c "$(SOURCE_DEBIAN_DIR)/man/man1/lazpaint.1" >"$(SHARE_DIR)/man/man1/lazpaint.1.gz"
	chmod 0644 "$(SHARE_DIR)/man/man1/lazpaint.1.gz"
	install -d "$(DOC_DIR)"
	gzip -9 -n -c "$(SOURCE_DEBIAN_DIR)/changelog" >"$(DOC_DIR)/changelog.gz"
	chmod 0644 "$(DOC_DIR)/changelog.gz"
	install --mode=0644 "$(SOURCE_DEBIAN_DIR)/copyright" "$(DOC_DIR)/copyright"
	install --mode=0644 "$(SOURCE_BIN_DIR)/readme.txt" "$(DOC_DIR)/README"
endif

install_icons:

uninstall: prefix
ifeq ($(UNAME),Windows) 
	echo "Go to Add/Remove programs to uninstall"
endif

ifeq ($(UNAME),Linux)
	$(REMOVE) $(BIN_DIR)/lazpaint
	$(REMOVEDIR) $(RESOURCE_DIR)
	$(REMOVE) "$(SHARE_DIR)/applications/lazpaint.desktop"
	declare -A icons=($(ICONS)); for s in "$${icons[@]}"; do $(REMOVE) $(ICON_DIR)/$$s/apps/lazpaint.png; done
	$(REMOVE) "$(SHARE_DIR)/pixmaps/lazpaint.png"
	$(REMOVE) "$(SHARE_DIR)/man/man1/lazpaint.1.gz"
	$(REMOVEDIR) $(DOC_DIR)
endif

distclean: clean clean_configure
clean: clean_bgrabitmap clean_bgracontrols clean_lazpaint

clean_configure:
	$(REMOVE) "prefix"
	$(REMOVE) "lazdir"
	$(REMOVE) "fpcbin"
	$(REMOVE) "debian/CONFIGURE_DEFAULT_LAZDIR"

clean_icons:
	$(REMOVEDIR) "icons"

clean_bgrabitmap:
	$(REMOVEDIR) "bgrabitmap/lib"
	$(REMOVEDIR) "bgrabitmap/backup"

clean_bgracontrols:
	$(REMOVEDIR) "bgracontrols/lib"
	$(REMOVEDIR) "bgracontrols/backup"

clean_lazpaint:
	$(REMOVEDIR) "lazpaint/debug"
	$(REMOVEDIR) "lazpaint/release/lib"
	$(REMOVE) "lazpaint/lazpaint.res"
	$(REMOVE) "lazpaint/release/lazpaint"
	$(REMOVE) "lazpaint/release/lazpaint32.exe"
	$(REMOVE) "lazpaint/release/lazpaint_x64.exe"
	$(REMOVEDIR) "lazpaint/backup"
	$(REMOVEDIR) "lazpaint/test_embedded/backup"

compile: lazdir bgrabitmap bgracontrols lazpaint
force:
	echo lazbuild or fpc will determine what to recompile

bgrabitmap: force bgrabitmap/bgrabitmappack.lpk
ifeq "$(lazdir)" ""
	lazbuild bgrabitmap/bgrabitmappack.lpk
endif

bgracontrols: force bgracontrols/bgracontrols.lpk
ifeq "$(lazdir)" ""
	lazbuild bgracontrols/bgracontrols.lpk
endif

lazpaint: force lazpaint/lazpaint.lpi
ifeq "$(lazdir)" ""
	lazbuild lazpaint/lazpaint.lpi
else
	$(RUN)makeres
	$(CREATEDIR) "lazpaint/release/lib"
	cd lazpaint $(THEN) $(fpcbin) -orelease/lazpaint -Fu./buttons -Fi./buttons -Fu./image -Fi./image -Fu./cursors -Fi./cursors -Fu./buttons -Fi./buttons -Fu./* -Fi./* -Fu../bgracontrols -Fi../bgracontrols -Fu../bgrabitmap -Fi../bgrabitmap $(LAZARUSDIRECTORIES) -MObjFPC -Scgi -Cg -OoREGVAR -Xs -XX -l -vewnhibq -O3 -CX -vi -FUrelease/lib/ -dLCL -d$(INTERFACE) lazpaint.lpr
endif

icons:
ifneq ($(UNAME),Windows)
	$(CREATEDIR) -p icons
	declare -A icons=($(ICONS)); for i in "$${!icons[@]}"; do convert $(ICON)[$$i] icons/$${icons[$$i]}.png; done
endif

