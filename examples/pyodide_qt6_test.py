import micropip
await micropip.install('http://localhost:8000/sip-6.8.3/dist/sip-6.8.3-py3-none-any.whl')
await micropip.install('http://localhost:8000/PyQt6_sip-13.6.0/dist/PyQt6_sip-13.6.0-cp311-cp311-emscripten_3_1_45_wasm32.whl')
await micropip.install('http://localhost:8000/pyqt6-wasm-target/PyQt6-6.6.1-py3-none-any.whl')

from os import listdir
listdir('/lib/python3.11/site-packages')
