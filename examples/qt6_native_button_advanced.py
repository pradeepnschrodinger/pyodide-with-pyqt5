# run with:
# DISABLE_WAYLAND=1 QT_DEBUG_PLUGINS=1 python3 examples/qt6_button_advanced.py

import sys
sys.path.append('/home/pradeep/projects/pyodide-with-pyqt5/pyqt6-native-target')
                
from PyQt6.QtWidgets import QApplication, QWidget, QPushButton
from PyQt6.QtGui import QIcon
from PyQt6.QtCore import pyqtSlot

class App(QWidget):
    def __init__(self):
        super().__init__()
        self.title = 'PyQt5 button'
        self.left = 10
        self.top = 10
        self.width = 320
        self.height = 200
        self.initUI()
  
    def initUI(self):
        self.setWindowTitle(self.title)
        self.setGeometry(self.left, self.top, self.width, self.height)
        button = QPushButton('Button at (100, 70)', self)
        button.setToolTip('Button tooltip!')
        button.move(100,70)
        button.clicked.connect(self.on_click)
        self.show()

    @pyqtSlot()
    def on_click(self):
        print('PyQt5 button click')

# App()

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = App()
    sys.exit(app.exec())
