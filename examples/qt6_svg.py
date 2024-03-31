from PyQt6 import QtCore, QtGui, QtWidgets, QtSvg
from PyQt6.QtCore import Qt

def make_button():
    btn = QtWidgets.QPushButton("Save SVG")
    btn.clicked.connect(clicked)
    btn.show()
    return btn

def clicked():
    rect = QtCore.QRect(0, 0, 150, 50)
    gen = QtSvg.QSvgGenerator()
    gen.setSize(rect.size())
    gen.setViewBox(rect)
    buffer = QtCore.QBuffer()
    buffer.open(QtCore.QIODevice.OpenModeFlag.ReadWrite)
    gen.setOutputDevice(buffer)
    painter = QtGui.QPainter()
    painter.begin(gen)
    color = QtGui.QColor(255, 0, 0)
    painter.setPen(color)
    painter.drawText(10, 10, 100, 25, Qt.AlignmentFlag.AlignCenter, "This is a test.")
    painter.end()
    buffer.seek(0)
    svg = buffer.readAll()
    print ("svg: ", svg)
    QtWidgets.QFileDialog.saveFileContent(svg, "test.svg")

# app = QtWidgets.QApplication([])
QtGui.QFontDatabase.addApplicationFont('/usr/lib/fonts/Vera.ttf')

panel = make_button()
