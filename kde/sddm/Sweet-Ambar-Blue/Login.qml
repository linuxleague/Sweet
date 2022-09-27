import "components"

import QtQuick 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

SessionManagementScreen {
    id: root
    property Item mainPasswordBox: passwordBox

    property bool showUsernamePrompt: !showUserList

    property string lastUserName
    property bool loginScreenUiVisible: false

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + units.smallSpacing

    signal loginRequest(string username, string password)

    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    /*
    * Login has been requested with the following username and password
    * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
    */
    function startLogin() {
        var username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        var password = passwordBox.text

        //this is partly because it looks nicer
        //but more importantly it works round a Qt bug that can trigger if the app is closed with a TextField focused
        //DAVE REPORT THE FRICKING THING AND PUT A LINK
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    Input {
        id: userNameInput
        Layout.fillWidth: true
        Layout.topMargin: 10
        Layout.bottomMargin: 10
        text: lastUserName
        visible: showUsernamePrompt
        focus: showUsernamePrompt && !lastUserName //if there's a username prompt it gets focus first, otherwise password does
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Username")

        onAccepted:
            if (root.loginScreenUiVisible) {
                passwordBox.forceActiveFocus()
            }
    }

    Input {
        id: passwordBox
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
        focus: !showUsernamePrompt || lastUserName
        echoMode: TextInput.Password

        Layout.fillWidth: true

        onAccepted: {
            if (root.loginScreenUiVisible) {
                startLogin();
            }
        }

        Keys.onEscapePressed: {
            mainStack.currentItem.forceActiveFocus();
        }

        //if empty and left or right is pressed change selection in user switch
        //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
        Keys.onPressed: {
            if (event.key == Qt.Key_Left && !text) {
                userList.decrementCurrentIndex();
                event.accepted = true
            }
            if (event.key == Qt.Key_Right && !text) {
                userList.incrementCurrentIndex();
                event.accepted = true
            }
        }

        Connections {
            target: sddm
            onLoginFailed: {
                passwordBox.selectAll()
                passwordBox.forceActiveFocus()
            }
        }
    }
    Button {
        id: loginButton
        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log In")
        enabled: passwordBox.text != ""

        Layout.topMargin: 15
        Layout.bottomMargin: 10
        Layout.preferredWidth: 170
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        
        font.pointSize: config.fontSize
        font.family: config.font
        opacity: enabled ? 1.0 : 0.7

        contentItem: Text {
            text: loginButton.text
            font: loginButton.font
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            id: buttonBackground
            height: parent.width
            width: passwordBox.height
            radius: width / 2
            rotation: -90
            anchors.centerIn: parent

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#20BDFF" }
                GradientStop { position: 1.0; color: "#5433FF" }
            }
        }
        onClicked: startLogin();
    }


    DropShadow {
        anchors.fill: loginButton
        horizontalOffset: 0
        verticalOffset: 0
        radius: 14
        samples: 25
        color: "#0072ff"
        source: loginButton
        z:-1
        opacity: loginButton.enabled ? 1 : 0
    }

}