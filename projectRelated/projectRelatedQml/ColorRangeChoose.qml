import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Window 2.13
import QtQuick.Layouts 1.13

ApplicationWindow{

    id:colorRangechoose
    signal sigmove
    visible: false
    width: back.width
    height: back.height
    //固定窗口
    maximumHeight: colorRangechoose.height
    minimumHeight: colorRangechoose.height
    minimumWidth: colorRangechoose.width
    maximumWidth: colorRangechoose.width
    property var sliderName:[]
    property var sliderPos:[]
    background: Rectangle{
        id:back
        color: 'green'
        width: innerColumn.width
        height:innerColumn.height
        ColumnLayout{
            id:innerColumn
            Repeater{
                model: sliderName
                delegate:Rectangle{
                    color: 'purple'
                    implicitHeight: text.contentHeight>slider.height?text.contentHeight:slider.height
                    implicitWidth: text.contentWidth + slider.width + 5
                    Text {
                        id:text
                        x:2
                        text: modelData + ':'
                    }
                    Slider{
                        id:slider
                        anchors.left: text.right
                        anchors.leftMargin: 2
                        stepSize: 1
                        from:0
                        value:0
                        to:255
                        onMoved: {
                            sliderPos[index] = value
                            console.log('index:', index , 'data : ', value)
                            colorRangechoose.sigmove()
                        }
                        Component.onCompleted: {
                            console.log('slider rebuild...')
                            sliderPos.push(value)
                        }
                        Component.onDestruction : {
                            console.log('slider des...')
                            if (sliderPos.length !== 0){
                                sliderPos = []
                            }

                        }

                    }
                }
                Component.onDestruction: {
//                    console.log('1111')
                }
            }
        }
    }

    onClosing: {
        close.accepted = true
    }
}





















