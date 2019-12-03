import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.0
import '../Custom'
import ImageViewer 1.0
ApplicationWindow{
    property int imageview_curFrame: 0
    property int imageview_totalFrame: 0
    width: 640
    height: 320
    Rectangle{
        id:root
        anchors.fill: parent
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
//    Rectangle{
//        id:image_view_background
//        anchors.left:path_view.right
//        anchors.right: root.right
//        anchors.bottom: root.bottom
//        anchors.top: path_view.top
//        color: 'green'
//        Text {
//            id:image_view_frame_idx
//            anchors.centerIn: parent
//            text: imageview_curFrame + '/' + imageview_totalFrame
//            color: 'red'
//            z:1
//        }
//        ImageViewer{
//            id:image_view
//            z:0
//            anchors.fill:parent
//            visible:true
//            MouseArea{
//                id:image_view_mousearea
//                anchors.fill: parent
//                onClicked: {
//                    image_view.next()
//                    image_view.setRange('lab',[0,0,140],[255,255,255])
//                    image_view.show()
//                }
//            }
//        }
//    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ImageViewer{
            id:image_view
            z:0
            anchors.left:path_view.right
            anchors.right: root.right
            anchors.bottom: root.bottom
            anchors.top: path_view.top
            visible:true
            Text {
                id:image_view_frame_idx
                anchors.centerIn: parent
                text: imageview_curFrame + '/' + imageview_totalFrame
                color: 'red'
                z:1
            }
            MouseArea{
                id:image_view_mousearea
                anchors.fill: parent
                onClicked: {
                    image_view.next()
                    image_view.setRange('lab',[0,0,140],[255,255,255])
                    image_view.show()
                }
            }
        }
//处理信号连接

    signal sigImageViewAlert(string msg)
    signal sigImageViewCurFrame(int msg)
    signal sigImageViewTotalFrame(int msg)
//    sigCurFrame = Signal(int) #当前帧数报告
//    sigTotalFrame = Signal(int) #总帧数报告
    Component.onCompleted: {
        image_view.sigAlert.connect(sigImageViewAlert)
        image_view.sigCurFrame.connect(sigImageViewCurFrame)
        image_view.sigTotalFrame.connect(sigImageViewTotalFrame)
    }

    onSigImageViewCurFrame: {
        imageview_curFrame = msg
    }
    onSigImageViewTotalFrame: {
        imageview_totalFrame = msg
    }



////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}


























