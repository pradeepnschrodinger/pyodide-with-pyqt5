from PyQt6 import QtCore, QtGui, QtWidgets, QtSvg, QtPrintSupport
from PyQt6.QtCore import Qt
from pyodide.code import run_js

global_file_array_buffer = None
def send_wasm_file_to_browser(fileName):
    with open(fileName, 'rb') as fh:
        global global_file_array_buffer
        global_file_array_buffer = fh.read()

    run_js('''
        const fileArrayBuffer = pyodide.globals.get('global_file_array_buffer');
        const blob = new Blob([fileArrayBuffer.toJs()], {type : 'application/octet-stream'});
        let url = window.URL.createObjectURL(blob);

        var downloadLink = document.createElement("a");
        downloadLink.href = url;
        downloadLink.download = "foo.pdf";
        document.body.appendChild(downloadLink);
        downloadLink.click();
    ''')

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

    renderer = QtSvg.QSvgRenderer(svg)
    printer = QtPrintSupport.QPrinter(QtPrintSupport.QPrinter.PrinterMode.HighResolution)
    printer.setOutputFormat(QtPrintSupport.QPrinter.OutputFormat.PdfFormat)
    printer.setOutputFileName("foo.pdf")
    printer.setFontEmbeddingEnabled(True)
    printer.setFullPage(False)
    printer.setPageSize(QtGui.QPageSize(renderer.defaultSize()))
    painter = QtGui.QPainter(printer)
    renderer.render(painter)
    painter.end()

    send_wasm_file_to_browser('/home/pyodide/foo.pdf')

# app = QtWidgets.QApplication([])
QtGui.QFontDatabase.addApplicationFont('/usr/lib/fonts/Vera.ttf')

panel = make_button()
# app.exec()
