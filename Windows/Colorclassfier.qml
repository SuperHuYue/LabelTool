import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.13
import '../Custom'
import '../projectRelated/projectRelatedQml'
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
    ColorRangeChoose{
        id:space_range_choose
        sliderName: ['lMin','lMax','aMin','aMax','bMin','bMax']
        visible: false
        property var space_name: 'lab'
        x:root.width + 10
        y:0
        onSigmove: {
            var pos = lab_fit_data()
            image_view.setRange(space_name,pos[0],pos[1])
            image_view.show()
        }
        function lab_fit_data(){
            //依据slidername生成符合处理条件的数据
            var fir = 0,sec = 0;
            console.log('slider length: ',sliderPos.length)
            if(sliderPos.length === 6){
                fir = [sliderPos[0],sliderPos[2],sliderPos[4]]
                sec = [sliderPos[1],sliderPos[3],sliderPos[5]]
            }
            else if(sliderPos.length == 2) //针对gray
            {
                fir = [sliderPos[0]]
                sec = [sliderPos[1]]
            }
            else{
                fir = [0,0,0]
                sec = [0,0,0]
            }
            var final_pos = [fir,sec]
            return final_pos
        }
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
    Rectangle{
        id:tool_choose
        anchors.left: menubar.right
        anchors.leftMargin: 2
        anchors.top: root.top
        anchors.right: root.right
        anchors.bottom: menubar.bottom
        color: 'pink'
        RowLayout{
            anchors.fill: parent
            RadioButton{
                id:luv_space
                text: qsTr("luv")
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.close()
//                    space_range_choose.visible = false 使用visible在radiobutton切换过错中会存在问题，具体原因尚且未曾遭到(到graylabel时候会出现空白)
                    space_range_choose.space_name = "luv"
                    space_range_choose.sliderName = ['lMin','lMax','uMin','uMax','vMin','vMax']
                    space_range_choose.show()
                }

            }
            RadioButton{
                id:rgb_space
                text: qsTr('rgb')
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.close()
//                    space_range_choose.visible = false
                    space_range_choose.space_name = "rgb"
                    space_range_choose.sliderName = ['bMin','bMax','gMin','gMax','rMin','rMax']
                    space_range_choose.show()
                }
            }
            RadioButton{
                id:hls_space
                text: qsTr('hls')
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.close()
//                    space_range_choose.visible = false
                    space_range_choose.space_name = 'hls'
                    space_range_choose.sliderName = ['hMin','hMax','lMin','lMax','sMin','sMax']
                    space_range_choose.show()
                }
            }
            RadioButton{
                id:gray_space
                text: qsTr('gray')
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.close()
//                    space_range_choose.visible = false
                    space_range_choose.space_name = 'gray'
                    space_range_choose.sliderName = ['Min','Max']
                    space_range_choose.show()
                }
            }
            RadioButton{
                id:lab_space
                text: qsTr('lab')
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.close()
//                    space_range_choose.visible = false
                    space_range_choose.space_name = 'lab'
                    space_range_choose.sliderName = ['lMin','lMax','aMin','aMax','bMin','bMax']
                    space_range_choose.show()
                }
            }
            RadioButton{
                id:others
                text: qsTr('others')
                checked: true
                Layout.minimumWidth: 30
                Layout.preferredWidth: 100
                onClicked: {
                    space_range_choose.visible = false
                }

            }

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
    ImageViewer{
        property double stretch_step: 0.1
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
            focus: true
            hoverEnabled: true
            onPositionChanged: {
                image_view.setMousePos(mouseX,mouseY)
            }

            onClicked: {
                console.log('image click...')
                image_view.next()
//                image_view.setRange('lab',[0,0,140],[255,255,255]) //设置变换颜色的方法
                image_view.show()

            }
             onWheel: {
                 console.log("PosX: ",wheel.x,"PosY: ",wheel.y)
                 if(wheel.modifiers &Qt.ControlModifier){
                     image_view.setMousePos(wheel.x,wheel.y)
                     if(wheel.angleDelta.y < 0){ //缩小
                             image_view.imageStretch = image_view.imageStretch - 0.1
                     }
                     else{  					//放大
                         image_view.imageStretch = image_view.imageStretch + 0.1
                     }
                     image_view.update()
                 }
                 console.log('Now ImageStretch...',image_view.imageStretch)
                 wheel.accepted = true
             }
        }
    }

//处理信号连接
    signal sigImageViewAlert(string msg)
    signal sigImageViewCurFrame(int msg)
    signal sigImageViewTotalFrame(int msg)
    signal sigImageViewPicPos(int x,int y)
//    sigCurFrame = Signal(int) #当前帧数报告
//    sigTotalFrame = Signal(int) #总帧数报告
    Component.onCompleted: {
        image_view.sigAlert.connect(sigImageViewAlert)
        image_view.sigCurFrame.connect(sigImageViewCurFrame)
        image_view.sigTotalFrame.connect(sigImageViewTotalFrame)
        image_view.sigPicPos.connect(sigImageViewPicPos)
    }
    onSigImageViewPicPos: {
//        console.log('Qml x: ',x,'y: ',y)
    }

    onSigImageViewCurFrame: {
        imageview_curFrame = msg
    }
    onSigImageViewTotalFrame: {
        imageview_totalFrame = msg
    }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}


























