import QtQuick 2.0

Rectangle{
    id:scrollBarBackground
    signal positionchange(real pos)
    property real position: 0
    property real size:1
    z:0
    color: 'black'
    states: [
        State {
            name: "horizental"
            PropertyChanges {
                target: scrollBarContentItem
                anchors.top: scrollBarBackground.top
                anchors.bottom:scrollBarBackground.bottom
                color:'green'
                x:scrollBarBackground.width * position
                y:0
                width:scrollBarBackground.width * size
                onXChanged:{
                    scrollBarBackground.positionchange(scrollBarContentItem.x)
                }
            }
            PropertyChanges {
                target: scrollBarContentItemArea
                drag.axis: Drag.XAxis
                drag.minimumX: 0
                drag.maximumX: scrollBarBackground.width - scrollBarContentItem.width

            }
        },
        State {
            name: "vertical"
            PropertyChanges {
                target:scrollBarContentItem
                anchors.left: parent.left
                anchors.right: parent.right
                color:'yellow'
                x:0
                y: scrollBarBackground.height * position
                height: scrollBarBackground.height * size
                onYChanged:{
                    scrollBarBackground.positionchange(scrollBarContentItem.y)
                }
            }
            PropertyChanges {
                target: scrollBarContentItemArea
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY:scrollBarBackground.height - scrollBarContentItem.height

            }
        }
    ]

    Rectangle{
        id:scrollBarContentItem
        property bool press: false
        border.width: 3
        border.color: 'purple'
        Drag.active: scrollBarContentItemArea.drag.active
       //Drag.dragType: Drag.Automatic
       //Drag.mimeData: {'hei':'tyr'}
        z:2
        MouseArea{
            z:2
            id:scrollBarContentItemArea
            anchors.fill:scrollBarContentItem
            drag.target: scrollBarContentItem
        }

    }

}
