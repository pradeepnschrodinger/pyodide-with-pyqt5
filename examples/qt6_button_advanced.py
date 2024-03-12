import sys
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
        self.button = button
        self.show()
    @pyqtSlot()
    def on_click(self):
        print('PyQt6 button click')

QApplication([])
app = App()
QtGui.QFontDatabase.addApplicationFont('/usr/lib/fonts/Vera.ttf')

# if __name__ == '__main__':
#     app = QApplication(sys.argv)
#     ex = App()
#     sys.exit(app.exec_())
