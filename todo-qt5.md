

### [FIXED] The pyodide version used here is pretty old, and does not have the pyodide.unpackArchive API.
Find an alternative so that we have a way of importing our app bundle.

### [FIX] Use pyodide v0.24.1

------------

### [FIXED] The entire build process took 29958s or ~8.3hours...
Most of the time was spent on cloning, perl-initiating, and compiling the QT5 repo.
Checkout timings at "./logs/time-Thu Feb  8 03:58:06 AM IST 2024.log"

### [FIX] As long as the qt5 repo directory isn't removed, we should be good.
Use `git clean -fdxf ` instead for a faster reset.

------------

### [FIXED] After building pyodide, there seems to be errors with an npm command
```
Error running ['/home/pradeep/projects/pyodide-with-pyqt5/pyodide/emsdk/emsdk/node/8.9.1_64bit/bin/npm', 'ci', '--production', '--no-optional']:
```

I might have to checkout out emsdk from Nov 26, 2020

### [FIX] 
Checkout 0.v.24.1 version of emsdk by modifying emsdk/Makefile
```
git checkout bda1ba4edf6e4140952c5596e4af47521d21f7eb #v0.24.1
```

------------

### [FIXED] change URLs for tarballs before building pyodide
```
ZLIBVERSION = 1.2.11
ZLIBTARBALL=$(ROOT)/downloads/zlib-$(ZLIBVERSION).tar.gz
ZLIBBUILD=$(ROOT)/build/zlib-$(ZLIBVERSION)
ZLIBURL=https://www.zlib.net/fossils/zlib-1.2.11.tar.gz

SQLITETARBALL=$(ROOT)/downloads/sqlite-autoconf-3270200.tar.gz
SQLITEBUILD=$(ROOT)/build/sqlite-autoconf-3270200
SQLITEURL=https://www.sqlite.org/2019/sqlite-autoconf-3270200.tar.gz

BZIP2TARBALL=$(ROOT)/downloads/bzip2-1.0.2.tar.gz
BZIP2BUILD=$(ROOT)/build/bzip2-1.0.2
BZIP2URL=https://ftp.gwdg.de/pub/linux/sources.redhat.com/bzip2/v102/bzip2-1.0.2.tar.gz
```

### [FIXED] QT5 compilation errors
There'll be errors during compilation related to numerical_limits. Eg:
```
Creating qmake...
............................In file included from ../include/QtCore/qfloat16.h:1,
                 from ../include/QtCore/../../src/corelib/global/qendian.h:44,
                 from ../include/QtCore/qendian.h:1,
                 from /home/pradeep/projects/pyodide-with-pyqt5/qt5/qtbase/src/corelib/codecs/qutfcodec.cpp:43:
../include/QtCore/../../src/corelib/global/qfloat16.h:295:7: error: ‘numeric_limits’ is not a class template
  295 | class numeric_limits<QT_PREPEND_NAMESPACE(qfloat16)> : public numeric_limits<float>
      |       ^~~~~~~~~~~~~~
../include/QtCore/../../src/corelib/global/qfloat16.h:295:77: error: expected template-name before ‘<’ token
  295 | class numeric_limits<QT_PREPEND_NAMESPACE(qfloat16)> : public numeric_limits<float>
      |                                                                             ^
```

To fix this, add these 3 lines at the top of qtbase/src/corelib/global/qglobal.h :
```
#ifdef __cplusplus
#include <limits>
#endif
```
