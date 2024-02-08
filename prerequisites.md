#
# PYODIDE + EMSDK
#

# required to create virtual environment for python
sudo apt-get install -y python3.10-venv

# The build process for pyodide requires 3.8 version of python.
# It did not work for python 3.10 for whatever reason.
#
# If your system doesn't have 3.8, then clone CPython and checkout v3.8.2
# Build and install cpython after configuring with the --prefix flag.
```
cd <cpython-root>
git checkout v3.8.2
./configure --prefix ./configure --prefix /home/pradeep/projects/cpython/pradeep/3.8.2
make
make install
```

# Once this is done, activate a virtualenv for python 3.8 via:
```
~/projects/cpython/pradeep/3.8.2/bin/python3 -m venv env
source env/bin/activate
pip install pyyaml
```

Install build dependencies:
```
sudo apt-get install -y libffi-dev gfortran uglifyjs make pkg-config npm cmake
sudo apt install -y zlib1g 
sudo apt install -y zlib1g-dev

sudo npm install -g less
```

# [auto-fixed by patch] After cloning pyodide, checkout particular tag for emsdk by modifying "pyodide/emsdk/Makefile"
	git clone https://github.com/juj/emsdk.git
	(cd emsdk && git checkout 3.1.29)

# [auto-fixed by patch] change URLs for tarballs before building pyodide
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

#
# QT5
#

# [auto-fixed by patch] QT5 compilation errors
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
