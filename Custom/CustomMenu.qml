import QtQuick 2.13
import QtQuick.Controls 2.13

Menu {
    id: menu

    topPadding: 2
    bottomPadding: 2

    //对每一个条目进行定制
    delegate: MenuItem {
        id: menuItem
        implicitWidth: 200
        implicitHeight: 40
        //对箭头标识进行定制
        arrow: Canvas {
            id:arrow
            x: parent.width - width
            implicitWidth: 40
            implicitHeight: 40
            visible: menuItem.subMenu //可以理解为有submenu则是可见的，没有则是不可见的
            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = menuItem.highlighted ? "green":"yellow" //"#ffffff" : "#21be2b"
                ctx.moveTo(15, 15)
                ctx.lineTo(width - 15, height / 2)
                ctx.lineTo(15, height - 15)
                ctx.closePath()
                ctx.fill()
            }
        }

        //对check标识进行定制
        indicator: Item {
            implicitWidth: 40
            implicitHeight: 40
            Rectangle {
                width: 26
                height: 26
                anchors.centerIn: parent
                visible: menuItem.checkable
                border.color: "#21be2b"
                radius: 3
                Rectangle {
                    width: 14
                    height: 14
                    anchors.centerIn: parent
                    visible: menuItem.checked
                    color: "#21be2b"
                    radius: 2
                }
            }
        }
        //对文字内容进行定制
        contentItem: Text {
            leftPadding: menuItem.indicator.width
            rightPadding: menuItem.arrow.width
            text: menuItem.text
            font: menuItem.font
            opacity: enabled ? 1.0 : 0.3
            color: menuItem.highlighted ? "#ffffff" : "#21be2b"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 40
            opacity: enabled ? 1 : 0.3
            color: menuItem.highlighted ? "#21be2b" : "transparent"
        }
        //这一部分的定制小心更改
        //设定mousearea为了让highlighted生效，同时需要重绘制arrow,同时由于mousearea覆盖了原结构，trigger需要重新转发
        MouseArea{
            anchors.fill:parent
            hoverEnabled: true
            onContainsMouseChanged: {
                       if(menuItem.subMenu !== null){
                           //console.log(containsMouse)
                      }
                      menuItem.highlighted = containsMouse  //是否拥有鼠标（即鼠标是否悬停在上面）
                      arrow.requestPaint()
            }
            onClicked: { // 转发click信号
                if(menuItem.checkable === true)
                    menuItem.checked = !menuItem.checked
                else if (menuItem.subMenu === true)
                {
                }
                else
                {
                    if(menuItem.action !== null)
                    {
                        menuItem.action.trigger()
                    }

                }
            }
        }

    }
//整个menu的背景
    background: Rectangle {
        implicitWidth: 400
        implicitHeight: 40
        color: 'purple' //"#ffffff"
        border.color: "#21be2b"
        radius:2
    }
}
