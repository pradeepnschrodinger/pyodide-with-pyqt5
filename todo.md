### multiprocessing isn't functional in pyodide
This causes setup.py to not work for python running in a pyodide venv.
`multiprocessing` can still be imported in pyodide though.

Try building it in pyodide -- https://pyodide.org/en/stable/usage/wasm-constraints.html#included-but-not-working-modules

### WASM resources like fonts, window svg icons not set

/home/niranjanpba/projects/pyodide-with-pyqt5/qt6/qtbase/src/plugins/platforms/wasm/CMakeLists.txt

Can be worked around by preloading resources into pyodide.asm.js

### Shared/dynamic library support

Dynamic linking support is currently in developer preview. The implementation is suitable for prototyping and evaluation, but is not suitable for production use. Current limitations and restrictions include:


https://doc.qt.io/qt-6/wasm.html#shared-libraries-and-dynamic-linking-developer-preview

### QFileDialog doesn't work

It doesn't work cause it internally uses exec and QFileSystemModel, both of which starts threads.
```
    qWarning("Hello from getOpenFileUrl()");
    // auto fileOpenCompleted = [&](const QString &fileName, const QByteArray &fileContent) {
    //     qWarning("Hello from fileOpenCompleted()");
    // };
    // QFileDialog::getOpenFileContent("All Files (*)", fileOpenCompleted);
    // const QString x = "Hello!";
    // const QUrl y(x);
    // return x;
```

I tried using a build of QT not configured with qthreads.
This does open the dialog and I am able to play around it.
Unfortunately control never goes back to the dialog.

pyodide.asm.js:9 Warning: exec() is not supported on Qt for WebAssembly in this configuration. Please build with asyncify support, or use an asynchronous API like QDialog::open()
pyodide.asm.js:9 Uncaught Please compile your program with async support in order to use asynchronous operations like emscripten_sleep

https://forum.qt.io/topic/137030/trouble-using-asyncify/2

The warning is thrown by /home/niranjanpba/projects/pyodide-with-pyqt5/qt6/qtbase/src/corelib/kernel/qeventdispatcher_wasm.cpp
It looks like QT_STATIC isn't defined even though we're using a STATIC BUILD!

### Proper QT screen/window integration

Take a look at QWasmIntegration::setContainerElements


-----------------------------------


### Multithreading for Pyodide's Python in WASM
https://www.qt.io/blog/2019/06/26/qt-webassembly-multithreading says that "We’ve found that emscripten 1.38.30 works well for threaded builds.".

```
Main thread deadlocks Calling QThread::wait (or pthread_join) on the main thread may deadlock, since the browser will be blocked from servicing application requests such as starting a new Web Worker for the thread we are waiting on. Possible workarounds include:

Pre-allocate Web Workers using QMAKE_WASM_PTHREAD_POOL_SIZE (maps to emscripten PTHREAD_POOL_SIZE)
Don't join worker threads when not needed (e.g. app exit). Earlier versions of the Mandelbrot demo was freezing the tab on exit; solved by disabling application cleanup for the Qt build which powers it.

```

experiment with PTHREAD_POOL_SIZE


-----------------------------------

Checkout all examples from https://www.pythonguis.com/pyqt6-tutorial/ and https://www.pythonguis.com/tutorials/pyqt6-signals-slots-events/

-----------------------------------

### "no target window errors" gets spammed for every mouse event

This is likely from QT trying to support touch events.

-----------------------------------

### [WORKEDAROUND] Font's not loading in static PyQt6

maybe the ttf font file is missing in the virtual file system?

https://doc.qt.io/qt-6/qt-embedded-fonts.html says Qt might look in the lib/fonts/ directory

https://stackoverflow.com/questions/7402576/get-current-working-directory-in-a-qt-application

https://forum.qt.io/topic/30008/solved-qt-font-search-path/5

### [WORKAROUND]
Recompile pyodide and preload fonts directory via:
```
  --preload-file /home/niranjanpba/projects/pyodide-with-pyqt5/qt6/qtbase/src/3rdparty/wasm@/usr/lib/fonts \
```
and register new font path to PyQt6 font db via:
```
    QtGui.QFontDatabase.addApplicationFont('/usr/lib/fonts/Vera.ttf')
```

-----------------------------------

### Hack to avoid tslInit errors when attempting to relocate module
-fpic did not work here...

    function tlsInitWrapper() {
      // HACK (pradeep): Why is tlsInitFunc undefined? We might need fpic here
      if (!tlsInitFunc) {
        console.error("Niranjan: tslInitFunc is undefined!")
        return;
      }
      var __tls_base = tlsInitFunc();

### FinalizationRegistry hacks to avoid errors while initilization pyodide.asm.js when Qt modules are linked because of -lembind

    $$ = { ptr: ptrobj, type: "PyProxy", cache, flags };
    // HACK (pradeep): Massive hack to fix finialization registry error
    Module.finalizationRegistry = new FinalizationRegistry((value: string) => {
      console.log('Pradeep: Finalization registry value: ', value);
    });
    Module.finalizationRegistry.register($$, [ptrobj, cache], $$);
    Module._Py_IncRef(ptrobj);

------------------------------------

### duplicate symbols when attempting to link pyodide:
https://github.com/emscripten-core/emscripten/issues/11985#issuecomment-1018733271


------------------------------------

### -lcompiler_rt

------------------------------------

### Import PyQt6 dynamically using .so shared lib files


Tip: Use `pyodide auditwheel exports` to show what symbols are exported.
eg:
```
PYODIDE_ROOT=../../pyodide pyodide auditwheel exports /home/niranjanpba/projects/pyodide-with-pyqt5/PyQt6_sip-13.6.0/dist/extracted/PyQt6/sip.cpython-311-wasm32-emscripten.so
```

#### Errors when trying to link python lib into pyqt6
`EM_JS` is not supported in side modules
```
  if settings.SIDE_MODULE:
    if metadata.emJsFuncs:
      # HACK (pradeep):
      print ("Niranjan: ", metadata.emJsFuncs)
      # exit_with_error('EM_JS is not supported in side modules')
    logger.debug('emscript: skipping remaining js glue generation')
```

------------------------------------

### Import PyQt6 dynamically using static .a lib files

```
>>> import micropip
await micropip.install('http://localhost:8000/sip-6.8.3/dist
/sip-6.8.3-py3-none-any.whl')
await micropip.install('http://localhost:8000/PyQt6_sip-13.6
.0/dist/PyQt6_sip-13.6.0-cp311-cp311-emscripten_3_1_37_wasm3
2.whl')
>>> 
await micropip.install('http://localhost:8000/pyqt6-wasm-tar
get/PyQt6-6.6.1-py3-none-any.whl')
>>> import PyQt6.QtCore
Traceback (most recent call last):
  File "<console>", line 1, in <module>
ModuleNotFoundError: No module named 'PyQt6.QtCore'
>>> from PyQt6 import QtCore
Traceback (most recent call last):
  File "<console>", line 1, in <module>
ImportError: cannot import name 'QtCore' from 'PyQt6' (/lib/
python3.11/site-packages/PyQt6/__init__.py)
```

---------------------------------


### [SOLVED] WASM magic number issue when importing PyQt6.so libraries
Trying to dynamically import PyQt6.so files throws:
```
    var int32View = new Uint32Array(new Uint8Array(binary.subarray(0, 24)).buffer);
    var magicNumberFound = int32View[0] == 1836278016;
    failIf(!magicNumberFound, "need to see wasm magic number");
```
### [FIX]:

These weren't actually .so files.
PyQt6 Makefile simply renames the output library from '.a' to '.so'.
We can instead make a proper dynamic module via:
```
    em++ $(OBJECTS) -shared -sSIDE_MODULE=1 -o QtCore.abi3.so
```
    
---------------------------------

### Errors when trying to import PyQt6 wheel via micropip
```
>>> import micropip
>>> await micropip.install('http://localhost:8000/PyQt6_sip-13.6.0/dist/PyQt6_
sip-13.6.0-cp311-cp311-emscripten_3_1_37_wasm32.whl')
Traceback (most recent call last):
  File "<console>", line 1, in <module>
  File "/lib/python3.11/site-packages/micropip/_micropip.py", line 603, in ins
tall
    await gather(*wheel_promises)
  File "/lib/python3.11/site-packages/micropip/_micropip.py", line 246, in ins
tall
    await self.load_libraries(target)
  File "/lib/python3.11/site-packages/micropip/_micropip.py", line 237, in loa
d_libraries
    await gather(*map(lambda dynlib: loadDynlib(dynlib, False), dynlibs))
pyodide.ffi.JsException: LinkError: WebAssembly.instantiate(): Import #198 mod
ule="env" function="memory": mismatch in shared state of memory, declared = 0,
 imported = 1
>>> import PyQt6
>>> import PyQt6.sip
Traceback (most recent call last):
  File "<console>", line 1, in <module>
ImportError: dynamic module does not define module export function (PyInit_sip
)
>>> await micropip.install('http://localhost:8000/pyqt6-wasm-target/PyQt6-6.6.
1-py3-none-any.whl')
>>> import PyQt6.sip
Traceback (most recent call last):
  File "<console>", line 1, in <module>
ImportError: dynamic module does not define module export function (PyInit_sip
)
>>> import PyQt6.QtCore
Traceback (most recent call last):
  File "<console>", line 1, in <module>
ImportError: dynamic module does not define module export function (PyInit_QtC
ore)
```
----------

### [SOLVED] QtWayland isn't configured for native build
```
-- Configuring submodule 'qtwayland'
CMake Warning at qtwayland/src/CMakeLists.txt:24 (message):
  QtWayland is missing required dependencies, nothing will be built.
  Although this could be considered an error, the configuration will still
  pass as coin (Qt's continuous integration system) will fail the build if
  configure fails, but will still try to configure the module on targets that
  are missing dependencies.
```
Solved by running passing `DISABLE_WAYLAND=1`.
eg:
```
DISABLE_WAYLAND=1 QT_DEBUG_PLUGINS=1 python3 examples/qt6_button_advanced.py
```

----------

### [SOLVED?] Pyodide with pthreads support

Simply compiling pyodide.asm with "-s USE_PTHREADS=1" throws:
```
wasm-ld: error: --shared-memory is disallowed by pegen.o because it was not compiled with 'atomics' or 'bulk-memory' features.
```

### [FIX?]

Looks like I need to compile pyodide with and cpython with pthreads enabled (eg: https://github.com/pyodide/pyodide/issues/237#issuecomment-1689899764)

-----------

Try getting an egg/wheel by using sip-wheel
eg: sip-wheel --verbose --jobs {cpu_count()} --build-dir {temp_build_dir} --pep484-pyi'
https://github.com/schrodinger/lib-build-scripts/blob/b73ff16974bc77c11c1ffec07f0d3f46422e8367/scripts/pyqt_tasks.py#L301

-----------

Pyodide link troubles with static PyQt6

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

[FIXED]:
link extra dependencies as described in qt6-wasm-build/qtbase/lib/libQt6Core.prl

Here's an example where I pulled ALL dependencies for Qt:
dist/pyodide.asm.js: \
	src/core/main.o  \
	$(wildcard src/py/lib/*.py) \
	libgl \
	$(CPYTHONLIB) \
	dist/libpyodide.a
	date +"[%F %T] Building pyodide.asm.js..."
	[ -d dist ] || mkdir dist
	$(CXX) -o dist/pyodide.asm.js dist/libpyodide.a \
	src/core/main.o $(MAIN_MODULE_LDFLAGS) \
	-sUSE_WEBGL2=1 -sFULL_ES2=1 \
	-sERROR_ON_UNDEFINED_SYMBOLS=0 \
	-pthread \
	-lembind \
	-lidbfs.js \
	-lidbstore.js \
	-lasync.js \
	/home/niranjanpba/projects/pyodide-with-pyqt5/PyQt6_sip-13.6.0/libsip.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/objects-Release/Widgets_resources_1/.rcc/qrc_qstyle.cpp.o \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/objects-Release/Widgets_resources_2/.rcc/qrc_qstyle1.cpp.o \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/objects-Release/Gui_resources_1/.rcc/qrc_qpdf.cpp.o \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/objects-Release/Gui_resources_2/.rcc/qrc_gui_shaders.cpp.o \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/objects-Release/Widgets_resources_3/.rcc/qrc_qmessagebox.cpp.o \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/libQt6BundledPcre2.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/libQt6BundledHarfbuzz.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/libQt6Core.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/libQtCore.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/libQt6BundledFreetype.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/libQt6BundledLibpng.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/libQt6Gui.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtGui/libQtGui.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/lib/libQt6Widgets.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtWidgets/libQtWidgets.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/plugins/platforms/libqwasm.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/plugins/platforms/libqoffscreen.a \
	/home/niranjanpba/projects/pyodide-with-pyqt5/qt6-wasm-host/plugins/platforms/libqminimal.a \

----

### [FIXED] Undefined references to QThread library symbols

References to QThread libraries' symbols (eg: _ZN7QThread11setPriorityENS_8PriorityE) are undefined (U) in the wasm version of QtCore.abi3.so
However, libQt6Core.so from native version does work

warning: undefined symbol: _ZN7QThread11setPriorityENS_8PriorityE (referenced by top-level compiled C/C++ code)

```
emnm PyQt6/QtCore.abi3.so | grep _ZN7QThread11setPriorityENS_8PriorityE
         U _ZN7QThread11setPriorityENS_8PriorityE


nm /home/pradeep/projects/pyodide-with-pyqt5/qt6-native-host/lib/libQt6Core.so | grep _ZN7QThread11setPriorityENS_8PriorityE
00000000002710b0 T _ZN7QThread11setPriorityENS_8PriorityE
00000000000c7b06 t _ZN7QThread11setPriorityENS_8PriorityE.cold
```

### [FIX]
Configure both Qt6 native and wasm builds with -feature-thread

-----------

### PyQt6.QtCore import troubles

```
>>> import PyQt6.QtCore
Niranjan:  In PyQt6__init__.py
Niranjan:  __path__ =  ['/lib/python3.11/site-packages/PyQt6']
Niranjan:  __name__ =  PyQt6
Traceback (most recent call last):
  File "<console>", line 1, in <module>
ImportError: dynamic module does not define module export function (PyInit_QtCore)
```

Checkout why Pyinit_QtCore isn't defined in QtCore.abi3.so ?
/home/pradeep/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/sipQtCorecmodule.cpp

```
emnm PyQt6/QtCore.abi3.so | grep PyInit_QtCore
00003804 T PyInit_QtCore
00012d50 d _ZZ13PyInit_QtCoreE11sip_methods
00013ca8 d _ZZ13PyInit_QtCoreE14sip_module_def

emnm ../pyqt6-native-target/PyQt6/QtCore.abi3.so | grep PyInit_QtCore
00000000000c66d0 T PyInit_QtCore
00000000003024e0 d _ZZ13PyInit_QtCoreE11sip_methods
00000000002ff140 d _ZZ13PyInit_QtCoreE14sip_module_def
```
------------

### [FIXED] QTimeZone errors when Makeing pyqt6

```
/home/pradeep/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/sipQtCorecmodule.cpp:9017:30: error: no member named 'NameType' in 'QTimeZone'
    qMetaTypeId<::QTimeZone::NameType>();
                ~~~~~~~~~~~~~^
/home/pradeep/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/sipQtCorecmodule.cpp:9018:30: error: no member named 'TimeType' in 'QTimeZone'
    qMetaTypeId<::QTimeZone::TimeType>();
```

^ Seems like the above errors are coming because qtimezone.h has
#if QT_CONFIG(timezone)
There's a high chance this is not defined?

checkout /home/pradeep/projects/pyodide-with-pyqt5/qt6/qtbase/src/corelib/qtcore-config.h where they have explicitly disabled timezone

checkout /home/pradeep/projects/pyodide-with-pyqt5/qt6/qtbase/src/corelib/global/qtconfigmacros.h for definition for QT_CONFIG

#define QT_CONFIG(feature) (1/QT_FEATURE_##feature == 1)

This seems to be the source: /home/pradeep/projects/pyodide-with-pyqt5/qt6/qtbase/src/corelib/configure.cmake

### [FIX]
Fixed by modifying the following cmake `qt6/qtbase/src/corelib/configure.cmake` so that we explicitly allow timezone features for WASM environment.