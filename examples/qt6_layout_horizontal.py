import sys

from PyQt6.QtCore import Qt, QSize
from PyQt6.QtWidgets import QMainWindow, QVBoxLayout, QWidget, QApplication
from PyQt6.QtGui import QPalette, QColor
from PyQt6 import QtGui

class Color(QWidget):

    def __init__(self, color):
        super(Color, self).__init__()
        self.setAutoFillBackground(True)

        palette = self.palette()
        palette.setColor(QPalette.ColorRole.Window, QColor(color))
        self.setPalette(palette)

class MainWindow(QMainWindow):

    def __init__(self):
        super(MainWindow, self).__init__()

        self.setWindowTitle("My App")

        layout = QVBoxLayout()

        layout.addWidget(Color('red'))
        layout.addWidget(Color('green'))
        layout.addWidget(Color('blue'))

        widget = QWidget()
        widget.setLayout(layout)
        self.setCentralWidget(widget)

#app = QApplication([])
QtGui.QFontDatabase.addApplicationFont('/usr/lib/fonts/Vera.ttf')

window = MainWindow()
window.show()
