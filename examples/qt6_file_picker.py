from PyQt6.QtWidgets import QMainWindow, QApplication, QPushButton, QFileDialog
from PyQt6.QtCore import pyqtSlot
from PyQt6 import QtGui
import sys


class Main(QMainWindow):
    def __init__(self):
        super().__init__()
        btn = QPushButton(self)
        btn.setText("Open file dialog")
        self.setCentralWidget(btn)
        btn.clicked.connect(self.open_dialog)
    
    @pyqtSlot()
    def open_dialog(self):
        print ("Called open_dialog()")
        fname = QFileDialog.getOpenFileName(
            self,
            "Open File",
            "/home/pyodide/examples",
            "All Files (*);; Python Files (*.py);; PNG Files (*.png)",
        )
        print ("Got filename: ", fname)

        # NOTE (pradeep): Execute program
        import PyQt6.QtWidgets
        if (PyQt6.QtWidgets.QApplication.instance()):
          PyQt6.QtWidgets.QApplication.instance().closeAllWindows()
        exec(open(fname).read())
        
    
#app = QApplication([])
QtGui.QFontDatabase.addApplicationFont('/usr/lib/fonts/Vera.ttf')

main_gui = Main()
main_gui.show()
