import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13

/*
  功能：弹出一个包含radiobutton的模态dialog
  ex:
    CustomDialogWithRadiobutton{
        modal: true
        id:choose_data_dialog
        listviewdata:['yolo','colorchoose']
        onAccepted: {
            console.log('outside accepted evoke....',choose_data_dialog.data_type_choosed)
        }
        onRejected: {
            console.log('outside reject evoke...')
            Qt.quit()
        }
    }
*/



Dialog{
    signal accepted
    signal rejected
    property var data_type_choosed:listviewdata[0]
    property var listviewdata: ['option a','option b','option c'] //该参数用于指定显示数据的名称
    id:choose_struct_dialog
    x: parent.width / 4
    y: parent.height / 4
    width: parent.width / 2
    height: parent.height / 2
    enabled: true
    visible: true
    modal: true
    closePolicy: Dialog.NoAutoClose   //这个设定很关键，默认关闭策略会在点击dialog外面空间的时候关闭dialog这样就无法达到为们模块化的效果
    header: Rectangle{
        id:header
        x:0
        y:0
        width: choose_struct_dialog.width
        height: choose_struct_dialog.height /5
        color: 'purple'
        border.color: 'blue'
        radius: 2
        Text {
            font.pixelSize:20
            color: 'yellow'
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:  parent.verticalCenter
            text: qsTr("please choose data structure...")
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                console.log('header clicked....')
            }
        }
    }
    //这里如果不用anchor对contentitem进行固定，则contentItem会产生一个空白的间隙，考虑是和其继承与popup有关
   contentItem:Rectangle{
       id:contentitem
       anchors.top: header.bottom
       anchors.left: header.left
       anchors.right: header.right
       anchors.bottom: footer.top
       //implicitWidth: choose_struct_dialog.width
       //implicitHeight: choose_struct_dialog * 3 /5
       border.color: 'blue'
       radius: 2
       color: 'yellow'
     //  Column{
     //      id:radio_choose_columu
     //      anchors.verticalCenter: parent.verticalCenter
     //      anchors.horizontalCenter: parent.horizontalCenter
     //      spacing: 2
           ListView{
               id:listview
               anchors.fill: parent
               anchors.verticalCenter: parent.verticalCenter
               anchors.horizontalCenter:parent.horizontalCenter
               model:listviewdata
               delegate: RadioDelegate{
                   text: modelData
                   checked: index==0
                   onClicked: {
                       console.log('choose changed: ',modelData)
                       data_type_choosed = modelData
                   }
               }
           }

    //       RadioButton{
    //           text: 'a'
    //       }
    //       RadioButton{
    //           text: 'b'
    //       }
    //   }

   }
   footer: Rectangle{
       id:footer
       radius: 2
       border.color: 'blue'
       color: 'red'
       x:0
       y:(choose_struct_dialog.height * 4) / 5
       width: choose_struct_dialog.width
       height: choose_struct_dialog.height / 5
       Button{
           id:ok
           text: 'ok'
           anchors.right: cancel.left
           anchors.rightMargin: 3
           anchors.top: cancel.top
           anchors.bottom: cancel.bottom
           implicitWidth: footer.width / 6
           background: Rectangle{
               color: 'yellow'
           }
           onClicked: {
              console.log('ok clicked....')
              choose_struct_dialog.accepted()

           }
       }
       Button{
           id:cancel
           text: 'cancel'
           anchors.right: footer.right
           anchors.rightMargin: 3
           anchors.top: footer.top
           anchors.topMargin: 3
           implicitHeight: footer.height / 3
           implicitWidth: footer.width / 6
           background: Rectangle{
               color: 'green'
           }
           onClicked: {
               console.log('cancel clicked....')
               choose_struct_dialog.rejected()
           }
       }

   }
   onAccepted: {
       console.log('Accepted...')
       accept()
       choose_struct_dialog.close()
   }
   onRejected: {
       console.log('Rejected...')
       reject()
       choose_struct_dialog.close()

   }
}
