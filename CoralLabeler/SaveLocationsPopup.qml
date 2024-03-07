import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    //Default value:
    //MacOS: ~/Library/Application Support/CoralLabeler
    //Win: C:/Users/<USER>/AppData/Local/CoralLabeler
    //Linux: ~/.local/share/CoralLabeler
    property url currentTempFolder: StandardPaths.writableLocation(StandardPaths.AppDataLocation)
    //Mac/Linux: ~/Documents/CoralLabeler
    //Win: C:/Users/<USER>/Documents/CoralLabeler
    property url currentOutputFolder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/CoralLabeler"

    //property Toolbox the_tbox; 

    standardButtons: Dialog.Cancel | Dialog.Save
    title: qsTr("Save Locations")
    modal: true
    background: Rectangle {
        color: "white"
    }
    ColumnLayout {
        Text {
            text: "Location to save shape definitions, which let you resume working on the same images after closing the application."
            horizontalAlignment: Text.AlignLeft
        }
        TextField {
            id: tempFolderField
            text: tbox.trimFileUrl(currentTempFolder)
            horizontalAlignment: Text.AlignLeft
            Layout.fillWidth: true
            Layout.maximumWidth: 400
        }

        Text {
            text: "Location to save the outputs of the program, including the per pixel labels and statistics for each image."
            horizontalAlignment: Text.AlignLeft
        }

        TextField {
            id: outFolderField
            text: tbox.trimFileUrl(currentOutputFolder)
            horizontalAlignment: Text.AlignLeft
            Layout.fillWidth: true
            Layout.maximumWidth: 400
        }
    }
    onAccepted: {
        //if new directories do not exist, create them

        //update current location
        currentTempFolder = tbox.reFileUrl(tempFolderField.text)
        currentOutputFolder = tbox.reFileUrl(outFolderField.text)
    }
}