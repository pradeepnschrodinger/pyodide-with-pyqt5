------------------------------------
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