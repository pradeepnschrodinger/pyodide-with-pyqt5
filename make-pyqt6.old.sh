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

# TODO (pradeep): Do we need this for unicode support?
sudo apt-get install -y libicu-dev

# pyodide
# rustup has a prompt - specify 1 (for default installation)
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# sudo apt-get install -y swig3.0
sudo apt install -y sqlite3
sudo apt install -y f2c

### NINJA (alternate to cmake that Qt uses)
sudo apt-get install -y ninja-build
# put ninja to bin

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
./configure --prefix ./configure --prefix /home/pradeep/projects/cpython/pradeep/3.11.3
make
make install

### PYTHON VENV
# /home/pradeep/projects/cpython/pradeep/3.11.3/bin/python3.11 -m venv .venv-native
python3.11 -m venv .venv-native
source .venv-native/bin/activate
pip install pyyaml


###### MAKE.SH

### PYODIDE
git clone https://github.com/iodide-project/pyodide.git
cd pyodide
# git checkout bda1ba4edf6e4140952c5596e4af47521d21f7eb #v0.24.1
git checkout 0fe04cd97d9c808a9d77335a630faf371f7ec200
pip install -r requirements.txt --no-cache-dir
# fix an issue related to pyndatic (see: https://stackoverflow.com/a/76958769)
pip install pydantic==1.10.9 --no-cache-dir

# apply patch for emsdk to fetch tags and checkout the 3.1.37 version of emsdk which Qt6 needs
# TODO (pradeep): Turn these into real patches
cp ../temp/pyodide__emsdk__Makefile emsdk/Makefile 
cp ../temp/pyodide__Makefile.envs Makefile.envs 

# apply patches for pyodide for parallel build
# TODO (pradeep): Turn these into real patches
cp ../temp/pyodide__Makefile Makefile
cp ../temp/pyodide__packages__sqlite3__meta.yaml packages/sqlite3/meta.yaml 
cp ../temp/pyodide__cpython__Makefile cpython/Makefile 

# TODO (pradeep): Can't build all packages because executables rustup and swif. I'm gonna disable the failing ones:
# PYODIDE_PACKAGES='*,!nlopt,!cryptography,!sourmash,!pyxel,!cramjam,!cbor-diag,!bcrypt,!rust-panic-test,!orjson' make

# working but flaky build! takes around 12-24mins. Decrease the job counts to make this less flaky?
# PYODIDE_JOBS=16 PYODIDE_PACKAGES='*,!nlopt,!cryptography,!sourmash,!pyxel,!cramjam,!cbor-diag,!bcrypt,!rust-panic-test,!orjson,!geos,!libgmp,!scipy,!swiglpk' make

# older build command I followed for pyqt5, but doesn't install setuptools...
# PYODIDE_PACKAGES="toolz,attrs" make

# build setuptools and other core libraries
PYODIDE_PACKAGES="toolz,attrs,core" make &> ../logs/pyodide-make.log

source ./emsdk/emsdk/emsdk_env.sh

### QT6
git clone git://code.qt.io/qt/qt5.git qt6
# git clone https://code.qt.io/qt/qt5.git qt6
cd qt6
git switch 6.6.1
# needs to be timed
perl init-repository

# apply patches in qtbase to configure timzeone, semaphore, and thread features to always be enabled
push qtbase
    cp ../../temp/qt6__qtbase__src__corelib__configure.cmake qtbase/src/corelib/configure.cmake
    cp src/corelib/configure.cmake ../../temp/qt6__qtbase__src__corelib__configure.cmake
    cp src/plugins/platforms/CMakeLists.txt ../../temp/qt6__qtbase__src__plugins__platforms__CMakeLists.txt
    cp src/plugins/platforms/minimal/CMakeLists.txt ../../temp/qt6__qtbase__src__plugins__platforms__minimal__CMakeLists.txt
    cp src/plugins/platforms/offscreen/CMakeLists.txt ../../temp/qt6__qtbase__src__plugins__platforms__offscreen__CMakeLists.txt
popd

# compile qt6 for native platform
mkdir qt6-native-build
cd qt6-native-build
# ./configure -xplatform wasm-emscripten -nomake examples -prefix $PWD/qtbase -feature-thread -opensource -confirm-license
# TODO (pradeep): Disable feature thread for Qt cause it's to be used in pyodide?
# ../qt6/configure -prefix ../qt6-native-host -nomake examples -confirm-license -feature-thread
../qt6/configure -static -feature-thread -prefix ../qt6-native-host -nomake examples -confirm-license &> ../logs/qt6-native-configure.log

# Should give the follow output:
# Qt is now configured for building. Just run 'cmake --build . --parallel'

# Once everything is built, you must run 'cmake --install .'
# Qt will be installed into '/usr/local/Qt-6.6.3'

# To configure and build other Qt modules, you can use the following convenience script:
#         /usr/local/Qt-6.6.3/bin/qt-configure-module

# If reconfiguration fails for some reason, try removing 'CMakeCache.txt' from the build directory
# Alternatively, you can add the --fresh flag to your CMake flags.

cmake --build . &> ../logs/qt6-native-build.log
cmake --install . &> ../logs/qt6-native-install.log


## build qt6 for wasm
# https://doc.qt.io/qt-6/wasm.html#wasm-building-qt-from-source
mkdir qt6-wasm-build
cd qt6-wasm-build
# ./configure -qt-host-path $(realpath ../qt6-native-host) -platform wasm-emscripten -prefix $PWD/qtbase &> ../logs/qt6-wasm-configure.log
# same build command but with QT_FEATURE_timezone enabled
# ./configure -DQT_FEATURE_timezone=1 -qt-host-path $(realpath ../qt6-native-host) -platform wasm-emscripten -prefix $PWD/qtbase &> ../logs/qt6-wasm-configure.log

# patch qtbase/src/corelib/configure.cmake to not disable timezone for WASM

../qt6/configure -static -feature-thread -qt-host-path $(realpath ../qt6-native-host) -platform wasm-emscripten -prefix $(realpath ../qt6-wasm-host) &> ../logs/qt6-wasm-configure.log

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
cmake --build . &> ../logs/qt6-wasm-build.log

# do we need to build it using `cmake --install .` like what core does ?
cmake --install . &> ../logs/qt6-wasm-install.log

## Create pyodide environment
# install pyodide builder
# pip install pyodide-build
# TODO (pradeep): Why doesn't the local pyodide-build not work correctly when building packages?
pip install -e pyodide/pyodide-build --no-cache-dir
PYODIDE_ROOT=pyodide pyodide venv .venv-pyodide

## Build SIP
# extract sip from https://pypi.org/project/sip/#files
tar -xf sources/sip-6.8.3.tar.gz
cd sip-6.8.3

# (didn't work with pyodide's cpython) 
# python3 setup.py install

# APPROACH 1
# use pyodide itself to build and package SIP - https://pyodide.org/en/0.24.1/development/building-and-testing-packages.html#build-the-wasm-emscripten-wheel
PYODIDE_ROOT=../pyodide pyodide build &> ../logs/sip-build.log
# should putput Successfully built /home/pradeep/projects/pyodide-with-pyqt5/sip-6.8.3/dist/sip-6.8.3-py3-none-any.whl
pip install dist/sip-6.8.3-py3-none-any.whl
# we should then be able to load this in the browser by doing a micropip.install('http://localhost:8000/sip-6.8.3/dist/sip-6.8.3-py3-none-any.whl')

# APPROACH 2
# use pyodide to build package
# Use pyodide's python to create a virtual environment (see https://pyodide.org/en/0.24.1/development/building-and-testing-packages.html#build-the-wasm-emscripten-wheel)

# activate pyodide venv in new terminal
# source .venv-pyodide/bin/activate

# build and install sip into pyodide's host python
# cd sip-6.8.3

# pip install -e ./pyodide-build
# ^ should output:  Successfully built /home/pradeep/projects/pyodide-with-pyqt5/sip-6.8.3/dist/sip-6.8.3-py3-none-any.whl

# python setup.py install
# ^ should output: Installed /home/pradeep/projects/pyodide-with-pyqt5/.venv-pyodide/lib/python3.11/site-packages/sip-6.8.3-py3.11.egg


## PyQt6-SIP
# extract pyqt6sip from https://pypi.org/project/PyQt6-sip/#files
tar -xf sources/PyQt6_sip-13.6.0.tar.gz
cd PyQt6_sip-13.6.0

# (native build)
python setup.py install

# (wasm build with setup.py)
# below command fails with error "emscripten does not support processes"
# python setup.py install

# (wasm build with pyodide)
# below command does not work in pyodide environment
# should output /home/pradeep/projects/pyodide-with-pyqt5/PyQt6_sip-13.6.0/dist/PyQt6_sip-13.6.0-cp311-cp311-emscripten_3_1_37_wasm32.whl
# TODO (pradeep): Should pyqt6-sip be built with SIP_STATIC_MODULE defined?

# fixes memory errors when importing pyqt6-sip with pthread turned on
LDFLAGS="-sSHARED_MEMORY=1" CFLAGS="-pthread -fPIC -lembind" PYODIDE_ROOT=../pyodide pyodide build &> ../logs/pyqt6-sip-build.log

# PYODIDE_ROOT=../pyodide pyodide build &> ../logs/pyqt6-sip-build.log
# we should then be able to load this in the browser by doing a  await micropip.install('http://localhost:8000/PyQt6_sip-13.6.0/dist/PyQt6_sip-13.6.0-cp311-cp311-emscripten_3_1_37_wasm32.whl')

# (wasm build with emcc outputing .lib)
rm -rf libsip.a build_objects
mkdir -p build_objects
emcc -pthread -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_array.c -o build_objects/sip_array.o

# looks like sip_bool.cpp is only required on windows
# emcc -pthread -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_bool.cpp -o build_objects/sip_bool.o

emcc -pthread -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_core.c -o build_objects/sip_core.o

emcc -pthread -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_descriptors.c -o build_objects/sip_descriptors.o

emcc -pthread -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_enum.c -o build_objects/sip_enum.o

emcc -pthread -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_int_convertors.c -o build_objects/sip_int_convertors.o

emcc -pthread -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_object_map.c -o build_objects/sip_object_map.o

emcc -pthread -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_threads.c -o build_objects/sip_threads.o

emcc -pthread -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_voidptr.c -o build_objects/sip_voidptr.o

emar cqs libsip.a build_objects/*.o


## PyQt6
# extract pyqt6 from https://pypi.org/project/PyQt6/#files
tar -xf sources/PyQt6-6.6.1.tar.gz
cd PyQt6-6.6.1
# TODO (pradeep): Should this also be compiled to WASM?
pip install --no-cache-dir PyQt-builder
# sip-install --qmake ../qt6-build-wasm/qtbase/bin/qt-cmake --confirm-license --verbose
# sip-install --qmake /usr/local/Qt-6.6.3/bin/qmake --confirm-license --verbose

# (test) native PyQt6
# sip-install --qmake ../qt6-native-host/bin/qmake --confirm-license --build-dir $(realpath ../pyqt6-native-build) --target-dir $(realpath ../pyqt6-native-target) --verbose &> pyqt6-native-install.log

# native PyQt6
sip-build --no-make --qmake ../qt6-native-host/bin/qmake --confirm-license --build-dir $(realpath ../pyqt6-native-build) --target-dir $(realpath ../pyqt6-native-target) --verbose  &> ../logs/pyqt6-native-build.log

# native PyQt6 build and install
cd pyqt6-native-build
make &> ../logs/pyqt6-native-make.log
make install &> ../logs/pyqt6-native-install.log

# patches for project.py so that we only build QtCore, QtWidgets, QtGui
# the rest aren't required, and they either cause build errors or takes a long time to complete
cp ../temp/pyqt6__project.py project.py

# patches for pyqtbuild
cp ../temp/pyqtbuild__bindings.py ../.venv-native/lib/python3.11/site-packages/pyqtbuild/bindings.py

# this doesn't work with pyodide-venv
# chmod +x /home/pradeep/projects/pyodide-with-pyqt5/.venv-pyodide/bin/sip-*
# chmod +666 /home/pradeep/projects/pyodide-with-pyqt5/.venv-pyodide/bin/sip-*

# This builds and runs the Makefile, resulting in a LOT of errors
# I manually removed the entries that failed in /home/pradeep/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/Makefile and /home/pradeep/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/sipQtCorecmodule.cpp
# Once that's done I ran make in QtCore and that built libQtCore.a succesfully
# sip-build --qmake ../qt6/qtbase/bin/qmake --confirm-license --build-dir $(realpath ../pyqt6-wasm-build) --target-dir $(realpath ../pyqt6-wasm-target) --verbose  &> ../logs/pyqt6-wasm-build.log

# patch QtCoremmod.sip
cp ../temp/pyqt6-wasm-build__QtCore__QtCoremod.sip sip/QtCore/QtCoremod.sip

# This works fine by first letting sip-build construct the make files and then making it manually after applying the patch files
sip-build --no-make --qmake ../qt6-wasm-host/bin/qmake --confirm-license --build-dir $(realpath ../pyqt6-wasm-build) --target-dir $(realpath ../pyqt6-wasm-target) --verbose  &> ../logs/pyqt6-wasm-build.log

cd pyqt6-wasm-build

# apply patch files
# TODO (pradeep): Turn these into patch files
# TODO (pradeep): Make -fPIC work. Maybe changing sourcecode is disrupting mappings?
cp ../temp/pyqt6-wasm-build__QtCore__Makefile QtCore/Makefile
# cp ../temp/pyqt6-wasm-build__QtCore__sipQtCorecmodule.cpp QtCore/sipQtCorecmodule.cpp 
cp ../temp/pyqt6-wasm-build__QtCore__sipQtCoreQReadLocker.cpp  QtCore/sipQtCoreQReadLocker.cpp
cp ../temp/pyqt6-wasm-build__QtCore__sipQtCoreQWriteLocker.cpp QtCore/sipQtCoreQWriteLocker.cpp 

cp ../temp/pyqt6-wasm-build__QtGui__Makefile QtGui/Makefile
cp ../temp/pyqt6-wasm-build__QtWidgets__Makefile QtWidgets/Makefile

# TODO (pradeep):
# Had to remove sipType_QThreadPool from qobject.sip:276:32
# Had to remove "%Include qthreadpool.sip" and "%Include qsemaphore.sip" from QtCoremod.sip
# Had to remove sipQtCoreQSystemSemaphore.o, sipQtCoreQThreadPool.o, sipQtCoreQSemaphoreReleaser.o, sipQtCoreQSemaphore.o, sipQtCoreQRecursiveMutex.o, from Makefile due to missing headers
# Had to remove sipQtCoreQMutex.o from Makefie due to hard compilation errors

make &> ../logs/pyqt6-wasm-make.log
make install &> ../logs/pyqt6-wasm-install.log

mkdir -p pyqt6-wasm-target
cd pyqt6-wasm-target

# # TODO (pradeep): Create shared object files out of .a files
# # for f in PyQt6/*.so; do mv -- "$f" "${f%.so}.a"; done
# em++  -I../../pyodide/cpython/build/Python-3.11.3 -I../../pyodide/cpython/build/Python-3.11.3/Include  -shared QtGui.a ../../pyodide/cpython/installs/python-3.11.3/lib/libpython3.11.a -sSIDE_MODULE=2 -o QtGui.abi3.so
# em++ -I../../pyodide/cpython/build/Python-3.11.3 -I../../pyodide/cpython/build/Python-3.11.3/Include -sSIDE_MODULE -shared -fPIC ../../pyodide/emsdk/emsdk/upstream/emscripten/cache/sysroot/lib/wasm32-emscripten/pic/libc++.a ../../pyodide/cpython/installs/python-3.11.3/lib/libpython3.11.a QtGui.a  -o QtGui.abi3.so
# em++ -s EXPORT_ALL=1 -s ASSERTIONS=1 -I../../pyodide/cpython/build/Python-3.11.3 -I../../pyodide/cpython/build/Python-3.11.3/Include -sSIDE_MODULE -shared -fPIC --rtlib=compiler-rt ../../pyodide/emsdk/emsdk/upstream/emscripten/cache/sysroot/lib/wasm32-emscripten/pic/libc.a ../../pyodide/emsdk/emsdk/upstream/emscripten/cache/sysroot/lib/wasm32-emscripten/pic/libc++.a ../../pyodide/cpython/installs/python-3.11.3/lib/libpython3.11.a QtGui.a  -o QtGui.abi3.so
# em++ $(OBJECTS) -shared -sSIDE_MODULE=1 -o QtCore.abi3.so
# em++ $(OBJECTS) -shared -sSIDE_MODULE=2 -o QtCore.abi3.so

# HACKY: create the wheel manually post-installation
# (cp ../temp/WHEEL PyQt6-6.6.1.dist-info/ && rm -rf PyQt6-6.6.1-py3-none-any.whl && zip -r PyQt6-6.6.1-py3-none-any.whl .)
# (cd .. && cp ../temp/WHEEL PyQt6-6.6.1.dist-info/ && rm -rf PyQt6-6.6.1-py3-none-any.whl && zip -r PyQt6-6.6.1-py3-none-any.whl .)
cp ../temp/WHEEL PyQt6-6.6.1.dist-info/
rm -rf PyQt6-6.6.1-py3-none-any.whl
zip -r PyQt6-6.6.1-py3-none-any.whl .

# this also doesn't work with pyodide-venv
# sip-install --qmake ../qt6/qtbase/bin/qmake --confirm-license --verbose &> pyqt6-build.log

# sip-install --qmake ../qt6-host/qtbase/bin/qmake --confirm-license --build-dir ../pyqt6-build-native --target-dir ../pyqt6-target-native --verbose &> pyqt6-build-native.log
# TODO (pradeep): Do we need the patches for QtCore, QtGui, etc?

# TODO (pradeep): Verify that sip-install is the one that generated qt6/qtbase/lib/libQt6Core.a, libQt6Gui.a, etc

### rebuild pyodide and link to static SIP, Qt, PyQt libraries
pushd pyodide
    # apply patches for pyodide
    cp ../temp/pyodide__src__core__main.c src/core/main.c
    cp ../temp/pyodide__src__js__module.ts src/js/module.ts 
    cp ../temp/pyodide__src__templates__console.html  src/templates/console.html
popd

# Build final bundle
rm -rf build-qt6
mkdir -p build-qt6
pushd build-qt6
    # copy necessary build artifacts from pyodide
    cp ../pyodide/dist/console.html index.html
    cp ../pyodide/dist/pyodide.asm.data .
    cp ../pyodide/dist/pyodide.asm.js .
    cp ../pyodide/dist/pyodide.asm.wasm .
    cp ../pyodide/dist/pyodide.mjs .
    cp ../pyodide/dist/pyodide.mjs.map .
    cp ../pyodide/dist/python_stdlib.zip .
    cp ../pyodide/dist/repodata.json .

    # copy pyqt6 examples
    mkdir -p examples
    cp ../examples/qt6_*.py ./examples/

    # remove broken examples
    rm -rf ./examples/qt6_file_picker.py

    # don't keep native examples since they don't run in WASM
    rm -rf ./examples/qt6_native*

    # copy the http server util script
    cp ../http_server.py .

    # bundle everything!
    rm -rf pyqt6-wasm.zip
    zip -r pyqt6-wasm.zip .
popd
