import cv2
import os
import threading
from PySide2.QtCore import QUrl,QObject,Signal,Slot,Property
from PySide2.QtGui import QPixmap
from PySide2.QtQuick import QQuickPaintedItem
from PySide2.QtGui import QImage
import numpy as np

#用于图形显示的模块(可进行重载conductImage完成图像处理的能力)
#信号引出sigAlert，sigCurFrame，sigTotalFrame 如需使用其功能需要在qml中进行connect
#显示图像时候，会对图像进行等比例压缩(尚未完成):目前想法是按照长宽相对较低的进行压缩
class ImageViewer(QQuickPaintedItem):
    sigAlert = Signal(str) #警告信息
    sigCurFrame = Signal(int) #当前帧数报告
    sigTotalFrame = Signal(int) #总帧数报告
    sigShowReady = Signal() #显示图片,该信号无需导出到QML
    def __init__(self,parent = None):
        super().__init__(parent)
        self.__path = None                                   #当前处理图像路径
        self.__imageShow = QPixmap()                         #当前显示图像位图
        self.__image = None                                  #opencv中读取的内容,以及后续处理保存的内容（尚未转化为QPixmap）
        # self.__percentage = None                           #当前图像加载/处理进度
        self.__type = None                                   #图像类型,视频还是图片
        self.__imageWidth = None                             #载入图像宽度
        self.__imageHeight = None                            #载入图像高度
        self.__SupportImageType = ['jpg','png']                #支持的图片类型
        self.__SupportVideoType = ['mp4']                    #支持的视频类型
        self.__imageContainer = dict()                       #用于保存图形设备.图像内容统一从这里读取
        self.__curFrame = 0                                  #当前帧号
        self.__totalFrame = 0                                #总帧号
        self.__loadReady = False                             #是否加载完毕
        self.sigShowReady.connect(self.show)

    def load_init(self):
        self.__path = None
        self.__imageShow = QPixmap()
        self.__image = None
        self.__type =None
        self.__imageHeight = None
        self.__imageWidth = None
        self.__imageContainer = dict()
        self.__curFrame = 0
        self.__totalFrame = 0
        self.__loadReady = False

    @staticmethod
    def videoFeedContainer(Obj):#Obj image_viewer本身
        cap = cv2.VideoCapture()
        ret = cap.open(Obj.__path)
        if ret is not True:
            Obj.sigAlert.emit("Error:video can't be opened...")
        while True:
            ret,img  = cap.read()
            if ret is False:
                Obj.setLoadReady(True)
                Obj.sigShowReady.emit()    #qt不允许非主线程更新显示，所以这里需要通过信号槽对图像进行更新
                print('load over...{}'.format(Obj.getTotalFrame()))
                cap.release()
                break
            Obj.feedImageContainer(img)

    def feedImageContainer(self,img):
        self.__totalFrame += 1
        self.__imageContainer[self.__totalFrame] = img
        self.setTotalFrame(self.__totalFrame)

    def setCurFrame(self,num): #外部不因该设置此参数,但引出此接口
        self.__curFrame = num
        self.sigCurFrame.emit(num)

    def getCurFrame(self):
        return self.__curFrame

    def getTotalFrame(self):
        return self.__totalFrame

    def setTotalFrame(self,num):
        self.__totalFrame = num
        self.sigTotalFrame.emit(num)
        pass

    totalFrame = Property(int, getTotalFrame, setTotalFrame, notify=sigTotalFrame)
    curFrame = Property(int, getCurFrame, setCurFrame, notify=sigCurFrame)


    @Slot(QUrl)
    def load(self,url):
        self.load_init()
        absPath = url.path()
        if os.path.exists(absPath) is False:
            self.sigAlert.emit("Path isn't exist...")
            return
        absPath = absPath.rstrip().lstrip()
        self.__path = absPath
        suffix = os.path.basename(absPath).split('.')[-1]
        self.setLoadReady(False)
        if suffix in self.__SupportImageType:
            self.__type = "image"
            # self.__image = cv2.imread(absPath)
            self.__imageContainer[1] = cv2.imread(absPath)
            self.setCurFrame(1)
            self.setTotalFrame(1)
            self.setLoadReady(True)
            self.show()
            pass
        elif suffix in self.__SupportVideoType:
            self.__type = "video"
            #start a new thread to feed images to imageContainer
            t1 = threading.Thread(target=ImageViewer.videoFeedContainer,args=(self,))
            self.setCurFrame(1)
            t1.start()
            pass
        else:
            self.sigAlert.emit("Not an supported data....")
            return

    #加载图片
    def loadImage(self,num=None):
        if num is not None:
            if num  > self.getTotalFrame():
                num = self.getTotalFrame()
            self.setCurFrame(num)
        self.__image = self.__imageContainer[self.getCurFrame()]

    #供子类进行重写
    def conductImage(self):
        pass

    def setLoadReady(self,ready):
        self.__loadReady = ready
    def getLoadReady(self):
        return  self.__loadReady

    @Slot()
    def show(self):
        if self.getLoadReady() is True:
            self.loadImage()
            self.conductImage()
            qimage = self.cvt_CV2QImage(self.__image)
            self.__imageShow = QPixmap.fromImage(qimage)
            self.update()

    @Slot(int)
    def target_show(self,num):
        self.setCurFrame(num)
        if self.getLoadReady() is True:
         self.loadImage()
         self.conductImage()
         qimage = self.cvt_CV2QImage(self.__image)
         self.__imageShow = QPixmap.fromImage(qimage)
         self.update()
        pass

    @Slot()
    def next(self):
        if  self.getCurFrame() < self.getTotalFrame():
            self.setCurFrame(self.__curFrame + 1)
            self.show()

    #内部实际绘制函数
    def paint(self, painter):
        if painter is None:
            raise Exception("painter None Exception...")
        if self.__imageShow.isNull() is not True:
            painter.drawPixmap(0,0,self.width(),self.height(),self.__imageShow)
        else:
            self.sigAlert.emit('image is null...')
        pass


    #函数功能：将cv转码得到的数据转换为QImage
    def cvt_CV2QImage(self,cv_data):
        if cv_data.dtype == np.uint8:
            bits_per_channel = 8
        else:
            self.sigAlert.emit("Convert error...")
        channel =  1 if len(cv_data.shape) is 2 else cv_data.shape[2]
        if channel is 1:
            img = QImage(cv_data.data,cv_data.shape[1],cv_data.shape[0],cv_data.shape[1],QImage.Format_Indexed8)
        elif channel is 3:
            img = QImage(cv_data,cv_data.shape[1],cv_data.shape[0],cv_data.shape[1] * 3, QImage.Format_RGB888)
            img = img.rgbSwapped()
        else:
            self.sigAlert.emit("not_right_channel....it has channel number:{}".format(channel))
            raise Exception("not_right_channel....it has channel number: ",channel)
        return img

