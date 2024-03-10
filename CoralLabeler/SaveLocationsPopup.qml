import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    function processError(errorcode) {
        if (errorcode !=0 ) {
                var errormsg
                if (errorcode == 1) {//File already exists and is not a directory
                    errormsg = "A non-directory file already exists at one of the specified paths. Please set a different path."
                } else if (errorcode == 2) { //PermissionError
                    errormsg = "You do not have permission to write to one of the specified paths. Please set a different path"
                }
                else if (errorcode == 3) { //OSError
                    errormsg = "An error occured while setting the paths. Please try again or set a different path."
                }
                var dialog = `
import QtQuick
import QtQuick.Dialogs
    MessageDialog {
        title: "Error saving paths"
        text: "${errormsg}"
        buttons: MessageDialog.Ok
    }`
                var dlog = Qt.createQmlObject(dialog, this)
                dlog.open()
            }
    }
    function updateText() {
        tempFolderField.text = tbox.trimFileUrl(tbox.getTempUrl())
        outFolderField.text = tbox.trimFileUrl(tbox.getOutUrl())
    }

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
            text: ""
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
            text: ""
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

        //add to/create config file with this preference
        tbox.saveFilePreference(tbox.reFileUrl(tempFolderField.text), tbox.reFileUrl(outFolderField.text))
        //create folders if neccessary
        var result = tbox.initFilePreference(tbox.reFileUrl(tempFolderField.text), tbox.reFileUrl(outFolderField.text))
        processError(result)
    }

    onRejected: {
        if (!tbox.fileExists("file_config")) {
            //if user cancelled but no value exists, choose defaults
            tbox.saveFilePreference(StandardPaths.writableLocation(StandardPaths.AppDataLocation), StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/CoralLabeler")
            var result = tbox.initFilePreference(StandardPaths.writableLocation(StandardPaths.AppDataLocation), StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/CoralLabeler")
            processError(result)
        }
        //otherwise do nothing, keeping their last value
    }
}