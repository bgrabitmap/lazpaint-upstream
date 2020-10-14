# lazpaint-upstream
Repository containing all files necessary to build LazPaint.

## Create the Debian package

To create the DEB file, you will need to have all necessary files for debuild. To get them, do the following:
```
wget https://github.com/bgrabitmap/lazpaint-upstream/archive/master.tar.gz
tar xzvf master.tar.gz
head -1 lazpaint-upstream-master/debian/changelog
# here we suppose we found version 6.4.1 (do not include the revision like "-1")
mv master.tar.gz lazpaint_6.4.1.orig.tar.gz
mv lazpaint-upstream-master lazpaint-6.4.1
```

### Using Lazarus from the Debian distribution

This build relies on the lcl package. If you want to use your current installation of Lazarus, see other sections below.

Important: installing lcl package may interfere with your installation of Lazarus. Before that, please uninstall Lazarus if it wasn't installed using synaptic. After that remove the configuration folder ".lazarus" in the home folder. 

To build the package:
```
cd lazpaint-6.4.1
apt install build-essential devscripts debhelper
apt install lcl
debuild -us -uc
cd ..
```

This will create the DEB and DSC files that can be distributed.

### Using your own installation of Lazarus or FPC
If you have your own version of Lazarus and FPC installed, you can use the following command to create the package:
```
cd lazpaint-6.4.1
./makedeb
cd ..
```

It will explain what parameters it expects. You will need to know where you Lazarus is located. You can find it using "dpkg-query -L" followed by the package that supplies lazarus. It can be for example:
```
dpkg-query -L lazarus-project
dpkg-query -L lazarus-ide-2.0
```

## Create binary files only
To make the binary files without creating a package, first call configure then call make. On Linux the syntax is:
```
./configure
make
```

This will produce the binary in the folder /lazpaint/release
