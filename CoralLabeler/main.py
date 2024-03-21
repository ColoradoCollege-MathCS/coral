# This Python file uses the following encoding: utf-8

import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication, QPushButton
from PySide6.QtCore import Slot, QCoreApplication

from toolbox import Toolbox
import action




if __name__ == "__main__":
    tbox = Toolbox()

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "main.qml"
    QCoreApplication.setApplicationName("CoralLabeler")

    context = engine.rootContext()
    context.setContextProperty("tbox",tbox)
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())





