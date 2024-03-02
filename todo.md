----------

[DONE?]: Looks like I need to compile pyodide with and cpython with pthreads enabled (eg: https://github.com/pyodide/pyodide/issues/237#issuecomment-1689899764)

# attempt compiling pyodide with "-s USE_PTHREADS=1"
../make-pyodide.sh

wasm-ld: error: --shared-memory is disallowed by pegen.o because it was not compiled with 'atomics' or 'bulk-memory' features.

-----------

Pyodide link troubles

../make-pyodide.sh 
warning: undefined symbol: _ZN7QThread11setPriorityENS_8PriorityE (referenced by top-level compiled C/C++ code)
warning: undefined symbol: _ZN7QThread21setTerminationEnabledEb (referenced by top-level compiled C/C++ code)
warning: undefined symbol: _ZNK7QThread8priorityEv (referenced by top-level compiled C/C++ code)
warning: undefined symbol: _ZNK7QThread9loopLevelEv (referenced by top-level compiled C/C++ code)
warning: undefined symbol: emscripten_idb_async_delete (referenced by top-level compiled C/C++ code)
warning: undefined symbol: emscripten_idb_async_exists (referenced by top-level compiled C/C++ code)
warning: undefined symbol: emscripten_idb_async_load (referenced by top-level compiled C/C++ code)
warning: undefined symbol: emscripten_idb_async_store (referenced by top-level compiled C/C++ code)
warning: undefined symbol: emscripten_sleep (referenced by top-level compiled C/C++ code)
warning: undefined symbol: pcre2_code_free_16 (referenced by top-level compiled C/C++ code)
warning: undefined symbol: pcre2_compile_16 (referenced by top-level compiled C/C++ code)
warning: undefined symbol: pcre2_config_16 (referenced by top-level compiled C/C++ code)
warning: undefined symbol: pcre2_get_error_message_16 (referenced by top-level compiled C/C++ code)
warning: undefined symbol: pcre2_get_ovector_pointer_16 (referenced by top-level compiled C/C++ code)
warning: undefined symbol: pcre2_jit_compile_16 (referenced by top-level compiled C/C++ code)
warning: undefined symbol: pcre2_jit_stack_assign_16 (referenced by top-level compiled C/C++ code)
warning: undefined symbol: pcre2_jit_stack_create_16 (referenced by top-level compiled C/C++ code)

----
[TODO]: Configure Qt6 native and wasm builds with -feature-thread

References to QThread libraries' symbols (eg: _ZN7QThread11setPriorityENS_8PriorityE) are undefined (U) in the wasm version of QtCore.abi3.so
However, libQt6Core.so from native version does work

warning: undefined symbol: _ZN7QThread11setPriorityENS_8PriorityE (referenced by top-level compiled C/C++ code)

emnm PyQt6/QtCore.abi3.so | grep _ZN7QThread11setPriorityENS_8PriorityE
         U _ZN7QThread11setPriorityENS_8PriorityE


nm /home/pradeep/projects/pyodide-with-pyqt5/qt6-native-host/lib/libQt6Core.so | grep _ZN7QThread11setPriorityENS_8PriorityE
00000000002710b0 T _ZN7QThread11setPriorityENS_8PriorityE
00000000000c7b06 t _ZN7QThread11setPriorityENS_8PriorityE.cold

-----------

PyQt6.QtCore import troubles

>>> import PyQt6.QtCore
Niranjan:  In PyQt6__init__.py
Niranjan:  __path__ =  ['/lib/python3.11/site-packages/PyQt6']
Niranjan:  __name__ =  PyQt6
Traceback (most recent call last):
  File "<console>", line 1, in <module>
ImportError: dynamic module does not define module export function (PyInit_QtCore)

Checkout why Pyinit_QtCore isn't defined in QtCore.abi3.so ?
/home/pradeep/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/sipQtCorecmodule.cpp

emnm PyQt6/QtCore.abi3.so | grep PyInit_QtCore
00003804 T PyInit_QtCore
00012d50 d _ZZ13PyInit_QtCoreE11sip_methods
00013ca8 d _ZZ13PyInit_QtCoreE14sip_module_def

emnm ../pyqt6-native-target/PyQt6/QtCore.abi3.so | grep PyInit_QtCore
00000000000c66d0 T PyInit_QtCore
00000000003024e0 d _ZZ13PyInit_QtCoreE11sip_methods
00000000002ff140 d _ZZ13PyInit_QtCoreE14sip_module_def
------------

pyqt6 make troubles

/home/pradeep/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/sipQtCorecmodule.cpp:9017:30: error: no member named 'NameType' in 'QTimeZone'
    qMetaTypeId<::QTimeZone::NameType>();
                ~~~~~~~~~~~~~^
/home/pradeep/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/sipQtCorecmodule.cpp:9018:30: error: no member named 'TimeType' in 'QTimeZone'
    qMetaTypeId<::QTimeZone::TimeType>();

^ Seems like the above errors are coming because qtimezone.h has
#if QT_CONFIG(timezone)
There's a high chance this is not defined?

checkout /home/pradeep/projects/pyodide-with-pyqt5/qt6/qtbase/src/corelib/qtcore-config.h where they have explicitly disabled timezone

checkout /home/pradeep/projects/pyodide-with-pyqt5/qt6/qtbase/src/corelib/global/qtconfigmacros.h for definition for QT_CONFIG

#define QT_CONFIG(feature) (1/QT_FEATURE_##feature == 1)

This seems to be the source: /home/pradeep/projects/pyodide-with-pyqt5/qt6/qtbase/src/corelib/configure.cmake
------------

[FIXED] The pyodide version used here is pretty old, and does not have the pyodide.unpackArchive API.
Find an alternative so that we have a way of importing our app bundle.

Use pyodide v0.24.1

------------

[FIXED] The entire build process took 29958s or ~8.3hours...
Most of the time was spent on cloning, perl-initiating, and compiling the QT5 repo.
Checkout timings at "./logs/time-Thu Feb  8 03:58:06 AM IST 2024.log"

As long as the qt5 repo directory isn't removed, we should be good.
Use `git clean -fdxf ` instead for a faster reset.

------------

[FIXED] After building pyodide, there seems to be errors with an npm command
```
Error running ['/home/pradeep/projects/pyodide-with-pyqt5/pyodide/emsdk/emsdk/node/8.9.1_64bit/bin/npm', 'ci', '--production', '--no-optional']:
```

I might have to checkout out emsdk from Nov 26, 2020

------------