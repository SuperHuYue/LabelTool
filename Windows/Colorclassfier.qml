import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.13
import '../Custom'
import '../projectRelated/projectRelatedQml'
import ImageViewer 1.0

ApplicationWindow{
    property int random_seed: 0
    property int imageview_curFrame: 0
    property int imageview_totalFrame: 0
    property bool image_loaded: false //just use for init image load
    id:app_root
    width: 640
    height: 320


    ColorRangeChoose{
        id:space_range_choose
        sliderName: ['lMin','lMax','aMin','aMax','bMin','bMax']
        property var space_name: 'lab'
        x:app_root.x +app_root.width + 10
        y:app_root.y

        onSigmove: {
            var pos = lab_fit_data()
            image_view.setRange(space_name,pos[0],pos[1])
            image_view.show()
        }
        function lab_fit_data(){
            //依据slidername生成符合处理条件的数据
            var fir = 0,sec = 0;
            console.log('slider length: ',sliderPos.length)
            if(sliderPos.length === 6){
                fir = [sliderPos[0],sliderPos[2],sliderPos[4]]
                sec = [sliderPos[1],sliderPos[3],sliderPos[5]]
            }
            else if(sliderPos.length == 2) //针对gray
            {
                fir = [sliderPos[0]]
                sec = [sliderPos[1]]
            }
            else{
                fir = [0,0,0]
                sec = [0,0,0]
            }
            var final_pos = [fir,sec]
            return final_pos
        }
    }

    FileDialog{
        id:fileChooseDialog
        title: 'choose the file that need conduct...'
        folder: Qt.resolvedUrl(shortcuts.Desktop) // 接受的均为url类型，需要将string转成url类型
        visible: false
        selectMultiple: true
        onAccepted:{
            for(var i = 0 ; i < fileChooseDialog.fileUrls.length; i++){
                path_view.listviewdata.append({'path':fileChooseDialog.fileUrls[i].toString()})
            }
            image_view.load(fileChooseDialog.fileUrls[0])
            image_loaded = true
        }
        onRejected: {
            console.log('file_choose canceled...')
        }
    }

    CustomMenuBar{
        id:menubar
        CustomMenu{
            title: qsTr('File')
            implicitWidth: 200
            Action{text: qsTr('open');
                onTriggered:{
                    fileChooseDialog.open()
                }
            }
        }
        CustomMenu{
            implicitWidth: 200
            title: qsTr('help')
            Action{text: qsTr('contract us')}
        }
    }
    Rectangle{
        id:tool_choose
        anchors.left: menubar.right
        anchors.leftMargin: 2
        anchors.top: menubar.top
        width: app_root.width - menubar.width - 2
        anchors.bottom: menubar.bottom
        color: 'pink'
        RowLayout{
            anchors.fill: parent
            RadioButton{
                id:luv_space
                text: qsTr("luv")
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.hide()
                    space_range_choose.space_name = "luv"
                    space_range_choose.sliderName = ['lMin','lMax','uMin','uMax','vMin','vMax']
                    space_range_choose.show()
                }

            }
            RadioButton{
                id:rgb_space
                text: qsTr('rgb')
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.hide()
//                  space_range_choose.visible = false
                    space_range_choose.space_name = "rgb"
                    space_range_choose.sliderName = ['bMin','bMax','gMin','gMax','rMin','rMax']
                    space_range_choose.show()
                }
            }
            RadioButton{
                id:hls_space
                text: qsTr('hls')
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.hide()
                    space_range_choose.space_name = 'hls'
                    space_range_choose.sliderName = ['hMin','hMax','lMin','lMax','sMin','sMax']
                    space_range_choose.show()
                }
            }
            RadioButton{
                id:gray_space
                text: qsTr('gray')
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.hide()
                    space_range_choose.space_name = 'gray'
                    space_range_choose.sliderName = ['Min','Max']
                    space_range_choose.show()
                }
            }
            RadioButton{
                id:lab_space
                text: qsTr('lab')
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.hide()
                    space_range_choose.space_name = 'lab'
                    space_range_choose.sliderName = ['lMin','lMax','aMin','aMax','bMin','bMax']
                    space_range_choose.show()
                }
            }
            RadioButton{
                id:others
                text: qsTr('others')
                checked: true
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.visible = false
                }

            }

        }
    }

    CustomListView{
        id:path_view
        anchors.top: menubar.bottom
        anchors.left: menubar.left
        width: app_root.width / 10
        height:app_root.height
        vBarenable:true
        hBarenable:true
        xMoveable: true
        yMoveable:true

    }
    Component{
        id: overlay_rect
        Canvas{
            id:rect_canvas
            z:2
            width: 200
            height: 200
            onPaint:{
                console.log('Overlay_rect painted....')
                var ctx = rect_canvas.getContext('2d')
                var background_r= Math.floor(Math.random(image_view.mouse_x)*255)
                var background_g = Math.floor(Math.random(image_view.mouse_y)*255)
                var background_b = Math.floor(Math.random(image_view.mouse_x+10)*255)
                var front_r = Math.floor(Math.random(image_view.mouse_y)*255)
                var front_g = Math.floor(Math.random(image_view.mouse_x + 10)*255)
                var front_b = Math.floor(Math.random(image_view.mouse_y + 20)*255)
                console.log(background_r,background_g,background_b,front_r,front_g,front_b)
//                ctx.fillStyle = Qt.rgba(background_r,background_g,background_b,0.5)
                ctx.fillStyle = Qt.rgba(background_r,background_g,background_b,0.5)
                ctx.fillRect(0,0,100,100)
                var pattern = ctx.createPattern(Qt.rgba(front_r, front_g, front_b, 1.0),Qt.BDiagPattern)
                ctx.fillStyle = pattern
                ctx.fillRect(0,0,100,100)
            }
        }
    }

    ImageViewer{
        property double stretch_step: 0.1
        property double show_image_x: 0
        property double show_image_y: 0
        property double show_image_width: 0
        property double show_image_height: 0
        property double mouse_x: 0
        property double mouse_y: 0
        id:image_view
        z:0
        anchors.left:path_view.right
        anchors.top: path_view.top
        width: app_root.width - path_view.width
        height: app_root.height - menubar.height
        clip:true
        visible:true
        Canvas{
            id:image_view_crossLine
            x:image_view.show_image_x
            y:image_view.show_image_y
            width: image_view.show_image_width
            height: image_view.show_image_height
            z:2
            visible: false
            onPaint: {
                console.log('ready painted..')
                var ctx = image_view_crossLine.getContext("2d");
                ctx.reset()
                ctx.fillStyle = Qt.rgba(1, 0, 0, 0);
                ctx.fillRect(0, 0, width, height);
                ctx.beginPath()
                ctx.strokeStyle = Qt.rgba(0,0,0,1)
                ctx.lineWidth = 2
                var p_x = image_view.mouse_x - x
                var p_y = image_view.mouse_y - y
                ctx.moveTo(p_x,0)
                ctx.lineTo(p_x,height)
                ctx.moveTo(0,p_y)
                ctx.lineTo(width,p_y)
                ctx.stroke()
                //ctx.moveTo(image_view.mouse_x - x,image_view.mouse_y - y)
            }
        }

        Text {
            id:image_view_frame_idx
            anchors.centerIn: parent
            text: imageview_curFrame + '/' + imageview_totalFrame
            color: 'red'
            z:1
        }

        CustomScrollBar{
            id:upScrollBar
            z:1
            anchors.top: image_view.top
            anchors.left: image_view.left
            anchors.right: image_view.right
            height:10
            state:"horizental"
            onPositionchange: {
                console.log(pos)
                image_view.setHorizentalPos(pos)
            }
        }
//如下两种用法均可以达到相同的效果
        CustomScrollBar{
            id:leftScrollBar
            z:1
            anchors.left:image_view.left
            anchors.top: image_view.top
            anchors.bottom: image_view.bottom
            width: 10
            state: "vertical"
            onPositionchange: {
                console.log(pos)
                image_view.setVerticalPos(pos)
            }
        }

        ScrollBar{
            id:vBar
            z:1
            policy: ScrollBar.AlwaysOn
            anchors.right: image_view.right
            anchors.bottom: image_view.bottom
            anchors.top: image_view.top
            width: 10
            orientation: Qt.Vertical
            contentItem.onYChanged : {
                console.log('content: ',contentItem.y)
            }
        }
//end

        ScrollBar{
            id:hBar
            z:1
            anchors.bottom: image_view.bottom
            anchors.left: image_view.left
            anchors.right: image_view.right
            height: 10
            policy: ScrollBar.AlwaysOn
            orientation: Qt.Horizontal
            onXChanged: {
                console.log('hBar: ',x)
            }
        }

        MouseArea{
            z:0
            id:image_view_mousearea
            anchors.fill: parent
            focus: true
            hoverEnabled: true
            propagateComposedEvents: true
            onClicked: {
                console.log('button clicked...')
                image_view_mousearea.focus = true //必须这里设定focus否则无法接收键盘指令
                var obj = overlay_rect.createObject(image_view)
                obj.x = mouseX
                obj.y = mouseY
                obj.requestPaint()
              //下一帧图像的调用方式
              //  console.log('image click...')
              //  image_view.next()
              //  image_view.show()
              //  mouse.accept = false

            }
            Keys.onPressed: {
                console.log('image view key pressed...')
                if(event.key === Qt.Key_W && image_loaded === true)
                {
                    image_view_mousearea.cursorShape = Qt.CrossCursor
                    image_view_crossLine.visible = true
                    image_view_crossLine.requestPaint()
                    console.log('image_loaded and key_W pressed...')
                    event.key.accepted = true
                }
            }

            onPositionChanged: {
                if(image_view_crossLine.visible === true){
                    image_view_crossLine.requestPaint()
                }
                image_view.mouse_x = mouseX
                image_view.mouse_y = mouseY
            }

             onWheel: {
                 //console.log("PosX: ",wheel.x,"PosY: ",wheel.y)
                 if(wheel.modifiers &Qt.ControlModifier){
                     if(wheel.angleDelta.y < 0){ //缩小
                         image_view.shrink(wheel.x,wheel.y)
                     }
                     else{  					//放大
                         image_view.dilate(wheel.x,wheel.y)
                     }
                     image_view.update()
                 }
//                 console.log('Now ImageStretch...',image_view.imageStretch)
                 wheel.accepted = true
             }
        }
    }

//处理信号连接
    signal sigImageViewAlert(string msg)
    signal sigImageViewCurFrame(int msg)
    signal sigImageViewTotalFrame(int msg)
    signal sigImageViewMouse2PicPos(int x,int y)
    signal sigImageViewShowPicInfo(double x,double y,double width,double height)
    signal sigImageViewShowScrollInfo(double hScrollSize,double vScrollSize,double hpos,double vpos )
//    sigCurFrame = Signal(int) #当前帧数报告
//    sigTotalFrame = Signal(int) #总帧数报告
    Component.onCompleted: {
        image_view.sigAlert.connect(sigImageViewAlert)
        image_view.sigCurFrame.connect(sigImageViewCurFrame)
        image_view.sigTotalFrame.connect(sigImageViewTotalFrame)
        image_view.sigMouse2PicPos.connect(sigImageViewMouse2PicPos)
        image_view.sigShowPicInfo.connect(sigImageViewShowPicInfo)
        image_view.sigShowScrollInfo.connect(sigImageViewShowScrollInfo)
    }
    onSigImageViewShowPicInfo: {
        console.log('x:',x,'y: ',y,'width: ',width,'height: ',height)
        image_view.show_image_x = x
        image_view.show_image_y = y
        image_view.show_image_width = width
        image_view.show_image_height = height
    }

    onSigImageViewShowScrollInfo : {
        console.log('hSize: ',hScrollSize,'vSize: ',vScrollSize,'hPos: ', hpos, 'vpos:' , vpos)
        upScrollBar.size = hScrollSize
        upScrollBar.position = hpos
        upScrollBar.update()
        leftScrollBar.size = vScrollSize
        leftScrollBar.position = vpos
        leftScrollBar.update()
        hBar.size = hScrollSize
        vBar.size = vScrollSize
        hBar.position = hpos
        vBar.position = vpos
        vBar.update()
        hBar.update()
//        //此处用来设置scrollbar的信息
//        console.log("frame_width: ", image_view.width, 'image_width: ',width)
//        console.log("frame_height: ", image_view.height, 'image_height: ',height)
//        hBar.size = image_view.width / width
//        vBar.size = image_view.height / height
//        console.log('hBar size: ', hBar.size)
//        console.log('vBar size: ', vBar.size)
//        console.log('x: ',offsetX, 'y: ',offsetY)
//        vBar.position =  y / (height - image_view.height)
//        hBar.position =  x / (width - image_view.width)
    }

    onSigImageViewMouse2PicPos: {
//        console.log('Qml x: ',x,'y: ',y)
    }

    onSigImageViewCurFrame: {
        imageview_curFrame = msg
    }
    onSigImageViewTotalFrame: {
        imageview_totalFrame = msg
    }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function program_init(){
        image_loaded =false  //图形加载标识
        view_init()
    }
    function view_init(){
        image_view_mousearea.cursorShape = Qt.ArrowCursor
        image_view_crossLine.visible = false
    }

}


























