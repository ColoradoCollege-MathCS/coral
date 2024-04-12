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
    modal: true
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
            onLinkActivated: Qt.openUrlExternally("https://www.gnu.org/licenses/gpl-3.0.en.html")
        }
        Text {
            text: "Application source code: <https://github.com/ColoradoCollege-MathCS/coral>"
            horizontalAlignment: Text.AlignLeft
            textFormat: Text.MarkdownText
            onLinkActivated: Qt.openUrlExternally("https://github.com/ColoradoCollege-MathCS/coral")
        }
        Text {
            text: "Icons from <a href=\"https://flaticon.com\">https://flaticon.com</a>: \
<ul>\
<li>Adjust Square, Magic Wand, Lasso, Selection Symbol by Freepik</li>\ 
<li>Floppy Disk by Yogi Aprelliyanto </li>\
<li>Move Button by SeyfDesigner </li>\
<li>Circle Select by Corner Pixel </li>\
<li>Paintbrush by Good Ware</li>\
<li>Recycle Bin by Lakonicon</li>\
</ul>"
            horizontalAlignment: Text.AlignLeft
            textFormat: Text.StyledText
            onLinkActivated: Qt.openUrlExternally("https://flaticon.com")
        }
    }
}