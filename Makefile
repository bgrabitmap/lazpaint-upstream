# On Linux, TARGET can be Gtk2 (default) or Qt5
# On FreeBSD, TARGET can be Gtk2 (default) or Qt5
# On Windows, TARGET can be Win32 (default) or Qt5

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
  UNAME := $(shell uname)
  ifeq ($(UNAME),FreeBSD)
    SHELL := /usr/local/bin/bash
  else
    SHELL := /bin/bash
  endif
  COPY := cp
  REMOVE := rm -f
  REMOVEDIR := rm -rf
  CREATEDIR := mkdir -p
  ECHOFILE := cat
  THEN := ;
  RUN := ./
endif

lazdir := $(shell $(ECHOFILE) lazdir)
fpcbin := $(shell $(ECHOFILE) fpcbin)
package := lazpaint

ifeq ($(UNAME),Linux)
  TARGET ?= Gtk2
  prefix := $(shell $(ECHOFILE) prefix)
  ifeq ($(MULTIBIN),1)
    package := lazpaint-$(shell echo $(TARGET) | tr A-Z a-z)
    prefix := /../$(package)$(prefix)
  endif
  USER_DIR = $(DESTDIR)$(prefix)
  BIN_DIR = $(USER_DIR)/bin
  SHARE_DIR=$(USER_DIR)/share
  RESOURCE_DIR=$(SHARE_DIR)/lazpaint
  DOC_DIR=$(SHARE_DIR)/doc/$(package)
  ICON_DIR=$(SHARE_DIR)/icons/hicolor
  SOURCE_BIN_DIR=lazpaint/release
  SOURCE_DEBIAN_DIR=debian
  SOURCE_DEBIAN_UPSTREAM=debian-upstream
  PO_FILES:=$(shell find "$(SOURCE_BIN_DIR)/i18n" -maxdepth 1 -type f -name *.po -printf "\"%f\" ")
  MODEL_FILES:=$(shell find "$(SOURCE_BIN_DIR)/models" -maxdepth 1 -type f -printf "\"%f\" ")
  ICON:=lazpaint/lazpaint.ico
  ICONS=$(shell identify $(ICON) | awk -F '[[]|[]] | ' '{ printf "[%s]=%s ", $$2, $$4 }')
  EXTRACTED_ICONS_DIR=icons
  EXTRACTED_ICONS=$(shell find "${EXTRACTED_ICONS_DIR}" -maxdepth 1 -type f -name *x*.png -exec basename {} .png ';')
  LAZARUSDIRECTORIES:="-Fu$(lazdir)/*" "-Fi$(lazdir)/*" "-Fu$(lazdir)/components/printers/unix" "-Fi$(lazdir)/components/printers/unix" "-Fu$(lazdir)/packager/registration" "-Fi$(lazdir)/packager/registration" "-Fu$(lazdir)/components/*" "-Fi$(lazdir)/components/*" "-Fu$(lazdir)/lcl/forms" "-Fi$(lazdir)/lcl/forms" "-Fu$(lazdir)/lcl/widgetset" "-Fi$(lazdir)/lcl/widgetset" "-Fu$(lazdir)/interfaces/*" "-Fi$(lazdir)/interfaces/*" "-Fu$(lazdir)/lcl/nonwin32" "-Fi$(lazdir)/lcl/nonwin32" "-Fu$(lazdir)/lcl/interfaces/gtk2" "-Fi$(lazdir)/lcl/interfaces/gtk2" "-Fu$(lazdir)/lcl/components/*" "-Fi$(lazdir)/lcl/components/*" "-Fu$(lazdir)/lcl/include" "-Fi$(lazdir)/lcl/include" "-Fu$(lazdir)/lcl" "-Fi$(lazdir)/lcl"
endif

ifeq ($(UNAME),FreeBSD)
  TARGET ?= Gtk2
  LAZARUSDIRECTORIES:="-Fu$(lazdir)/*" "-Fi$(lazdir)/*" "-Fu$(lazdir)/components/printers/unix" "-Fi$(lazdir)/components/printers/unix" "-Fu$(lazdir)/packager/registration" "-Fi$(lazdir)/packager/registration" "-Fu$(lazdir)/components/*" "-Fi$(lazdir)/components/*" "-Fu$(lazdir)/lcl/forms" "-Fi$(lazdir)/lcl/forms" "-Fu$(lazdir)/lcl/widgetset" "-Fi$(lazdir)/lcl/widgetset" "-Fu$(lazdir)/interfaces/*" "-Fi$(lazdir)/interfaces/*" "-Fu$(lazdir)/lcl/nonwin32" "-Fi$(lazdir)/lcl/nonwin32" "-Fu$(lazdir)/lcl/interfaces/gtk2" "-Fi$(lazdir)/lcl/interfaces/gtk2" "-Fu$(lazdir)/lcl/components/*" "-Fi$(lazdir)/lcl/components/*" "-Fu$(lazdir)/lcl/include" "-Fi$(lazdir)/lcl/include" "-Fu$(lazdir)/lcl" "-Fi$(lazdir)/lcl"
endif

ifeq ($(UNAME),Windows)
  TARGET ?= Win32
  LAZARUSDIRECTORIES:="-Fu$(lazdir)/*" "-Fi$(lazdir)/*" "-Fu$(lazdir)/components/printers/win32" "-Fi$(lazdir)/components/printers/win32" "-Fu$(lazdir)/packager/registration" "-Fi$(lazdir)/packager/registration" "-Fu$(lazdir)/components/*" "-Fi$(lazdir)/components/*" "-Fu$(lazdir)/lcl/forms" "-Fi$(lazdir)/lcl/forms" "-Fu$(lazdir)/lcl/widgetset" "-Fi$(lazdir)/lcl/widgetset" "-Fu$(lazdir)/interfaces/*" "-Fi$(lazdir)/interfaces/*" "-Fu$(lazdir)/lcl/interfaces/win32" "-Fi$(lazdir)/lcl/interfaces/win32" "-Fu$(lazdir)/lcl/components/*" "-Fi$(lazdir)/lcl/components/*" "-Fu$(lazdir)/lcl/include" "-Fi$(lazdir)/lcl/include" "-Fu$(lazdir)/lcl" "-Fi$(lazdir)/lcl"
endif

# determine buildmode/interface
BUILDMODE:=Release
INTERFACE:=LCL$(shell echo $(TARGET) | tr A-Z a-z)
ifeq ($(TARGET),Qt5)
  BUILDMODE:=ReleaseQt5
endif

all: compile

install: prefix
ifeq ($(UNAME),Windows) 
	echo "Use installation made by InnoSetup with \"lazpaint\lazpaint.iss\""
endif

ifeq ($(UNAME),Linux)
	install -D "$(SOURCE_BIN_DIR)/$(package)" "$(BIN_DIR)/lazpaint"
	for f in $(PO_FILES); do install -D --mode=0644 "$(SOURCE_BIN_DIR)/i18n/$$f" "$(RESOURCE_DIR)/i18n/$$f"; done
	for f in $(MODEL_FILES); do install -D --mode=0644 "$(SOURCE_BIN_DIR)/models/$$f" "${RESOURCE_DIR}/models/$$f"; done
	install -D "$(SOURCE_DEBIAN_UPSTREAM)/applications/lazpaint.desktop" "$(SHARE_DIR)/applications/lazpaint.desktop"
	install -D "$(EXTRACTED_ICONS_DIR)/48x48.png" "$(SHARE_DIR)/pixmaps/lazpaint.png"
	for s in $(EXTRACTED_ICONS); do install -D --mode=0644 "$(EXTRACTED_ICONS_DIR)/$$s.png" "$(ICON_DIR)/$$s/apps/lazpaint.png"; done
	install -d "$(SHARE_DIR)/man/man1"
	gzip -9 -n -c "$(SOURCE_DEBIAN_UPSTREAM)/man/man1/lazpaint.1" >"$(SHARE_DIR)/man/man1/lazpaint.1.gz"
	chmod 0644 "$(SHARE_DIR)/man/man1/lazpaint.1.gz"
	install -d "$(DOC_DIR)"
	gzip -9 -n -c "$(SOURCE_DEBIAN_DIR)/changelog" >"$(DOC_DIR)/changelog.Debian.gz"
	chmod 0644 "$(DOC_DIR)/changelog.Debian.gz"
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
	for s in $(EXTRACTED_ICONS); do $(REMOVE) $(ICON_DIR)/$$s/apps/lazpaint.png; done
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
ifeq ($(UNAME),Windows)
	$(REMOVE) "lazpaint/release/lazpaint32.exe"
	$(REMOVE) "lazpaint/release/lazpaint_x64.exe"
else
	$(REMOVE) "lazpaint/release/$(package)"
endif
	$(REMOVEDIR) "lazpaint/backup"
	$(REMOVEDIR) "lazpaint/test_embedded/backup"

compile: lazdir lazpaint
force:
	echo lazbuild or fpc will determine what to recompile

lazpaint: force bgracontrols lazpaint/lazpaint.lpi
ifeq "$(lazdir)" ""
	lazbuild --build-mode=$(BUILDMODE) bgrabitmap/bgrabitmappack.lpk bgracontrols/bgracontrols.lpk lazpaint/lazpaint.lpi
else
	$(COPY) "lazpaint/resources/lazpaint.res" "lazpaint/lazpaint.res"
	$(CREATEDIR) "lazpaint/release/lib"
	cd lazpaint $(THEN) $(fpcbin) -orelease/lazpaint -Fu./buttons -Fi./buttons -Fu./image -Fi./image -Fu./cursors -Fi./cursors -Fu./buttons -Fi./buttons -Fu./* -Fi./* -Fu../bgracontrols -Fi../bgracontrols -Fu../bgrabitmap -Fi../bgrabitmap $(LAZARUSDIRECTORIES) -MObjFPC -Scgi -Cg -OoREGVAR -Xs -XX -l -vewnhibq -O3 -CX -vi -FUrelease/lib/ -dLCL -d$(INTERFACE) lazpaint.lpr
endif
ifeq ($(MULTIBIN),1)
	mv "$(SOURCE_BIN_DIR)/lazpaint" "$(SOURCE_BIN_DIR)/$(package)"
endif

icons:
ifneq ($(UNAME),Windows)
	$(CREATEDIR) -p icons
	declare -A icons=($(ICONS)); for i in "$${!icons[@]}"; do convert $(ICON)[$$i] icons/$${icons[$$i]}.png; done
endif

