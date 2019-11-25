import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import './Custom'
import './Windows'

ApplicationWindow{
    id:root
    width: 1024
    height: 640
    visible:true
    Colorclassfier{
        id:colorclassfier
        width: root.width
        height: root.height

    }

    CustomDialogWithRadiobutton{
        modal: true
        id:choose_data_dialog
        listviewdata:['colorclassfier']
        onAccepted: {
            console.log('outside accepted evoke....',choose_data_dialog.data_type_choosed)
            switch(choose_data_dialog.data_type_choosed)
            {
            case listviewdata[0]:
                colorclassfier.visible = true
                root.visible = false
                //第一种数据格式
                break;
            case listviewdata[1]:
                //第二种数据格式
                break;
            default:
                console.log('Not supported yet...');
                break;

            }
        }
        onRejected: {
            console.log('outside reject evoke...')
            Qt.quit()
        }
    }
}




