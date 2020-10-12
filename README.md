# lazpaint-upstream
Repository containing all files necessary to build LazPaint.

## Create package with Debuild
To create the Debian package, retrieve the content of the repository in a subdirectory inside a directory dedicated to upstreams. Rename the directory as lazpaint-### where ### is the version number. Compress this folder into a file in the upstream directory in tar.gz format and rename it to lazpaint-###.orig.tar.gaz. Then from the subdirectory, run the following commands:
- apt install build-essential devscripts debhelper
- debuild -us -uc

## Create package without dependency to Lazarus or FPC
If you have your own version of Lazarus and FPC installed, you can use the following command to create the package:
- ./makedeb

It will explain what parameters it expects

## Create the binary files without the package
To make the binary without creating a package, first call configure then call make. On Linux the syntax is:
- ./configure
- make

This will produce the binary in the folder /lazpaint/release

