# This Python file uses the following encoding: utf-8

import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication, QPushButton
from PySide6.QtCore import Slot

from toolbox import Toolbox




if __name__ == "__main__":
    tbox = Toolbox()

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(qml_file)

    context = engine.rootContext()
    context.setContextProperty("tbox",tbox)

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())


