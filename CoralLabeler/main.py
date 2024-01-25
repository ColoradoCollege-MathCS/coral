# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from toolbox import Toolbox

if __name__ == "__main__":
    tbox = Toolbox()
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "main.qml"
    tbox.initLabels("test_images/rosvol2-cover.jpg")
    engine.load(qml_file)
    context = engine.rootContext()
    context.setContextProperty("tbox",tbox)
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())

