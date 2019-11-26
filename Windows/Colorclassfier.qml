import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.0
import '../Custom'

ApplicationWindow{
    id:root
    width: 640
    height: 320


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
    CustomListView{
        id:path_view
        anchors.top: menubar.bottom
        anchors.left: menubar.left
        width: root.width / 10
        anchors.bottom: root.bottom
        vBarenable:true
        hBarenable:true
        xMoveable: true
        yMoveable:true

    }

}

