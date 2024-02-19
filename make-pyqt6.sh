# TODO (pradeep): Compile qt with multi processing disabled
# https://doc.qt.io/QtApplicationManager/singlevsmultiprocess.html#build-and-runtime-options

# TODO (pradeep): multiprocessing isn't functional in pyodide, but can still be imported
# try building it in pyodide -- https://pyodide.org/en/stable/usage/wasm-constraints.html#included-but-not-working-modules -- to see if pyqt compilation works

###### PREREQUISITES

### Dev dependencies
sudo apt-get install -y autoconf
sudo apt-get install -y libtool
sudo apt-get install -y libgl1-mesa-dev
sudo apt-get install -y libglu1-mesa-dev
sudo apt install -y libfontconfig1-dev libfreetype6-dev libx11-dev libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-cursor-dev libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev

# pyodide
# rustup has a prompt - specify 1 (for default installation)
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# sudo apt-get install -y swig3.0
sudo apt install -y sqlite3
sudo apt install -y f2c

### NINJA (alternate to cmake that Qt uses)
put ninja to bin

### NVM
# https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# reload bashrc
nvm install v18.5.0
nvm use v18.5.0

### CPYTHON
cd <cpython-root>
#git checkout v3.11.8
git checkout v3.11.3
./configure --prefix ./configure --prefix /home/pradeep/projects/cpython/pradeep/3.11.8
make
make install

### PYTHON VENV
# /home/pradeep/projects/cpython/pradeep/3.11.8/bin
python3.11 -m venv .venv
source .venv/bin/activate
pip install pyyaml


###### MAKE.SH

### PYODIDE
git clone https://github.com/iodide-project/pyodide.git
cd pyodide
git checkout bda1ba4edf6e4140952c5596e4af47521d21f7eb #v0.24.1
pip install -r requirements.txt

# TODO (pradeep): `setuptools`` isn't installed here. Maybe try with PYODIDE_PACKAGES='*' make

# TODO (pradeep): Can't build all packages because executables rustup and swif. I'm gonna disable the failing ones:

# PYODIDE_PACKAGES='*,!nlopt,!cryptography,!sourmash,!pyxel,!cramjam,!cbor-diag,!bcrypt,!rust-panic-test,!orjson' make

# working but flaky build! takes around 12-24mins. Decrease the job counts to make this less flaky?
# PYODIDE_JOBS=16 PYODIDE_PACKAGES='*,!nlopt,!cryptography,!sourmash,!pyxel,!cramjam,!cbor-diag,!bcrypt,!rust-panic-test,!orjson,!geos,!libgmp,!scipy,!swiglpk' make

# PYODIDE_PACKAGES="toolz,attrs" make

PYODIDE_PACKAGES="toolz,attrs,core" make

source ./emsdk/emsdk/emsdk_env.sh

### QT6
git clone git://code.qt.io/qt/qt5.git qt6
# git clone https://code.qt.io/qt/qt5.git qt6
cd qt6
git switch 6.6
# needs to be timed
perl init-repository

# compile qt6 for native platform
mkdir qt6-native-build
cd qt6-native-build
# ./configure -xplatform wasm-emscripten -nomake examples -prefix $PWD/qtbase -feature-thread -opensource -confirm-license
# TODO (pradeep): Disable feature thread for Qt cause it's to be used in pyodide?
../qt6/configure -prefix ../qt6-native-host -nomake examples -confirm-license -feature-thread

# Should give the follow output:
# Qt is now configured for building. Just run 'cmake --build . --parallel'

# Once everything is built, you must run 'cmake --install .'
# Qt will be installed into '/usr/local/Qt-6.6.3'

# To configure and build other Qt modules, you can use the following convenience script:
#         /usr/local/Qt-6.6.3/bin/qt-configure-module

# If reconfiguration fails for some reason, try removing 'CMakeCache.txt' from the build directory
# Alternatively, you can add the --fresh flag to your CMake flags.

cmake --build .
cmake --install .

### Configure Qt6 for WASM platform
## Approach 1
../qt6/configure -prefix /home/pradeep/projects/pyodide-with-pyqt5/qt6-host


## Approach 2#
# from qt-build
../qt6/configure

# cmake --build . --parallel
cmake --build .
sudo cmake --install .

# from qt6-build-wasm
#QT_HOST_PATH=~/projects/pyodide-with-pyqt5/qt6-build/qtbase  ../qt6/configure -xplatform wasm-emscripten -prefix .
QT_HOST_PATH=~/projects/pyodide-with-pyqt5/qt6-build/qtbase  ../qt6/configure -xplatform wasm-emscripten -prefix /home/pradeep/projects/pyodide-with-pyqt5/qt6-host
# this command doesn't work with the following error:
# CMake Error at qtbase/cmake/QtPublicDependencyHelpers.cmake:216 (find_package):
#   Could not find a package configuration file provided by "Qt6HostInfo" with
#   any of the following names:

#     Qt6HostInfoConfig.cmake
#     qt6hostinfo-config.cmake

# the file is at ../qt6-build/qtbase/lib/cmake/Qt6HostInfo/Qt6HostInfoConfig.cmake
# QT_HOST_PATH=~/projects/pyodide-with-pyqt5/qt6/qtbase ../qt6/configure -xplatform wasm-emscripten

cmake --build .
cmake --install .


# Approach 3: https://doc.qt.io/qt-6/wasm.html#wasm-building-qt-from-source
./configure -qt-host-path ../qt6-native-host -platform wasm-emscripten -prefix $PWD/qtbase
# Should give the following output:
# Note: Using static linking will disable the use of dynamically loaded plugins. Make sure to import all needed static plugins, or compile needed modules into the library.
# Note: Hunspell in Qt Virtual Keyboard is not enabled. Spelling correction will not be available.

# WARNING: You should use the recommended Emscripten version 3.1.37 with this Qt. You have 3.1.45.
# WARNING: QDoc will not be compiled, probably because clang's C and C++ libraries could not be located. This means that you cannot build the Qt documentation.
# You may need to set CMAKE_PREFIX_PATH or LLVM_INSTALL_DIR to the location of your llvm installation.
# Other than clang's libraries, you may need to install another package, such as clang itself, to provide the ClangConfig.cmake file needed to detect your libraries. Once this
# file is in place, the configure script may be able to detect your system-installed libraries without further environment variables.
# On macOS, you can use Homebrew's llvm package.
# You will also need to set the FEATURE_clang CMake variable to ON to re-evaluate this check.
# WARNING: QDoc cannot be compiled without Qt's commandline parser or thread features.
# WARNING: Clang-based lupdate parser will not be available. LLVM and Clang C++ libraries have not been found.
# You will need to set the FEATURE_clangcpp CMake variable to ON to re-evaluate this check.
# WARNING: QtWebEngine won't be built. Build can be done only on Linux, Windows or macOS.
# WARNING: QtPdf won't be built. Build can be done only on Linux, Windows, macO, iOS and Android(on non-Windows hosts only).

# -- 

# Qt is now configured for building. Just run 'cmake --build . --parallel'

# Once everything is built, Qt is installed. You should NOT run 'cmake --install .'
# Note that this build cannot be deployed to other machines or devices.

# To configure and build other Qt modules, you can use the following convenience script:
#         /home/pradeep/projects/pyodide-with-pyqt5/qt6/qtbase/bin/qt-configure-module

# create qt6 static libs
# qt6/qtbase/lib/libQt6Core.a
cmake --build .


## Build SIP
# extract sip from https://pypi.org/project/sip/#files
tar -xf sources/sip-6.8.3.tar.gz
cd sip-6.8.3

# (didn't work with pyodide's cpython) 
# python3 setup.py install

# APPROACH 1
# use pyodide itself to build and package SIP - https://pyodide.org/en/0.24.1/development/building-and-testing-packages.html#build-the-wasm-emscripten-wheel
PYODIDE_ROOT=../pyodide pyodide build
# should putput Successfully built /home/pradeep/projects/pyodide-with-pyqt5/sip-6.8.3/dist/sip-6.8.3-py3-none-any.whl
pip install dist/sip-6.8.3-py3-none-any.whl # looks like this is already installed

# APPROACH 2
# pyodide package builder (https://pyodide.org/en/0.24.1/development/building-and-testing-packages.html#build-the-wasm-emscripten-wheel)
cd pyodide

# these doesn't seem to do anything cause we already built pyodide completely above
make -C emsdk
make -C cpython
pyodide venv ../.venv-pyodide

# run this in a new bash
source .venv-pyodide/bin/activate

# build and install sip into pyodide's host python
cd sip-6.8.3
pip install -e ./pyodide-build
# should output Successfully built /home/pradeep/projects/pyodide-with-pyqt5/sip-6.8.3/dist/sip-6.8.3-py3-none-any.whl

## PyQt6-SIP
# extract pyqt6sip from https://pypi.org/project/PyQt6-sip/#files
tar -xf sources/PyQt6_sip-13.6.0.tar.gz
cd PyQt6_sip-13.6.0

# (native build)
python setup.py install

mkdir -p build
emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_array.c -o build/sip_array.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_bool.cpp -o build/sip_bool.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_core.c -o build/sip_core.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_descriptors.c -o build/sip_descriptors.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_enum.c -o build/sip_enum.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_int_convertors.c -o build/sip_int_convertors.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_object_map.c -o build/sip_object_map.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_threads.c -o build/sip_threads.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_voidptr.c -o build/sip_voidptr.o

emar cqs libsip.a build/*.o


## PyQt6
# extract pyqt6 from https://pypi.org/project/PyQt6/#files
tar -xf sources/PyQt6-6.6.1.tar.gz
cd PyQt6-6.6.1
# TODO (pradeep): Should this also be compiled to WASM?
pip install PyQt-builder
# sip-install --qmake ../qt6-build-wasm/qtbase/bin/qt-cmake --confirm-license --verbose
# sip-install --qmake /usr/local/Qt-6.6.3/bin/qmake --confirm-license --verbose

# (test) native PyQt6
# sip-install --qmake ../qt6-native-host/bin/qmake --confirm-license --build-dir $(realpath ../pyqt6-native-build) --target-dir $(realpath ../pyqt6-native-target) --verbose &> pyqt6-native-install.log

# patches for project.py
# approach #1
# set 'WebAssembly' as the platform for 'QtCore'
# removed 'QAxContainer' entry from self.bindings in project.py
# removed 'QtTextToSpeech' entry from self.bindings in project.py
# removed 'QtSpatialAudio' entry from self.bindings in project.py
# removed QtPdf, QtPdfWidgets
# removed QtPositioning, QtSerialPort, QtDBus
# the final list would be 
        # self.bindings_factories = [QtCore, QtNetwork, QtGui, QtQml, QtWidgets,
        #         QtDesigner, QtHelp, QtOpenGL, QtOpenGLWidgets,
        #         QtPrintSupport, QtQuick, QtQuick3D, QtQuickWidgets, QtSql,
        #         QtSvg, QtSvgWidgets, QtTest, QtXml, QtMultimedia,
        #         QtMultimediaWidgets, QtRemoteObjects, QtSensors,
        #         QtWebChannel, QtWebSockets, QtBluetooth, QtNfc]

# approach #2
# removed 8 failing packages: dbus, positioning, serialport, pdf, pdfwidgets, spatialaudio, axcontainer

# build PyQt6
#sip-install --qmake ../qt6/qtbase/bin/qmake --confirm-license --verbose

# this doesn't work with pyodide-venv
# (test) DO NOT USE relative paths
sip-install --qmake ../qt6/qtbase/bin/qmake --confirm-license --build-dir ../pyqt6-build --target-dir ../pyqt6-target --verbose &> pyqt6-build.log
# this also doesn't work with pyodide-venv
# sip-install --qmake ../qt6/qtbase/bin/qmake --confirm-license --verbose &> pyqt6-build.log

# sip-install --qmake ../qt6-host/qtbase/bin/qmake --confirm-license --build-dir ../pyqt6-build-native --target-dir ../pyqt6-target-native --verbose &> pyqt6-build-native.log
# TODO (pradeep): Do we need the patches for QtCore, QtGui, etc?

# TODO (pradeep): Verify that sip-install is the one that generated qt6/qtbase/lib/libQt6Core.a, libQt6Gui.a, etc

### TODO (pradeep): Package as a pyodide package?
cd pyodide
pyodide skeleton pypi <package-name>


# pyodide
cd pyodide

    git apply ../patches/pyodide-main-qt6.patch

    emcc -o src/core/main.bc -c src/core/main.c -O3 -g -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -Wno-warn-absolute-paths -Isrc/type_conversion/

# em++ -s EXPORT_NAME="'pyodide'" -o build/pyodide.asm.html src/main.bc src/type_conversion/jsimport.bc src/type_conversion/jsproxy.bc src/type_conversion/js2python.bc src/type_conversion/pyimport.bc src/type_conversion/pyproxy.bc src/type_conversion/python2js.bc src/type_conversion/python2js_buffer.bc src/type_conversion/runpython.bc src/type_conversion/hiwire.bc -O3 -s MODULARIZE=1 cpython/installs/python-3.8.2/lib/libpython3.8.a packages/lz4/lz4-1.8.3/lib/liblz4.a -s "BINARYEN_METHOD='native-wasm'" -s TOTAL_MEMORY=20971520 -s ALLOW_MEMORY_GROWTH=1 -s MAIN_MODULE=1 -s EMULATE_FUNCTION_POINTER_CASTS=1 -s LINKABLE=1 -s EXPORTED_FUNCTIONS='["___cxa_guard_acquire", "__ZNSt3__28ios_base4initEPv", "LZ4", "loadPackage", "LZ4.loadPackage", "pyodide", "runPython", "pyodide.runPython", "_main", "_LZ4_decompress_safe", "__runPython", "_runPython", "__js2python_jsproxy", "__pyimport", "__pyproxy_get", "__js2python_allocate_string", "__js2python_get_ptr", "__pyproxy_apply", "__findImports", "__js2python_none", "__js2python_pyproxy", "__js2python_number", "UTF16ToString","stringToUTF16"]'  -s WASM=1 -s USE_FREETYPE=1 -s USE_LIBPNG=1 -std=c++14 -Lcpython/build/sqlite-autoconf-3270200/.libs -lsqlite3 cpython/build/bzip2-1.0.2/libbz2.a -lstdc++ --memory-init-file 0 -s TEXTDECODER=0 -s LZ4=1 -s FORCE_FILESYSTEM=1 -l QtCore -L ../PyQt5-5.15.2.dev2011131516/QtCore -l Qt5Core -L ../qt5/qtbase/lib -l sip -L ../PyQt5_sip-12.8.1  -L ../PyQt5-5.15.2.dev2011131516/QtGui -l QtGui -L ../PyQt5-5.15.2.dev2011131516/QtWidgets -l QtWidgets -l Qt5Core -l Qt5Gui -l Qt5Widgets -l libqwasm -L ../qt5/qtbase/plugins/platforms -l Qt5FontDatabaseSupport -l libqminimal -l libQt5EventDispatcherSupport -l libqoffscreen --bind -s EXTRA_EXPORTED_RUNTIME_METHODS=["UTF16ToString","stringToUTF16"]  -s FULL_ES2=1 -s USE_WEBGL2=1 -l qtharfbuzz -l QtSvg -L ../PyQt5-5.15.2.dev2011131516/QtSvg -l qsvgicon -L ../qt5/qtbase/plugins/iconengines -L ../qt5/qtbase/plugins/imageformats -l libqjpeg -l libqsvg -l Qt5Svg

mkdir -p build
# build command from qt5
# em++ -s EXPORT_NAME="'pyodide'" -o build/pyodide.asm.html src/core/main.o src/core/js2python.o src/core/docstring.o src/core/hiwire.o src/core/error_handling.o src/core/_pyodide_core.o src/core/python2js.o src/core/pyproxy.o src/core/python2js_buffer.o src/core/main.o src/core/jsproxy.o src/core/pyversion.o src/core/pyodide_pre.o -O3 -s MODULARIZE=1 cpython/installs/python-3.11.3/lib/libpython3.11.a -s "BINARYEN_METHOD='native-wasm'" -s TOTAL_MEMORY=20971520 -s ALLOW_MEMORY_GROWTH=1 -s MAIN_MODULE=1 -s EMULATE_FUNCTION_POINTER_CASTS=1 -s LINKABLE=1 -s EXPORTED_FUNCTIONS='["___cxa_guard_acquire", "__ZNSt3__28ios_base4initEPv", "LZ4", "loadPackage", "LZ4.loadPackage", "pyodide", "runPython", "pyodide.runPython", "_main", "_LZ4_decompress_safe", "__runPython", "_runPython", "__js2python_jsproxy", "__pyimport", "__pyproxy_get", "__js2python_allocate_string", "__js2python_get_ptr", "__pyproxy_apply", "__findImports", "__js2python_none", "__js2python_pyproxy", "__js2python_number", "UTF16ToString","stringToUTF16"]'  -s WASM=1 -s USE_FREETYPE=1 -s USE_LIBPNG=1 -std=c++14 -Lcpython/build/sqlite-autoconf-3270200/.libs -lsqlite3 -lstdc++ --memory-init-file 0 -s TEXTDECODER=0 -s LZ4=1 -s FORCE_FILESYSTEM=1 -l QtCore -L ../PyQt5-5.15.2.dev2011131516/QtCore -l Qt5Core -L ../qt5/qtbase/lib -l sip -L ../PyQt5_sip-12.8.1  -L ../PyQt5-5.15.2.dev2011131516/QtGui -l QtGui -L ../PyQt5-5.15.2.dev2011131516/QtWidgets -l QtWidgets -l Qt5Core -l Qt5Gui -l Qt5Widgets -l libqwasm -L ../qt5/qtbase/plugins/platforms -l Qt5FontDatabaseSupport -l libqminimal -l libQt5EventDispatcherSupport -l libqoffscreen --bind -s EXTRA_EXPORTED_RUNTIME_METHODS=["UTF16ToString","stringToUTF16"]  -s FULL_ES2=1 -s USE_WEBGL2=1 -l qtharfbuzz -l QtSvg -L ../PyQt5-5.15.2.dev2011131516/QtSvg -l qsvgicon -L ../qt5/qtbase/plugins/iconengines -L ../qt5/qtbase/plugins/imageformats -l libqjpeg -l libqsvg -l Qt5Svg

# (not working) build commmand for qt6
em++ -s EXPORT_NAME="'pyodide'" -o build/pyodide.asm.html src/core/main.o src/core/js2python.o src/core/docstring.o src/core/hiwire.o src/core/error_handling.o src/core/_pyodide_core.o src/core/python2js.o src/core/pyproxy.o src/core/python2js_buffer.o src/core/main.o src/core/jsproxy.o src/core/pyversion.o src/core/pyodide_pre.o -O3 -s MODULARIZE=1 cpython/installs/python-3.11.3/lib/libpython3.11.a -s "BINARYEN_METHOD='native-wasm'" -s TOTAL_MEMORY=20971520 -s ALLOW_MEMORY_GROWTH=1 -s MAIN_MODULE=1 -s EMULATE_FUNCTION_POINTER_CASTS=1 -s LINKABLE=1 -s EXPORTED_FUNCTIONS='["___cxa_guard_acquire", "__ZNSt3__28ios_base4initEPv", "LZ4", "loadPackage", "LZ4.loadPackage", "pyodide", "runPython", "pyodide.runPython", "_main", "_LZ4_decompress_safe", "__runPython", "_runPython", "__js2python_jsproxy", "__pyimport", "__pyproxy_get", "__js2python_allocate_string", "__js2python_get_ptr", "__pyproxy_apply", "__findImports", "__js2python_none", "__js2python_pyproxy", "__js2python_number", "UTF16ToString","stringToUTF16"]'  -s WASM=1 -s USE_FREETYPE=1 -s USE_LIBPNG=1 -std=c++14 -Lcpython/build/sqlite-autoconf-3270200/.libs -lsqlite3 -lstdc++ --memory-init-file 0 -s TEXTDECODER=0 -s LZ4=1 -s FORCE_FILESYSTEM=1 ../pyqt6-build/cfgtest_QtCore/QtCore.wasm -L ../qt5/qtbase/lib -l sip -L ../PyQt6_sip-13.6.0  ../pyqt6-build/cfgtest_QtGui/QtGui.wasm ../pyqt6-build/cfgtest_QtWidgets/QtWidgets.wasm -l libqwasm -L ../qt5/qtbase/plugins/platforms -l Qt5FontDatabaseSupport -l libqminimal -l libQt5EventDispatcherSupport -l libqoffscreen --bind -s EXTRA_EXPORTED_RUNTIME_METHODS=["UTF16ToString","stringToUTF16"]  -s FULL_ES2=1 -s USE_WEBGL2=1 -l qtharfbuzz -l QtSvg -L ../PyQt5-5.15.2.dev2011131516/QtSvg -l qsvgicon -L ../qt5/qtbase/plugins/iconengines -L ../qt5/qtbase/plugins/imageformats -l libqjpeg -l libqsvg -l Qt5Svg &> pyodide-build.log

# original make commands from pyodide/Makefile.envs and pyodide-make.log
em++ -o dist/pyodide.asm.js dist/libpyodide.a src/core/main.o -O2 -g0  -L/home/pradeep/projects/pyodide-with-pyqt5/pyodide/cpython/installs/python-3.11.3/lib/ -s WASM_BIGINT  -s MAIN_MODULE=1 -s MODULARIZE=1 -s LZ4=1 -s EXPORT_NAME="'_createPyodideModule'" -s EXPORT_EXCEPTION_HANDLING_HELPERS -s EXCEPTION_CATCHING_ALLOWED=['we only want to allow exception handling in side modules'] -sEXPORTED_RUNTIME_METHODS='stackAlloc,stackRestore,stackSave' -s DEMANGLE_SUPPORT=1 -s USE_ZLIB -s USE_BZIP2 -s FORCE_FILESYSTEM=1 -s TOTAL_MEMORY=20971520 -s ALLOW_MEMORY_GROWTH=1 -s EXPORT_ALL=1 -s POLYFILL -s MIN_SAFARI_VERSION=140000 -s STACK_SIZE=5MB -s AUTO_JS_LIBRARIES=0 -s AUTO_NATIVE_LIBRARIES=0 -s NODEJS_CATCH_EXIT=0 -s NODEJS_CATCH_REJECTION=0 -lpython3.11 -lffi -lstdc++ -lidbfs.js -lnodefs.js -lproxyfs.js -lworkerfs.js -lwebsocket.js -leventloop.js -lGL -legl.js -lwebgl.js -lhtml5_webgl.js -sGL_WORKAROUND_SAFARI_GETCONTEXT_BUG=0
sed -i -E 's/var __Z[^;]*;//g' dist/pyodide.asm.js
sed -i '1i "use strict";' dist/pyodide.asm.js
sed -i -n -e :a -e '1,4!{P;N;D;};N;ba' dist/pyodide.asm.js
echo "globalThis._createPyodideModule = _createPyodideModule;" >> dist/pyodide.asm.js

# above command gives following errors
wasm-ld: error: unable to find library -lQtCore
wasm-ld: error: unable to find library -lQt5Core
wasm-ld: error: unable to find library -lsip
wasm-ld: error: unable to find library -lQtGui
wasm-ld: error: unable to find library -lQtWidgets
wasm-ld: error: unable to find library -lQt5Core
wasm-ld: error: unable to find library -lQt5Gui
wasm-ld: error: unable to find library -lQt5Widgets
wasm-ld: error: unable to find library -llibqwasm
wasm-ld: error: unable to find library -lQt5FontDatabaseSupport
wasm-ld: error: unable to find library -llibqminimal
wasm-ld: error: unable to find library -llibQt5EventDispatcherSupport
wasm-ld: error: unable to find library -llibqoffscreen
wasm-ld: error: unable to find library -lqtharfbuzz
wasm-ld: error: unable to find library -lQtSvg
wasm-ld: error: unable to find library -lqsvgicon
wasm-ld: error: unable to find library -llibqjpeg
wasm-ld: error: unable to find library -llibqsvg
wasm-ld: error: unable to find library -lQt5Svg
# we need to build pyqt6 statically to get these up