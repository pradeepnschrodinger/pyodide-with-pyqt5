### CPYTHON
# git clone https://github.com/python/cpython.git
pushd cpython
    #git checkout v3.11.8
    git checkout v3.11.3
    ./configure --prefix $(realpath -m ./host/3.11.3)
    make
    make install
popd

### PYTHON VENV
./cpython/host/3.11.3/bin/python3.11 -m venv .venv-native
source .venv-native/bin/activate
pip install pyyaml

### PYODIDE
# git clone https://github.com/iodide-project/pyodide.git
push pyodide
    git checkout bda1ba4edf6e4140952c5596e4af47521d21f7eb #v0.24.1
    # git checkout 0fe04cd97d9c808a9d77335a630faf371f7ec200
    pip install -r requirements.txt --no-cache-dir
    # fix an issue related to pyndatic (see: https://stackoverflow.com/a/76958769)
    pip install pydantic==1.10.9 --no-cache-dir

    # apply patch for emsdk to fetch tags and checkout the 3.1.37 version of emsdk which Qt6 needs
    # TODO (pradeep): Turn these into real patches
    # git apply ../patches/pyodide-emsdk-old-checkout.patch

    # apply patches for pyodide's cpython for wasm pthread support
    # TODO (pradeep): Turn these into real patches
    # cp ../temp/pyodide__cpython__Makefile cpython/Makefile

    # build setuptools and other core libraries
    # PYODIDE_PACKAGES="toolz,attrs,core" make &> ../logs/pyodide-make.log
    PYODIDE_JOBS=1 PYODIDE_PACKAGES="toolz,attrs,core,numpy,scipy" make &> ../logs/pyodide-make-msv.log

    source ./emsdk/emsdk/emsdk_env.sh
popd

### QT6
# git clone git://code.qt.io/qt/qt5.git qt6
# git clone https://code.qt.io/qt/qt5.git qt6
push qt6
    git switch 6.6.1
    # needs to be timed
    perl init-repository

    # apply patches in qtbase to configure timzeone, semaphore, and thread features to always be enabled
    push qtbase
        # TODO (pradeep): Do we need to patch cmake/QtInternalTargets.cmake ?

        # patch to enable most features for WASM build
        git apply ../../patches/qt6-wasm-enable-features.patch

        # patch to enable "minimal" and "offscreen" plugins for WASM build
        git apply ../../patches/qt6-wasm-enable-plugins.patch

        # patch to supress pointer event warnings for touch events
        # TODO (pradeep): Fix this or configure to not use touch events
        git apply ../../patches/qt6-disable-touch-events.patch

        # apply patch to fix icon paths for FileDialog for wasm
        # TODO (pradeep): Figure out why this was broken in the first place
        git apply ../../patches/qt6-wasm-fix-window-svgs.patch
    popd
popd

# only configure required modules by skipping everything else
QT_MODULES_SKIP_FLAGS=$(./qt6_module_skip_flags.sh "qtbase qtsvg")

## setup qt6 for native platform
mkdir -p qt6-native-build
pushd qt6-native-build
    # configure qt6 for native platform
    ../qt6/configure -static $QT_MODULES_SKIP_FLAGS -prefix ../qt6-native-host -nomake examples -confirm-license &> ../logs/qt6-native-configure.log
    
    # build qt6 for native platform
    cmake --build . --parallel &> ../logs/qt6-native-build.log
    cmake --install . &> ../logs/qt6-native-install.log
popd

## setup qt6 for wasm platform
# https://doc.qt.io/qt-6/wasm.html#wasm-building-qt-from-source
mkdir qt6-wasm-build
pushd qt6-wasm-build
    # configure qt6 for wasm platform
    ../qt6/configure -static $QT_MODULES_SKIP_FLAGS -qt-host-path $(realpath ../qt6-native-host) -platform wasm-emscripten -prefix $(realpath ../qt6-wasm-host) &> ../logs/qt6-wasm-configure.log

    # build qt6 for wasm platform
    cmake --build . --parallel -v &> ../logs/qt6-wasm-build.log
    cmake --install . &> ../logs/qt6-wasm-install.log
popd

### PyQt6-SIP
# extract pyqt6sip from https://pypi.org/project/PyQt6-sip/#files
tar -xf sources/PyQt6_sip-13.6.0.tar.gz
pushd PyQt6_sip-13.6.0

    rm -rf libsip.a build_objects
    mkdir -p build_objects

    emcc -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_array.c -o build_objects/sip_array.o

    # looks like sip_bool.cpp is only required on windows
    # emcc -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_bool.cpp -o build_objects/sip_bool.o

    emcc -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_core.c -o build_objects/sip_core.o

    emcc -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_descriptors.c -o build_objects/sip_descriptors.o

    emcc -pthread -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_enum.c -o build_objects/sip_enum.o

    emcc -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_int_convertors.c -o build_objects/sip_int_convertors.o

    emcc -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_object_map.c -o build_objects/sip_object_map.o

    emcc -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_threads.c -o build_objects/sip_threads.o

    emcc -fPIC -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall  -I../pyodide/cpython/build/Python-3.11.3 -I../pyodide/cpython/build/Python-3.11.3/Include -c sip_voidptr.c -o build_objects/sip_voidptr.o

    # bundle all the object files into a static library
    emar cqs libsip.a build_objects/*.o
popd

### PyQt6
# extract pyqt6 from https://pypi.org/project/PyQt6/#files
tar -xf sources/PyQt6-6.6.1.tar.gz
pushd PyQt6-6.6.1

    # install PyQt tools (eg: sip-build)
    pip install --no-cache-dir PyQt-builder

    # patches for project.py so that we only build QtCore, QtWidgets, QtGui
    # the rest aren't required, and they either cause build errors or takes a long time to complete
    cp ../temp/pyqt6__project.py project.py

    # patches for pyqtbuild
    cp ../temp/pyqtbuild__bindings.py ../.venv-native/lib/python3.11/site-packages/pyqtbuild/bindings.py

    # PyQt6 to not initialize qt.conf
    cp ../temp/PyQt6__qpy__QtCore__qpycore_post_init.cpp qpy/QtCore/qpycore_post_init.cpp

    # patch QtCoremmod.sip to remove "%Include qthreadpool.sip" and "%Include qsemaphore.sip" from QtCoremod.sip
    cp ../temp/pyqt6-wasm-build__QtCore__QtCoremod.sip sip/QtCore/QtCoremod.sip

    # remove sipType_QThreadPool from qobject.sip:276:32
    cp ../temp/PyQt6__sip__QtCore__qobject.sip sip/QtCore/qobject.sip

    # configure PyQt6 wasm build but without running make yet
    sip-build --no-make --qmake ../qt6-wasm-host/bin/qmake --confirm-license --build-dir $(realpath ../pyqt6-wasm-build) --target-dir $(realpath ../pyqt6-wasm-target) --verbose  &> ../logs/pyqt6-wasm-build.log
popd

## Fix PyQt6 before building
push pyqt6-wasm-build
    # patch pyqt6-wasm-build/QtWidgets/sipQtWidgetsQApplication.cpp to import static QT plugins

    # patch pyqt6-wasm-build/QtCore/sipQtCoreQRecursiveMutex.cpp and pyqt6-wasm-build/QtCore/sipQtCoreQMutex.cpp to call sipCpp->tryLock() with zero timeout
    # eg: sipRes = sipCpp->tryLock(*a0);

    # Add -fPIC to compiler flags
    sed -i 's/CFLAGS[[:space:]]*=/& -fPIC/' ./QtCore/Makefile
    sed -i 's/CFLAGS[[:space:]]*=/& -fPIC/' ./QtGui/Makefile
    sed -i 's/CFLAGS[[:space:]]*=/& -fPIC/' ./QtWidgets/Makefile
    sed -i 's/CFLAGS[[:space:]]*=/& -fPIC/' ./QtSvg/Makefile
    sed -i 's/CFLAGS[[:space:]]*=/& -fPIC/' ./QtPrintSupport/Makefile

    sed -i 's/CXXFLAGS[[:space:]]*=/& -fPIC/' ./QtCore/Makefile
    sed -i 's/CXXFLAGS[[:space:]]*=/& -fPIC/' ./QtGui/Makefile
    sed -i 's/CXXFLAGS[[:space:]]*=/& -fPIC/' ./QtWidgets/Makefile
    sed -i 's/CXXFLAGS[[:space:]]*=/& -fPIC/' ./QtSvg/Makefile
    sed -i 's/CXXFLAGS[[:space:]]*=/& -fPIC/' ./QtPrintSupport/Makefile

    # configure correct python include paths
    sed -i 's|-I../../cpython/host/3.11.3/include/python3.11|-I../../pyodide/cpython/build/Python-3.11.3 -I../../pyodide/cpython/build/Python-3.11.3/Include|' ./QtCore/Makefile
    sed -i 's|-I../../cpython/host/3.11.3/include/python3.11|-I../../pyodide/cpython/build/Python-3.11.3 -I../../pyodide/cpython/build/Python-3.11.3/Include|' ./QtGui/Makefile
    sed -i 's|-I../../cpython/host/3.11.3/include/python3.11|-I../../pyodide/cpython/build/Python-3.11.3 -I../../pyodide/cpython/build/Python-3.11.3/Include|' ./QtWidgets/Makefile
    sed -i 's|-I../../cpython/host/3.11.3/include/python3.11|-I../../pyodide/cpython/build/Python-3.11.3 -I../../pyodide/cpython/build/Python-3.11.3/Include|' ./QtSvg/Makefile
    sed -i 's|-I../../cpython/host/3.11.3/include/python3.11|-I../../pyodide/cpython/build/Python-3.11.3 -I../../pyodide/cpython/build/Python-3.11.3/Include|' ./QtPrintSupport/Makefile

    # Fix "const" compilation issues by removing const qualifer
    # eg: const ::QReadLocker *sipCpp;
    # eg: const ::QWriteLocker *sipCpp;
    cp ../temp/pyqt6-wasm-build__QtCore__sipQtCoreQReadLocker.cpp  QtCore/sipQtCoreQReadLocker.cpp
    cp ../temp/pyqt6-wasm-build__QtCore__sipQtCoreQWriteLocker.cpp QtCore/sipQtCoreQWriteLocker.cpp 

    # build PyQt6 for wasm
    make &> ../logs/pyqt6-wasm-make.log
    make install &> ../logs/pyqt6-wasm-install.log
popd

### PYODIDE
#rebuild pyodide and link to static SIP, Qt, PyQt libraries
pushd pyodide
    # apply patches for pyodide
    cp ../temp/pyodide__src__core__main.c src/core/main.c
    cp ../temp/pyodide__src__js__module.ts src/js/module.ts 
    cp ../temp/pyodide__src__templates__console.html  src/templates/console.html
    cp ../temp/pyodide__src__core__pyproxy.ts src/core/pyproxy.ts
    cp ../temp/pyodide__Makefile Makefile

    make
popd

### PACKAGING
# build final bundle
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
