
#说明：重载了ImageViewer，对不同颜色空间的参数作相关的处理
import cv2
import numpy as np
from PySide2.QtCore import QUrl,QObject,Signal,Slot,Property
from CustomPythonToQml.ImageViewer import ImageViewer


class ImageViewerWithColorConduct(ImageViewer):
    def __init__(self):
        super().__init__()
        ########################################
        #第一个位置代表是否使能，后面的参数则是相关图形空间的range
        self.__support_color_space = {'lab':ImageViewerWithColorConduct.labFunc,
                                      'hsv':ImageViewerWithColorConduct.hsvFunc,
                                      'rgb':ImageViewerWithColorConduct.rgbFunc,
                                      'hls':ImageViewerWithColorConduct.hlsFunc,
                                      'gray':ImageViewerWithColorConduct.grayFunc,
                                      'luv':ImageViewerWithColorConduct.luvFunc}
        self.__channel_range = [[0,0,0],[255,255,255]]
        self.__command = 'lab'
        pass

    def load_init(self):
        super().load_init()
        self.__channel_range = [[0,0,0],[255,255,255]]
        self.__command = 'lab'
#################################################################################
    @staticmethod
    def labFunc(Obj):
        if Obj.getLoadReady() == True:
            tmp = Obj.loadImage()
            tmp = cv2.cvtColor(tmp,cv2.COLOR_BGR2LAB)
            mask= cv2.inRange(tmp,np.array(Obj.__channel_range[0]),np.array(Obj.__channel_range[1]))
            tmp = cv2.cvtColor(tmp,cv2.COLOR_LAB2BGR)
            tmp = cv2.copyTo(tmp,mask)
            Obj.setImage(tmp)
        pass
    @staticmethod
    def hsvFunc(Obj):
        tmp = Obj.loadImage()
        tmp = cv2.cvtColor(tmp, cv2.COLOR_BGR2HSV)
        mask = cv2.inRange(tmp, np.array(Obj.__channel_range[0]), np.array(Obj.__channel_range[1]))
        tmp = cv2.cvtColor(tmp, cv2.COLOR_HSV2BGR)
        tmp = cv2.copyTo(tmp, mask)
        Obj.setImage(tmp)
        pass
    @staticmethod
    def rgbFunc(Obj):
        tmp = Obj.loadImage()
        mask = cv2.inRange(tmp, np.array(Obj.__channel_range[0]), np.array(Obj.__channel_range[1]))
        tmp = cv2.copyTo(tmp, mask)
        Obj.setImage(tmp)
        pass
    @staticmethod
    def hlsFunc(Obj):
        tmp = Obj.loadImage()
        tmp = cv2.cvtColor(tmp, cv2.COLOR_BGR2HLS)
        mask = cv2.inRange(tmp, np.array(Obj.__channel_range[0]), np.array(Obj.__channel_range[1]))
        tmp = cv2.cvtColor(tmp, cv2.COLOR_HLS2BGR)
        tmp = cv2.copyTo(tmp, mask)
        Obj.setImage(tmp)
        pass
    @staticmethod
    def grayFunc(Obj):
        tmp = Obj.loadImage()
        tmp = cv2.cvtColor(tmp, cv2.COLOR_BGR2GRAY)
        mask = cv2.inRange(tmp, np.array(Obj.__channel_range[0]), np.array(Obj.__channel_range[1]))
        tmp = cv2.copyTo(tmp, mask)
        Obj.setImage(tmp)
        pass
    @staticmethod
    def luvFunc(Obj):
        tmp = Obj.loadImage()
        tmp = cv2.cvtColor(tmp, cv2.COLOR_BGR2LUV)
        mask = cv2.inRange(tmp, np.array(Obj.__channel_range[0]), np.array(Obj.__channel_range[1]))
        tmp = cv2.cvtColor(tmp, cv2.COLOR_LUV2BGR)
        tmp = cv2.copyTo(tmp, mask)
        Obj.setImage(tmp)
        pass

    @Slot(str,'QVariantList','QVariantList') #注意直接传入list会报错，需要传递list就用QVariantList
    def setRange(self,type,fir,sec):
        fir = list(map(int,fir))
        sec = list(map(int,sec))
        if super().getLoadReady() is True:
            print("type:{},fir:{},sec：{}".format(type.lower(),fir,sec))
            if type.lower() in self.__support_color_space:
                #do some thing...
                self.__channel_range.clear()
                self.__channel_range.append(fir)
                self.__channel_range.append(sec)
                self.__command = type.lower()
                pass
            else:
                self.sigAlert.emit("not supported dataset...")
                pass

    def conductImage(self):
        func = self.__support_color_space[self.__command]
        func(self)
        pass






