import sys

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction
from PyQt6.QtWidgets import QApplication, QLabel, QMainWindow, QMenu
from PyQt6 import QtGui

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()

    def contextMenuEvent(self, e):
        context = QMenu(self)
        context.addAction(QAction("test 1", self))
        context.addAction(QAction("test 2", self))
        context.addAction(QAction("test 3", self))
        context.exec(e.globalPos())


# app = QApplication(sys.argv)
QtGui.QFontDatabase.addApplicationFont('/usr/lib/fonts/Vera.ttf')

window = MainWindow()
window.show()

# app.exec()
