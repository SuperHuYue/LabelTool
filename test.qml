import QtQuick 2.4
import QtQuick.Window 2.2

Window {
    id: win
    width: 800
    height: 600
    title: "Drag & drop example"
    visible: true

    Repeater {
        model: 10
        Rectangle {
            id: rect
            width: 50
            height: 50
            z: mouseArea.drag.active ||  mouseArea.pressed ? 2 : 1
            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
            x: Math.random() * (win.width / 2 - 100)
            y: Math.random() * (win.height - 100)
            property point beginDrag
            property bool caught: false
            border { width:2; color: "white" }
            radius: 5
            Drag.active: mouseArea.drag.active

            Text {
                anchors.centerIn: parent
                text: index
                color: "white"
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                drag.target: parent
                onPressed: {
                    rect.beginDrag = Qt.point(rect.x, rect.y);
                }
                onReleased: {
                    if(!rect.caught) {
                        backAnimX.from = rect.x;
                        backAnimX.to = beginDrag.x;
                        backAnimY.from = rect.y;
                        backAnimY.to = beginDrag.y;
                        backAnim.start()
                    }
                }

            }
            ParallelAnimation {
                id: backAnim
                SpringAnimation { id: backAnimX; target: rect; property: "x"; duration: 500; spring: 2; damping: 0.2 }
                SpringAnimation { id: backAnimY; target: rect; property: "y"; duration: 500; spring: 2; damping: 0.2 }
            }
        }
    }

    Rectangle {
        anchors {
            top: parent.top
            right:  parent.right
            bottom:  parent.bottom
        }
        width: parent.width / 2
        color: "gold"
        DropArea {
            anchors.fill: parent
            onEntered: drag.source.caught = true;
            onExited: drag.source.caught = false;
        }
    }
}
