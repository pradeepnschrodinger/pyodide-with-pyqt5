cd pyodide
em++ -o dist/pyodide.asm.js dist/libpyodide.a src/core/main.o -O2 -g0  -L/home/pradeep/projects/pyodide-with-pyqt5/pyodide/cpython/installs/python-3.11.3/lib/ -s WASM_BIGINT  -s MAIN_MODULE=1 -s MODULARIZE=1 -s LZ4=1 -s EXPORT_NAME="'_createPyodideModule'" -s EXPORT_EXCEPTION_HANDLING_HELPERS -s EXCEPTION_CATCHING_ALLOWED=['we only want to allow exception handling in side modules'] -sEXPORTED_RUNTIME_METHODS='stackAlloc,stackRestore,stackSave' -s DEMANGLE_SUPPORT=1 -s USE_ZLIB -s USE_BZIP2 -s FORCE_FILESYSTEM=1 -s TOTAL_MEMORY=20971520 -s ALLOW_MEMORY_GROWTH=1 -s EXPORT_ALL=1 -s POLYFILL -s MIN_SAFARI_VERSION=140000 -s STACK_SIZE=5MB -s AUTO_JS_LIBRARIES=0 -s AUTO_NATIVE_LIBRARIES=0 -s NODEJS_CATCH_EXIT=0 -s NODEJS_CATCH_REJECTION=0 -lpython3.11 -lffi -lstdc++ -lidbfs.js -lnodefs.js -lproxyfs.js -lworkerfs.js -lwebsocket.js -leventloop.js -lGL -legl.js -lwebgl.js -lhtml5_webgl.js -sGL_WORKAROUND_SAFARI_GETCONTEXT_BUG=0
if [[ -n ${PYODIDE_SOURCEMAP+x} ]] || [[ -n ${PYODIDE_SYMBOLS+x} ]] || [[ -n ${PYODIDE_DEBUG_JS+x} ]]; then \
	cd dist && npx prettier -w pyodide.asm.js ; \
fi
sed -i -E 's/var __Z[^;]*;//g' dist/pyodide.asm.js
sed -i '1i "use strict";' dist/pyodide.asm.js
# Remove last 4 lines of pyodide.asm.js, see issue #2282
# Hopefully we will remove this after emscripten fixes it, upstream issue
# emscripten-core/emscripten#16518
# Sed nonsense from https://stackoverflow.com/a/13383331
sed -i -n -e :a -e '1,4!{P;N;D;};N;ba' dist/pyodide.asm.js
echo "globalThis._createPyodideModule = _createPyodideModule;" >> dist/pyodide.asm.js