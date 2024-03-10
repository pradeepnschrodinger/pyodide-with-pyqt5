-----------------------------------

"no target window errors" gets spammed for every mouse event



-----------------------------------

Font's not loading in static PyQt6

maybe the ttf font file is missing in the virtual file system?

https://doc.qt.io/qt-6/qt-embedded-fonts.html says Qt might look in the lib/fonts/ directory

https://stackoverflow.com/questions/7402576/get-current-working-directory-in-a-qt-application

https://forum.qt.io/topic/30008/solved-qt-font-search-path/5

-----------------------------------
Hack to avoid tslInit errors when attempting to relocate module
-fpic did not work here...

    function tlsInitWrapper() {
      // HACK (pradeep): Why is tlsInitFunc undefined? We might need fpic here
      if (!tlsInitFunc) {
        console.error("Niranjan: tslInitFunc is undefined!")
        return;
      }
      var __tls_base = tlsInitFunc();

FinalizationRegistry hacks to avoid errors while initilization pyodide.asm.js when Qt modules are linked because of -lembind

    $$ = { ptr: ptrobj, type: "PyProxy", cache, flags };
    // HACK (pradeep): Massive hack to fix finialization registry error
    Module.finalizationRegistry = new FinalizationRegistry((value: string) => {
      console.log('Pradeep: Finalization registry value: ', value);
    });
    Module.finalizationRegistry.register($$, [ptrobj, cache], $$);
    Module._Py_IncRef(ptrobj);

------------------------------------

https://github.com/emscripten-core/emscripten/issues/11985#issuecomment-1018733271
-lcompiler_rt 

------------------------------------
Trying to import PyQt6 using .so shared lib files


Tip: Use `pyodide auditwheel exports` to show what symbols are exported.
eg:
PYODIDE_ROOT=../../pyodide pyodide auditwheel exports /home/niranjanpba/projects/pyodide-with-pyqt5/PyQt6_sip-13.6.0/dist/extracted/PyQt6/sip.cpython-311-wasm32-emscripten.so


  if settings.SIDE_MODULE:
    if metadata.emJsFuncs:
      # HACK (pradeep):
      print ("Niranjan: ", metadata.emJsFuncs)
      # exit_with_error('EM_JS is not supported in side modules')
    logger.debug('emscript: skipping remaining js glue generation')


------------------------------------
Trying to import PyQt6 using static .a lib files

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


---------------------------------


Trying to dynamically import 

                var int32View = new Uint32Array(new Uint8Array(binary.subarray(0, 24)).buffer);
                var magicNumberFound = int32View[0] == 1836278016;
                failIf(!magicNumberFound, "need to see wasm magic number");
    
    
    
---------------------------------



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