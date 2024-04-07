# This Python file uses the following encoding: utf-8

import sys
from pathlib import Path
import os

from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication, QPushButton
from PySide6.QtCore import Slot, QCoreApplication

from toolbox import Toolbox
import action

#This code from the book Create Gui Apps with Python and Qt6 by Martin Fitzpatrick
try:
    from ctypes import windll #only execute this code on windows
    appIdString = "com.CoralLabeler"
    windll.shell32.SetCurrentProcessExplicitAppUserModelID(appIdString)
except ImportError:
    pass

if __name__ == "__main__":
    tbox = Toolbox()

    app = QGuiApplication(sys.argv)
    app.setWindowIcon(QIcon(os.path.join(tbox.getFileLocation(),"icons","drcl.png")))
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "main.qml"
    QCoreApplication.setApplicationName("CoralLabeler")

    context = engine.rootContext()
    context.setContextProperty("tbox",tbox)
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())





