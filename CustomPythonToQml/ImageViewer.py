import cv2
import os
import threading
from PySide2.QtCore import QUrl,QObject,Signal,Slot,Property
from PySide2.QtGui import QPixmap
from PySide2.QtQuick import QQuickPaintedItem
from PySide2.QtGui import QImage
import numpy as np

#用于图形显示的模块(可进行重载conductImage完成图像处理的能力,在使用ConductImage的过程中不允许对图形比例进行放缩)
#信号引出sigAlert，sigCurFrame，sigTotalFrame,sigPicPos 如需使用其功能需要在qml中进行connect
#如果对当前图片进行变化（不调用重载的conductImage)---->使用update，使用show或者showtarget会调用conductImage同时重置图像位置
class ImageViewer(QQuickPaintedItem):
    sigAlert = Signal(str) #警告信息
    sigCurFrame = Signal(int) #当前帧数报告
    sigTotalFrame = Signal(int) #总帧数报告
    sigMouse2PicPos = Signal(int,int) #鼠标对应图片上的位置
    sigShowPicInfo = Signal(float,float,float,float) #展示到界面中的图像的参数(针对frame的x，y的偏移,width,height)
    sigShowReady = Signal() #显示图片,该信号无需导出到QML
    def __init__(self,parent = None):
        super().__init__(parent)
        self.__path = None                                   #当前处理图像路径
        self.__imageShow = QPixmap()                         #当前显示图像位图
        self.__image = None
        # self.__percentage = None                           #当前图像加载/处理进度
        self.__type = None                                   #图像类型,视频还是图片
        self.__SupportImageType = ['jpg','png']                #支持的图片类型
        self.__SupportVideoType = ['mp4']                    #支持的视频类型
        self.__imageContainer = dict()                       #用于保存图形设备.图像内容统一从这里读取
        self.__curFrame = 0                                  #当前帧号
        self.__totalFrame = 0                                #总帧号
        self.__loadReady = False                             #是否加载完毕
        ################################################################################
        #图形绘制相关
        self.__ShowImageX = None
        self.__ShowImageY = None
        self.__OriImageX = None
        self.__OriImageY = None

        self.__ShowImageStretch = None
        self.__OriImageStretch = None

        self.__MousePosX2Pic = None
        self.__MousePosY2Pic = None
        self.__MousePosX2Frame = None
        self.__MousePosY2Frame = None
        self.__ShowNextReady = True                          #控制显示同步
        self.__StretchStep = 0.05
        self.__hScrollSize = None                            #0.0~1.0
        self.__vScrollSize = None                            #0.0~1.0
        ################################################################################
        self.sigShowReady.connect(self.show)



    def show_Init(self):
        ################################################################################
        # 图形绘制相关
        self.__ShowImageX = None
        self.__ShowImageY = None
        self.__OriImageX = None
        self.__OriImageY = None

        self.__ShowImageStretch = None
        self.__OriImageStretch = None

        self.__MousePosX2Pic = None
        self.__MousePosY2Pic = None
        self.__MousePosX2Frame = None
        self.__MousePosY2Frame = None
        self.__ShowNextReady = True
        self.__StretchStep = 0.05
        self.__hScrollSize = None
        self.__vScrollSize = None
        pass
        ################################################################################



    def load_init(self):
        self.__path = None
        self.__imageShow = QPixmap()
        self.__sourceImage = None
        self.__image = None
        self.__type = None
        self.__imageContainer = dict()
        self.__curFrame = 0
        self.__totalFrame = 0
        self.__loadReady = False
        ################################################################################
        # 图形绘制相关
        self.__ShowImageX = None
        self.__ShowImageY = None
        self.__OriImageX = None
        self.__OriImageY = None

        self.__ShowImageStretch = None
        self.__OriImageStretch = None

        self.__MousePosX2Pic = None
        self.__MousePosY2Pic = None
        self.__MousePosX2Frame = None
        self.__MousePosY2Frame = None
        self.__ShowNextReady = True
        self.__StretchStep = 0.05
        self.__hScrollSize = None
        self.__vScrollSize = None

    @Slot(float)
    def setHorizentalPos(self,pos):
        if self.__ShowImageX is None or self.__ShowImageY is None or self.__imageShow is None \
            or self.__image is None or self.__hScrollSize is None:
            return
        if self.__ShowNextReady is False:
            return
        self.setShowControl()
        self.__ShowImageX = -(pos) * ((self.__imageShow.width() - self.width()) / (self.width() *(1 - self.__hScrollSize)))

        image = cv2.resize(self.__image,None,
                           fx= self.__ShowImageStretch,
                           fy= self.__ShowImageStretch,
                           interpolation=cv2.INTER_LINEAR)
        qimage = self.cvt_CV2QImage(image)
        self.__imageShow = QPixmap.fromImage(qimage)
        self.update()



    @Slot(float)
    def setVerticalPos(self,pos):
        if self.__ShowImageX is None or self.__ShowImageY is None or self.__imageShow is None \
                or self.__image is None or self.__vScrollSize is None:
            return
        if self.__ShowNextReady is False:
            return
        self.setShowControl()
        self.__ShowImageY = -(pos) * ((self.__imageShow.height() - self.height()) / (self.height()*(1 - self.__vScrollSize)))

        image = cv2.resize(self.__image,None,
                           fx= self.__ShowImageStretch,
                           fy= self.__ShowImageStretch,
                           interpolation=cv2.INTER_LINEAR)
        qimage = self.cvt_CV2QImage(image)
        self.__imageShow = QPixmap.fromImage(qimage)
        self.update()


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
            if num > self.getTotalFrame():
                num = self.getTotalFrame()
            self.setCurFrame(num)
        self.__image = self.__imageContainer[self.getCurFrame()]
        #加载图片的同时计算图形原始比例
        framework_width = self.width()      #画版的宽度
        framework_height = self.height()     #画版的高度
        if self.__image is None:
            return
        image = self.__image #原图
        image_height = image.shape[0]
        image_width = image.shape[1]
        self.__OriImageStretch = (framework_width / image_width) if ((framework_width / image_width) < (framework_height / image_height)) else (framework_height / image_height)
        self.__ShowImageStretch = self.__OriImageStretch + 0
        resized_img_width = image_width * self.__ShowImageStretch
        resized_img_height = image_height * self.__ShowImageStretch
        self.__OriImageX = framework_width / 2 - resized_img_width / 2
        self.__OriImageY = framework_height / 2 - resized_img_height / 2
        self.__stayRadioResize()
        return self.__image

    def setImage(self,img):
        self.__image = img

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
            self.update()

    @Slot(int)
    def target_show(self,num):
        self.setCurFrame(num)
        if self.getLoadReady() is True:
         self.loadImage()
         self.conductImage()
         self.update()
        pass


    def setShowControl(self):
        self.__ShowNextReady = False

    def releaseShowControl(self):
        self.__ShowNextReady = True

    #调用setMousePos指令会返回当前鼠标位置信息
    @Slot(float,float)
    def dilate(self,x,y):
        if self.__ShowNextReady is False:
            return
        self.setShowControl()
        self.setOriImageStretchOffset(self.__StretchStep)
        self.__MousePosX = x
        self.__MousePosY = y
        if self.__ShowImageX is None or self.__ShowImageY is None:
            return
        frame_width = self.width()
        frame_height = self.height()

        if self.__MousePosX > self.__ShowImageX and self.__MousePosY > self.__ShowImageY:
            #click pos in the picture
            self.__MousePosX2Frame = self.__MousePosX / frame_width
            self.__MousePosY2Frame = self.__MousePosY / frame_height
            picPosX = self.__MousePosX - self.__ShowImageX
            picPosY = self.__MousePosY - self.__ShowImageY
            self.__MousePosX2Pic = picPosX / self.__imageShow.width()
            self.__MousePosY2Pic = picPosY / self.__imageShow.height()
            pass
        else:
            #click pos not in the picture  self.__MousePosX2Frame = None
            pass
        self.__stayRadioResize()

    @Slot(float,float)
    def shrink(self,x,y):
        if self.__ShowNextReady is False:
            return
        self.setShowControl()
        self.setOriImageStretchOffset( - self.__StretchStep)
        self.__MousePosX = x
        self.__MousePosY = y
        if self.__ShowImageX is None or self.__ShowImageY is None:
            return
        frame_width = self.width()
        frame_height = self.height()

        if self.__MousePosX > self.__ShowImageX and self.__MousePosY > self.__ShowImageY:
            #click pos in the picture
            self.__MousePosX2Frame = self.__MousePosX / frame_width
            self.__MousePosY2Frame = self.__MousePosY / frame_height
            picPosX = self.__MousePosX - self.__ShowImageX
            picPosY = self.__MousePosY - self.__ShowImageY
            self.__MousePosX2Pic = picPosX / self.__imageShow.width()
            self.__MousePosY2Pic = picPosY / self.__imageShow.height()
            pass
        else:
            #click pos not in the picture
            pass
        self.__stayRadioResize()

    def setOriImageStretchOffset(self,stretchOffset):
        if self.__OriImageStretch is None or self.__image is None:
            return
        resized_width = self.__image.shape[1] * (self.__ShowImageStretch + stretchOffset)
        resized_height = self.__image.shape[0] * (self.__ShowImageStretch + stretchOffset)
        if resized_width <= 30 or resized_height <= 30:
            pass
        else:
            self.__ShowImageStretch = self.__ShowImageStretch + stretchOffset



    #缩放控制,确定图片在显示中的位置
    def __stayRadioResize(self):
        if (self.__image is None or self.__ShowImageStretch is None):
            return None
        #print(self.__MousePosX2Pic,self.__MousePosY2Pic,self.__MousePosX2Frame,self.__MousePosY2Frame)
        if self.__MousePosX2Pic is None or self.__MousePosY2Pic is None or \
           self.__MousePosX2Frame is None or self.__MousePosY2Frame is None:
            #print('wops')
            self.__ShowImageX = self.__OriImageX
            self.__ShowImageY = self.__OriImageY
            pass
        else:
            #print('enter this...')
            framework_width = self.width()      #画版的宽度
            framework_height = self.height()     #画版的高度
            image_width = self.__image.shape[1] * self.__ShowImageStretch
            image_height = self.__image.shape[0] * self.__ShowImageStretch
            if image_width <= framework_width or image_height <= framework_height or self.__ShowImageX > 0 or self.__ShowImageY > 0:
                self.__ShowImageX = (framework_width - image_width) / 2
                self.__ShowImageY = (framework_height - image_height) / 2
            else:
                alignXinImg = self.__image.shape[1] * self.__ShowImageStretch * self.__MousePosX2Pic
                alignYinImg = self.__image.shape[0] * self.__ShowImageStretch * self.__MousePosY2Pic
                alignXinFrame = framework_width * self.__MousePosX2Frame
                alignYinFrame = framework_height * self.__MousePosY2Frame
                self.__ShowImageX = alignXinFrame - alignXinImg
                self.__ShowImageY = alignYinFrame - alignYinImg


            hScroll_size = min(self.width() / self.__imageShow.width(),1)
            vScroll_size = min(self.height() / self.__imageShow.height(),1)
            hPos_mediate = abs(self.__ShowImageX /(self.__imageShow.width() - self.width()+ 1e-19)) if self.__ShowImageX<0 else 0
            vPos_mediate = abs(self.__ShowImageY / (self.__imageShow.height() - self.height() + 1e-19)) if self.__ShowImageY < 0 else 0
            hPos = (hPos_mediate *((1 - hScroll_size) * self.width())) / self.width()
            vPos = (vPos_mediate * ((1 - vScroll_size)* self.height())) / self.height()
            self.__vScrollSize = vScroll_size
            self.__hScrollSize = hScroll_size
            #hPos = min(abs((self.__ShowImageX) / (self.__imageShow.width() - self.width() - hScroll_size)),1)
            #vPos = min(abs((self.__ShowImageY) / (self.__imageShow.height() - self.height()-vScroll_size)),1)
            self.sigShowPicInfo.emit(hScroll_size,vScroll_size,
                                     hPos,vPos)
        image = cv2.resize(self.__image,None,
                           fx= self.__ShowImageStretch,
                           fy= self.__ShowImageStretch,
                           interpolation=cv2.INTER_LINEAR)
        qimage = self.cvt_CV2QImage(image)
        self.__imageShow = QPixmap.fromImage(qimage)


    @Slot()
    def next(self):
        if  self.getCurFrame() < self.getTotalFrame():
            self.setCurFrame(self.__curFrame + 1)
            self.show()

    #内部实际绘制函数
    def paint(self, painter):
        if painter is None:
            raise Exception("painter None Exception...")
        if self.__image is None:
            return
      #  image = cv2.resize(self.__image,None,
      #                           fx= self.__ShowImageStretch,
      #                           fy= self.__ShowImageStretch,
      #                           interpolation=cv2.INTER_LINEAR)
      #  qimage = self.cvt_CV2QImage(image)
      #  self.__imageShow = QPixmap.fromImage(qimage)
        if self.__imageShow.isNull() is not True:
                painter.drawPixmap(self.__ShowImageX,
                                   self.__ShowImageY,
                                   self.__imageShow.width(),
                                   self.__imageShow.height(),
                                   self.__imageShow)
                #print('x:', self.__ShowImageX, 'y: ',self.__ShowImageY)
                self.releaseShowControl()
                if self.__ShowImageX > 0 or self.__ShowImageY > 0:
                    #raise Exception('Not nice ImageX...')
                    pass

        else:
            self.sigAlert.emit('image is null...')
        pass

    #函数功能：将cv转码得到的数据转换为QImage
    def cvt_CV2QImage(self,cv_data):
        if cv_data.dtype == np.uint8:
            bits_per_channel = 8
        else:
            self.sigAlert.emit("Convert error...")
        channel = 1 if len(cv_data.shape) is 2 else cv_data.shape[2]
        if channel is 1:
            img = QImage(cv_data.data,cv_data.shape[1],cv_data.shape[0],cv_data.shape[1],QImage.Format_Indexed8)
        elif channel is 3:
            img = QImage(cv_data,cv_data.shape[1],cv_data.shape[0],cv_data.shape[1] * 3, QImage.Format_RGB888)
            img = img.rgbSwapped()
        else:
            self.sigAlert.emit("not_right_channel....it has channel number:{}".format(channel))
            raise Exception("not_right_channel....it has channel number: ",channel)
        return img

    totalFrame = Property(int, getTotalFrame, setTotalFrame, notify=sigTotalFrame)
    curFrame = Property(int, getCurFrame, setCurFrame, notify=sigCurFrame)

