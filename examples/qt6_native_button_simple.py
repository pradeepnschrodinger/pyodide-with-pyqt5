# run with:
# DISABLE_WAYLAND=1 QT_DEBUG_PLUGINS=1 python3 examples/qt6_native_button_simple.py

import os
print(os.environ)

import sys
sys.path.append('/home/pradeep/projects/pyodide-with-pyqt5/pyqt6-native-target')

from PyQt6 import QtWidgets

app = QtWidgets.QApplication([])
btn = QtWidgets.QPushButton("This is a button")
btn.show()
app.exec()
