import QtQuick 2.13
import QtQuick.Controls 2.12

MenuBar {
    id: menuBar
    Menu { title: qsTr("File") ;
          Action{text: qsTr('inner')}
    }
    Menu { title: qsTr("Edit") }
    Menu { title: qsTr("View") }
    Menu { title: qsTr("Help") }

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
            MouseArea{
                anchors.fill: parent
                propagateComposedEvents: true //该参数可以将覆盖的空间信息再度发送,前提是，该区域消息没有被处理
                onClicked: {
                    console.log("MenuItem clicked...")  //该区域信息已经被处理，即使设定propagateComposedEcents为true不能进行传递
                    //barBackground.clicked(null) // 通过转发的方式，可以达到信息再传递
                    menuBarItem.clicked()
                }

            }
        }
    }
    background: Rectangle {
        implicitWidth: 40
        implicitHeight: 40
        color: 'purple'//"#ffffff"
        MouseArea{
        id:barBackground
        propagateComposedEvents: true
        anchors.fill: parent
        onClicked: {
            console.log('barBackground click...')
            }
        }

        Rectangle {
            color: "#21be2b"
            width: parent.width
            height:3
            anchors.bottom: parent.bottom
        }
    }
}
