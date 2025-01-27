from PyQt5 import QtCore, QtWidgets
from PyQt5.QtCore import Qt
 
 
class MyModel(QtCore.QAbstractTableModel):
 
    def rowCount(self, parent: QtCore.QModelIndex = None) -> int:
        if parent and parent.isValid():
            return 0
        else:
            return 3
 
    def columnCount(self, parent: QtCore.QModelIndex = None) -> int:
        return 2
 
    def data(self, index: QtCore.QModelIndex, role=Qt.ItemDataRole.DisplayRole):
        if role != Qt.ItemDataRole.DisplayRole:
            return None
        elif index.column() == 0:
            return str(index.row())
        else:
            return "ABC"[index.row()]
 
    def headerData(self,
                   section: int,
                   orientation: Qt.Orientation,
                   role: int = Qt.ItemDataRole.DisplayRole):
        if (orientation == Qt.Orientation.Horizontal and
                role == Qt.ItemDataRole.DisplayRole):
            return f"Header {section + 1}"
        return None
 
 
# app = QtWidgets.QApplication([])
model = MyModel()
view = QtWidgets.QTableView()
view.setModel(model)
view.show()
# app.exec()