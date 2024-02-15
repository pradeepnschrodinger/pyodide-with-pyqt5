###### PREREQUISITES

### Dev dependencies
sudo apt-get install autoconf
sudo apt-get install libtool
sudo apt-get install libgl1-mesa-dev
sudo apt-get install libglu1-mesa-dev

### NINJA (alternate to cmake that Qt uses)
put ninja to bin

### NVM
https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
nvm install v18.5.0
nvm use v18.5.0

### CPYTHON
cd <cpython-root>
git checkout v3.11.8
./configure --prefix ./configure --prefix /home/pradeep/projects/cpython/pradeep/3.11.8
make
make install

### PYTHON VENV
python3.11 -m venv env
source env/bin/activate
pip install pyyaml


###### MAKE.SH

### PYODIDE
git clone https://github.com/iodide-project/pyodide.git
git checkout bda1ba4edf6e4140952c5596e4af47521d21f7eb
pip install -r requirements.txt
PYODIDE_PACKAGES="toolz,attrs" make

source ./emsdk/emsdk/emsdk_env.sh

### QT6
git clone git://code.qt.io/qt/qt5.git qt6
cd qt6
git switch 6.6
# needs to be timed
perl init-repository

./configure -xplatform wasm-emscripten -nomake examples -prefix $PWD/qtbase -feature-thread -opensource -confirm-license

## TEMP 1
../qt6/configure -prefix /home/pradeep/projects/pyodide-with-pyqt5/qt6-host


## TEMP 2
# from qt-build
../qt6/configure

# Qt is now configured for building. Just run 'cmake --build . --parallel'

# Once everything is built, you must run 'cmake --install .'
# Qt will be installed into '/usr/local/Qt-6.6.3'

# To configure and build other Qt modules, you can use the following convenience script:
#         /usr/local/Qt-6.6.3/bin/qt-configure-module

# If reconfiguration fails for some reason, try removing 'CMakeCache.txt' from the build directory
# Alternatively, you can add the --fresh flag to your CMake flags.


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


# TEMP 3 https://doc.qt.io/qt-6/wasm.html#wasm-building-qt-from-source

# (didn't work with pyodide's cpython) extract sip from https://pypi.org/project/sip/#files
cd sip-6.8.3
python3 setup.py install

# extract pyqt6sip from https://pypi.org/project/PyQt6-sip/#files
cd PyQt6_sip-13.6.0
emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_array.c -o build/sip_array.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_core.c -o build/sip_core.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_descriptors.c -o build/sip_descriptors.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_enum.c -o build/sip_enum.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_int_convertors.c -o build/sip_int_convertors.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_object_map.c -o build/sip_object_map.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_threads.c -o build/sip_threads.o

emcc -pthread -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_voidptr.c -o build/sip_voidptr.o

emar cqs libsip.a build/*.o

# extract pyqt6 from https://pypi.org/project/PyQt6/#files
cd PyQt6-6.6.1
pip install PyQt-builder
# sip-install --qmake ../qt6-build-wasm/qtbase/bin/qt-cmake --confirm-license --verbose
sip-install --qmake /usr/local/Qt-6.6.3/bin/qmake --confirm-license --verbose

# pyodide
cd pyodide

    git apply ../../patches/pyodide-main.patch

    emcc -o src/core/main.bc -c src/core/main.c -O3 -g -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -Wno-warn-absolute-paths -Isrc/type_conversion/

# em++ -s EXPORT_NAME="'pyodide'" -o build/pyodide.asm.html src/main.bc src/type_conversion/jsimport.bc src/type_conversion/jsproxy.bc src/type_conversion/js2python.bc src/type_conversion/pyimport.bc src/type_conversion/pyproxy.bc src/type_conversion/python2js.bc src/type_conversion/python2js_buffer.bc src/type_conversion/runpython.bc src/type_conversion/hiwire.bc -O3 -s MODULARIZE=1 cpython/installs/python-3.8.2/lib/libpython3.8.a packages/lz4/lz4-1.8.3/lib/liblz4.a -s "BINARYEN_METHOD='native-wasm'" -s TOTAL_MEMORY=20971520 -s ALLOW_MEMORY_GROWTH=1 -s MAIN_MODULE=1 -s EMULATE_FUNCTION_POINTER_CASTS=1 -s LINKABLE=1 -s EXPORTED_FUNCTIONS='["___cxa_guard_acquire", "__ZNSt3__28ios_base4initEPv", "LZ4", "loadPackage", "LZ4.loadPackage", "pyodide", "runPython", "pyodide.runPython", "_main", "_LZ4_decompress_safe", "__runPython", "_runPython", "__js2python_jsproxy", "__pyimport", "__pyproxy_get", "__js2python_allocate_string", "__js2python_get_ptr", "__pyproxy_apply", "__findImports", "__js2python_none", "__js2python_pyproxy", "__js2python_number", "UTF16ToString","stringToUTF16"]'  -s WASM=1 -s USE_FREETYPE=1 -s USE_LIBPNG=1 -std=c++14 -Lcpython/build/sqlite-autoconf-3270200/.libs -lsqlite3 cpython/build/bzip2-1.0.2/libbz2.a -lstdc++ --memory-init-file 0 -s TEXTDECODER=0 -s LZ4=1 -s FORCE_FILESYSTEM=1 -l QtCore -L ../PyQt5-5.15.2.dev2011131516/QtCore -l Qt5Core -L ../qt5/qtbase/lib -l sip -L ../PyQt5_sip-12.8.1  -L ../PyQt5-5.15.2.dev2011131516/QtGui -l QtGui -L ../PyQt5-5.15.2.dev2011131516/QtWidgets -l QtWidgets -l Qt5Core -l Qt5Gui -l Qt5Widgets -l libqwasm -L ../qt5/qtbase/plugins/platforms -l Qt5FontDatabaseSupport -l libqminimal -l libQt5EventDispatcherSupport -l libqoffscreen --bind -s EXTRA_EXPORTED_RUNTIME_METHODS=["UTF16ToString","stringToUTF16"]  -s FULL_ES2=1 -s USE_WEBGL2=1 -l qtharfbuzz -l QtSvg -L ../PyQt5-5.15.2.dev2011131516/QtSvg -l qsvgicon -L ../qt5/qtbase/plugins/iconengines -L ../qt5/qtbase/plugins/imageformats -l libqjpeg -l libqsvg -l Qt5Svg

mkdir -p build
em++ -s EXPORT_NAME="'pyodide'" -o build/pyodide.asm.html src/core/main.o src/core/js2python.o src/core/docstring.o src/core/hiwire.o src/core/error_handling.o src/core/_pyodide_core.o src/core/python2js.o src/core/pyproxy.o src/core/python2js_buffer.o src/core/main.o src/core/jsproxy.o src/core/pyversion.o src/core/pyodide_pre.o -O3 -s MODULARIZE=1 cpython/installs/python-3.11.3/lib/libpython3.11.a -s "BINARYEN_METHOD='native-wasm'" -s TOTAL_MEMORY=20971520 -s ALLOW_MEMORY_GROWTH=1 -s MAIN_MODULE=1 -s EMULATE_FUNCTION_POINTER_CASTS=1 -s LINKABLE=1 -s EXPORTED_FUNCTIONS='["___cxa_guard_acquire", "__ZNSt3__28ios_base4initEPv", "LZ4", "loadPackage", "LZ4.loadPackage", "pyodide", "runPython", "pyodide.runPython", "_main", "_LZ4_decompress_safe", "__runPython", "_runPython", "__js2python_jsproxy", "__pyimport", "__pyproxy_get", "__js2python_allocate_string", "__js2python_get_ptr", "__pyproxy_apply", "__findImports", "__js2python_none", "__js2python_pyproxy", "__js2python_number", "UTF16ToString","stringToUTF16"]'  -s WASM=1 -s USE_FREETYPE=1 -s USE_LIBPNG=1 -std=c++14 -Lcpython/build/sqlite-autoconf-3270200/.libs -lsqlite3 -lstdc++ --memory-init-file 0 -s TEXTDECODER=0 -s LZ4=1 -s FORCE_FILESYSTEM=1 -l QtCore -L ../PyQt5-5.15.2.dev2011131516/QtCore -l Qt5Core -L ../qt5/qtbase/lib -l sip -L ../PyQt5_sip-12.8.1  -L ../PyQt5-5.15.2.dev2011131516/QtGui -l QtGui -L ../PyQt5-5.15.2.dev2011131516/QtWidgets -l QtWidgets -l Qt5Core -l Qt5Gui -l Qt5Widgets -l libqwasm -L ../qt5/qtbase/plugins/platforms -l Qt5FontDatabaseSupport -l libqminimal -l libQt5EventDispatcherSupport -l libqoffscreen --bind -s EXTRA_EXPORTED_RUNTIME_METHODS=["UTF16ToString","stringToUTF16"]  -s FULL_ES2=1 -s USE_WEBGL2=1 -l qtharfbuzz -l QtSvg -L ../PyQt5-5.15.2.dev2011131516/QtSvg -l qsvgicon -L ../qt5/qtbase/plugins/iconengines -L ../qt5/qtbase/plugins/imageformats -l libqjpeg -l libqsvg -l Qt5Svg

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