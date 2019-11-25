import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import '../Custom'

ApplicationWindow{
    id:root
    width: 640
    height: 320
    CustomMenuBar{
        id:menubar
    }
    CustomListView{
        anchors.top: menubar.bottom
        anchors.left: menubar.left
        width: root.width / 10
        anchors.bottom: root.bottom
        vBarenable:true
        hBarenable:true
        xMoveable: true
        yMoveable:true
        listviewdata:lotsofdata()

//        rightclickmenu: {
//            Action { text: qsTr("Tool Bar"); checkable: true }
//            Action { text: qsTr("Side Bar"); checkable: true; checked: true }
//            Action { text: qsTr("Status Bar"); checkable: true; checked: true }
//
//            MenuSeparator {
//                contentItem: Rectangle {
//                implicitWidth: 200
//                implicitHeight: 1
//                color: "#21be2b"
//                }
//            }
//            Menu {
//                title: qsTr("Advanced")
//                Action{text: qsTr('hello')}
//                // ...
//            }
//        }
    }

function lotsofdata(){
    var tmp = []
    for(var i = 0; i < 1000; i++)
    {
        tmp.push(i)
    }
    tmp.push('dhsajkdhasjkhsklshfjkagfgfkfgsjkgshjkfsggfs:w')
    return tmp
}
}

