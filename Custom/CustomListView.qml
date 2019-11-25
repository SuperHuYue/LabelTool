import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.13

/*
 模块介绍：该模块实现了可拖拽（放大缩小）的listiew，同时拥有scrollbar进行滚动
 xMoveable:竖直轴是否能调整
 yMoveable:水平轴是否能调整
 vBarenable:是否显示垂直轴拖动框
 hBarenable:是否显示水平轴拖动框
 listviewdata:显示到界面上的数据 list类型，目前只测试了text类型
 rightclickmenu中的条目需要
 注意：动态出现scrolbar尚有bug---line28有解释
*/
Rectangle{
    id:controlBackground
    color: 'blue'
    implicitHeight: 300
    implicitWidth: 100
    property var listviewdata: ['william']
    property var xMoveable: false
    property var yMoveable: false
    property var hBarenable: false
    property var vBarenable: false
    property int vbarwidth: 10
    property int hbarheight: 10
    ////////////////////////////////////////////////////////////////////////////////
    //目前这种动态出现scrobar的方式尚且还有bug，会在鼠标处于bar中心时bar不停的闪动
    //readonly property var finalvBarenable: (vBarenable && background_area.containsMouse)
    //readonly property var finalhBarenable: (hBarenable && background_area.containsMouse)
    ////////////////////////////////////////////////////////////////////////////////

    readonly property var finalvBarenable: vBarenable
    readonly property var finalhBarenable: hBarenable
    //warning :解释方式为顺序从上往下的方式，如果controlBackgroundArea放置在最后，那么它将会覆盖整个空间成为最上层的mousearea，而放在这里则是最底层的mousearea,放置在顶层则会让后面的mousearea消息的
    //propaganda出现问题，导致出错！！！！！
    MouseArea{
        id:controlBackgroundArea
        anchors.fill: controlBackground
        hoverEnabled: true
        onClicked: {
            console.log('control clicked....')
            //mouse.accepted = false
        }
    }
    CustomMenu{
        id:rightclickmenu
        Action { text: qsTr("Tool Bar"); checkable: true; onTriggered: {console.log('add some method....')}}
        Action { text: qsTr("Side Bar"); checkable: true; checked: true }
        Action { text: qsTr("Status Bar"); checkable: true; checked: true }

        MenuSeparator {
            contentItem: Rectangle {
                implicitWidth: 200
                implicitHeight: 1
                color: "#21be2b"
            }
        }
        Menu {
            title: qsTr("Advanced")
            Action{text: qsTr('hello')}
            // ...
        }
    }

    Rectangle{
         id:listBackground
         anchors.left: controlBackground.left
         anchors.top: controlBackground.top
         width: finalvBarenable?(controlBackground.width - vbarwidth):controlBackground.width
         height: finalhBarenable?(controlBackground.height - hbarheight):controlBackground.height
         color: 'yellow'
         clip: true
         TextMetrics{
             id:textMetrics
         }
         ListView{
             id:root
             z:0
             model: listviewdata
             property int max_text_length: 0
//             anchors.left: listBackground.left
             width:max_text_length
             height: contentHeight
             focus: true
             x: -hBar.position * width
             y: -vBar.position * contentHeight
             delegate:Rectangle{
                 id:warpper
                 width: root.width
                 height: listBackground.height /10
                 color: ListView.isCurrentItem?'black':'red'
                 Text {
                     id:info
                     font: textMetrics.font
                     anchors.left: warpper.left
                     text: modelData
                     anchors.horizontalCenter: warpper.horizontalCenter
                     anchors.verticalCenter: warpper.verticalCenter
                     color:warpper.ListView.isCurrentItem?'red':'black'
                     Component.onCompleted: {
                         textMetrics.text = modelData
                         var tmp = textMetrics.tightBoundingRect.width
                         if(tmp > root.max_text_length){
                             root.max_text_length = tmp
                         }
                     }
                 }

                 MouseArea{
                     id:warpper_area
                     anchors.fill: parent
                     acceptedButtons: Qt.LeftButton | Qt.RightButton
                     propagateComposedEvents: true
                     onClicked: {
                         root.currentIndex = index
                         console.log('curidx: ',root.currentIndex, 'total idx', root.count)
                         mouse.accepted = false
                     }
                 }
             }

         }
         MouseArea{
             id:background_area
             anchors.fill:listBackground
             acceptedButtons: Qt.LeftButton | Qt.RightButton   //*****MouseArea接受button类型
             property bool xSensArea: false
             property bool ySensArea: false
             property bool xStretch: false
             property bool yStretch: false
             property var pos:[]
             propagateComposedEvents: true     //****消息向下传递
             hoverEnabled: true

             onPressed: {
                 if(mouse.button === Qt.LeftButton) {
                     console.log('left button clicked...')
                     if(xSensArea == true){
                         xStretch = true
                         pos = [mouseX,mouseY]
                     }
                     if(ySensArea == true){
                         yStretch = true
                         pos = [mouseX,mouseY]
                     }
                 }
                 if(mouse.button === Qt.RightButton){
                     console.log('right button clicked....')
                     rightclickmenu.x = mouseX + parent.x
                     rightclickmenu.y = mouseY + parent.y
                     rightclickmenu.popup()
                 }
                 if(mouse.button === Qt.MidButton){
                     console.log('middle button clicked...')
                 }

             }
             onReleased: {
                 xStretch = false
                 yStretch = false
             }



             onPositionChanged: { // mouse给入的是相对当前mouseare的坐标
                 var xCursorChange = mouseX > (listBackground.width - 5) && mouseX < (listBackground.width);
                 var yCursorChange = mouseY > (listBackground.height - 5) && mouseY < (listBackground.height)
                 if(xCursorChange === true || yCursorChange === true)
                 {
                     if(xCursorChange === true && yCursorChange === true){

                     }else if(xCursorChange === true){
                         xSensArea = true
                         background_area.cursorShape = Qt.SplitHCursor
                     }else{
                         ySensArea = true
                         background_area.cursorShape = Qt.SplitVCursor

                     }

                 }else{
                     if(xCursorChange !== true){
                         xSensArea = false
                     }
                     if(yCursorChange !== true){
                         ySensArea = false
                     }
                     if(xSensArea || ySensArea === false)
                     {
                         background_area.cursorShape = Qt.ArrowCursor
                     }
                 }
                 if(xStretch == true && xMoveable === true){
                     console.log('xStretch enter...')
                     if(mouseX < root.max_text_length){
                         controlBackground.width = mouseX
                     }

                 }

                 if(yStretch == true && yMoveable === true){
                     console.log('yStretch enter...')
                     controlBackground.height = mouseY
                 }
             }
         }

 //        Keys.onPressed: {
 //            if(event.key === Qt.Key_Left)
 //            {
 //                console.log('key pressed....')
 //            }
 //        }
    }

    ScrollBar{
        id:vBar
        z:1
        active: pressed
        orientation: Qt.Vertical
        visible: finalvBarenable?true:false
        size:listBackground.height / root.contentHeight
        anchors.top: controlBackground.top
        anchors.right: controlBackground.right
        anchors.bottom: controlBackground.bottom
        width:vbarwidth
        background:Rectangle{
            color: 'green'
        }

        contentItem: Rectangle{
            color: 'purple'
        }
        onPositionChanged: {
            console.log(root.contentHeight , '   ',listBackground.height)
        }
    }
    ScrollBar{
        id:hBar
        z:1
        active: pressed
        orientation: Qt.Horizontal
        visible: finalhBarenable?true:false
        size:listBackground.width/ root.width
        anchors.bottom: controlBackground.bottom
        anchors.left: controlBackground.left
        width: finalvBarenable?(controlBackground.width - vBar.width):controlBackground.width
        height:hbarheight
        background:Rectangle{
            color: 'green'
        }

        contentItem: Rectangle{
            color: 'red'
        }
        onPositionChanged: {
            console.log(root.width, '   ',listBackground.width)
        }
    }
}
