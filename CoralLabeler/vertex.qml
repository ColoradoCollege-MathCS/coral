import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import Qt.labs.folderlistmodel
import QtQuick.Shapes



Rectangle {
    color: "black"
    radius: 20
    width: radius
    height: radius
    visible: true

    x: papa.x
    y: papa.y

    property var papa: undefined
}