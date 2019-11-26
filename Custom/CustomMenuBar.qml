import QtQuick 2.13
import QtQuick.Controls 2.12

MenuBar {
    id: menuBar

//    Menu { title: qsTr("File") ;
//          Action{text: qsTr('inner')}
//    }
//    Menu { title: qsTr("Edit") }
//    Menu { title: qsTr("View") }
//    Menu { title: qsTr("Help") }
    delegate: MenuBarItem {
        id: menuBarItem

        contentItem: Text {
            text: menuBarItem.text
            font: menuBarItem.font
            opacity: enabled ? 1.0 : 0.3
            color: menuBarItem.highlighted ? "#ffffff" : "#21be2b"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            id:itemBackground
            implicitWidth: 40
            implicitHeight: 40
            opacity: enabled ? 1 : 0.3
            color: menuBarItem.highlighted ? "#21be2b" : "transparent"
        }
    }
    background: Rectangle {
        implicitWidth: 40
        implicitHeight: 40
        color: 'purple'//"#ffffff"

        Rectangle {
            color: "#21be2b"
            width: parent.width
            height:3
            anchors.bottom: parent.bottom
        }
    }
}
