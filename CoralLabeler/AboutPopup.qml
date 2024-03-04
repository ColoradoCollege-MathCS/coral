import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    title: qsTr("About")
    standardButtons: Dialog.Ok
    background: Rectangle {
        color: "white"
    }

    ColumnLayout {
        Text {
            text: "CoralLabeler built by Calvin Than, Dylan Chapell, Khawla Douah, and Mai Nguyen"
            horizontalAlignment: Text.AlignLeft
            textFormat: Text.MarkdownText
        }
        Text {
            text: "Licensed under the [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.en.html)"
            horizontalAlignment: Text.AlignLeft
            textFormat: Text.MarkdownText
        }
        Text {
            text: "Application source code: <https://github.com/ColoradoCollege-MathCS/coral>"
            horizontalAlignment: Text.AlignLeft
            textFormat: Text.MarkdownText
        }
        Text {
            text: "Icons from <https://flaticon.com>: "
            horizontalAlignment: Text.AlignLeft
            textFormat: Text.MarkdownText
        }
    }
}