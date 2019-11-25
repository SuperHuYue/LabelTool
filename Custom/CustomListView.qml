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
    Rectangle{
         id:listBackground
         anchors.left: controlBackground.left
         anchors.top: controlBackground.top
         width: vBarenable?(controlBackground.width - vbarwidth):controlBackground.width
         height: hBarenable?(controlBackground.height - hbarheight):controlBackground.height
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
                     propagateComposedEvents: true

                     onClicked: {
                         root.currentIndex = index
                         console.log('curidx: ',root.currentIndex, 'total idx', root.count)
                     }
                 }
             }

         }
         MouseArea{
             id:background_area
             anchors.fill:listBackground
             property bool xSensArea: false
             property bool ySensArea: false
             property bool xStretch: false
             property bool yStretch: false
             property var pos:[]
             propagateComposedEvents: true
             hoverEnabled: true

             onPressed: {
                 if(xSensArea == true){
                     xStretch = true
                     pos = [mouseX,mouseY]
                 }
                 if(ySensArea == true){
                     yStretch = true
                     pos = [mouseX,mouseY]
                 }
             }
             onReleased: {
                 xStretch = false
                 yStretch = false
             }

             onPositionChanged: { // mouse给入的是相对当前mouseare的坐标
                 var xCursorChange = mouseX > (listBackground.width - 5) && mouseX < (listBackground.width + 5);
                 var yCursorChange = mouseY > (listBackground.height - 5) && mouseY < (listBackground.height + 5)
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

    }

    ScrollBar{
        id:vBar
        z:1
        active: pressed
        orientation: Qt.Vertical
        visible: vBarenable?true:false
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
        visible: hBarenable?true:false
        size:listBackground.width/ root.width
        anchors.bottom: controlBackground.bottom
        anchors.left: controlBackground.left
        width: vBarenable?(controlBackground.width - vBar.width):controlBackground.width
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
