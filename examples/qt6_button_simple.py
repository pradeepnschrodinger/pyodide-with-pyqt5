from PyQt6 import QtWidgets
from PyQt6 import QtCore

# app = QtWidgets.QApplication([])
btn = QtWidgets.QPushButton("This is a button")
btn.show()
# app.exec()


############

from PyQt6.QtWidgets import QApplication, QWidget, QPushButton
from PyQt6.QtCore import Qt
 
class Window(QWidget):
    def __init__(self):
        super().__init__()
        self.resize(250, 250)
        self.setWindowTitle("CodersLegacy") 
        button = QPushButton("Hello World", self)
        button.move(100, 100)
 
 
# app = QApplication(sys.argv)
app = QApplication([])
window = Window()
window.show()


# import sys
# from PyQt6.QtWidgets import QApplication, QPushButton

# # app = QApplication(sys.argv)

# window = QPushButton("Push Me")
# window.show()

# app.exec()