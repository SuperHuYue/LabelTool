import sys
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QUrl


if __name__ == '__main__':

    sys_argv = sys.argv
    sys_argv += ['--style', 'default']
    app = QGuiApplication(sys_argv)

    engine = QQmlApplicationEngine()

    engine.load(QUrl("main.qml"))
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec_())