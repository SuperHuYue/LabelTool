import sys
# from CustomPythonToQml.ImageViewer import ImageViewer
from projectRelated.projectRelatedpyObj.ImageViewerWithColorClassfier import ImageViewerWithColorConduct
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine,qmlRegisterType
from PySide2.QtCore import QUrl

if __name__ == '__main__':
    sys_argv = sys.argv
    sys_argv += ['--style', 'default']
    app = QGuiApplication(sys_argv)
    qmlRegisterType(ImageViewerWithColorConduct,"ImageViewer",1,0,"ImageViewer")
    engine = QQmlApplicationEngine()
    engine.load(QUrl("main.qml"))
    #engine.load(QUrl("test.qml"))
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec_())