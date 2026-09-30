import QtQuick
import QtQuick.Effects
import Quickshell
import qs.Commons
import qs.Ui

// Tsukiyo lock screen.
// Only the visuals differ from omarchy.lock: the public properties, signals and
// password handling below are kept identical so Service.qml drives it unchanged.
Item {
  id: root

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  // ── Palette, read from the active theme so it follows colors.toml ──
  readonly property color ink: Color.background
  readonly property color parchment: Color.lock.text
  readonly property color mist: Color.accent
  readonly property color fog: Util.alpha(Color.lock.text, 0.34)
  readonly property color faint: Util.alpha(Color.lock.text, 0.16)
  readonly property color ember: Color.lock.textError

  readonly property string serif: "Noto Serif CJK JP"
  readonly property string mono: Style.font.family
  readonly property real unit: Math.max(0.85, Math.min(width / 1600, height / 1000))

  readonly property bool errorState: failureMessage.length > 0
  readonly property bool typing: passwordInput.text.length > 0
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && !errorState

  readonly property string userName: Quickshell.env("USER") || ""
  property date now: new Date()

  readonly property string greeting: {
    var h = now.getHours()
    if (h < 5) return "still awake"
    if (h < 12) return "good morning"
    if (h < 17) return "good afternoon"
    if (h < 22) return "good evening"
    return "good night"
  }

  function fileUrl(path) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + backgroundVersion
  }

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  onFailedAttemptsChanged: if (failedAttempts > 0) shake.restart()
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  Timer {
    interval: 1000
    repeat: true
    running: root.visible
    triggeredOnStart: true
    onTriggered: root.now = new Date()
  }

  Rectangle {
    anchors.fill: parent
    color: root.ink

    // ── Backdrop: the wallpaper, softly blurred, drifting very slowly ──
    Item {
      id: backdrop
      anchors.fill: parent
      layer.enabled: true   // blur once, then only transform the cached texture
      transformOrigin: Item.Center

      Image {
        id: wallpaper
        anchors.fill: parent
        visible: false
        source: root.loadBackground ? root.fileUrl(root.backgroundPath) : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        sourceSize.width: width
        sourceSize.height: height
      }

      MultiEffect {
        anchors.fill: wallpaper
        source: wallpaper
        autoPaddingEnabled: false
        visible: wallpaper.status === Image.Ready
        blurEnabled: true
        blur: 0.55
        blurMax: 64
        blurMultiplier: 1.0
        brightness: -0.08
        saturation: -0.12
        contrast: -0.05
      }

      SequentialAnimation on scale {
        running: root.loadBackground && root.visible
        loops: Animation.Infinite
        NumberAnimation { from: 1.02; to: 1.08; duration: 60000; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1.08; to: 1.02; duration: 60000; easing.type: Easing.InOutSine }
      }
    }

    // ── Night-ink veil: light at the top, deep behind the password ──
    Rectangle {
      anchors.fill: parent
      gradient: Gradient {
        GradientStop { position: 0.0; color: Util.alpha(root.ink, 0.35) }
        GradientStop { position: 0.45; color: Util.alpha(root.ink, 0.30) }
        GradientStop { position: 1.0; color: Util.alpha(root.ink, 0.88) }
      }
    }

    // ── Fog: three wide bands drifting at different speeds ──
    Repeater {
      model: [
        { y: 0.30, h: 0.22, a: 0.050, d: 140000, dir: 1 },
        { y: 0.58, h: 0.28, a: 0.045, d: 190000, dir: -1 },
        { y: 0.78, h: 0.20, a: 0.060, d: 110000, dir: 1 }
      ]

      delegate: Rectangle {
        required property var modelData
        width: root.width * 1.8
        height: root.height * modelData.h
        y: root.height * modelData.y
        opacity: modelData.a
        gradient: Gradient {
          GradientStop { position: 0.0; color: "transparent" }
          GradientStop { position: 0.5; color: root.parchment }
          GradientStop { position: 1.0; color: "transparent" }
        }

        SequentialAnimation on x {
          running: root.loadBackground && root.visible
          loops: Animation.Infinite
          NumberAnimation {
            from: modelData.dir > 0 ? -root.width * 0.8 : 0
            to: modelData.dir > 0 ? 0 : -root.width * 0.8
            duration: modelData.d
            easing.type: Easing.InOutSine
          }
          NumberAnimation {
            from: modelData.dir > 0 ? 0 : -root.width * 0.8
            to: modelData.dir > 0 ? -root.width * 0.8 : 0
            duration: modelData.d
            easing.type: Easing.InOutSine
          }
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    // ── Time ──
    Column {
      id: timeBlock
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.verticalCenter
      anchors.bottomMargin: 36 * root.unit
      spacing: 10 * root.unit

      opacity: root.loadBackground ? 1 : 0
      transform: Translate { y: root.loadBackground ? 0 : 18 * root.unit; Behavior on y { NumberAnimation { duration: 1100; easing.type: Easing.OutCubic } } }
      Behavior on opacity { NumberAnimation { duration: 1100; easing.type: Easing.OutCubic } }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.greeting + (root.userName ? ", " + root.userName : "")
        color: root.fog
        font.family: root.mono
        font.pixelSize: 14 * root.unit
        font.letterSpacing: 3 * root.unit
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10 * root.unit

        Text {
          id: clock
          text: Qt.formatTime(root.now, "h:mm AP").split(" ")[0]
          color: root.parchment
          font.family: root.serif
          font.weight: Font.ExtraLight
          font.pixelSize: 168 * root.unit
          font.letterSpacing: -2 * root.unit
          layer.enabled: true
          layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.ink
            shadowOpacity: 0.55
            shadowBlur: 1.0
            shadowVerticalOffset: 4
          }
        }

        Text {
          anchors.baseline: clock.baseline
          text: Qt.formatTime(root.now, "AP").toLowerCase()
          color: root.fog
          font.family: root.mono
          font.pixelSize: 15 * root.unit
          font.letterSpacing: 2 * root.unit
        }
      }

      // 月夜 between two hairlines, signed like a print (as on the boot screen)
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14 * root.unit

        Rectangle { width: 44 * root.unit; height: 1; color: root.faint; anchors.verticalCenter: parent.verticalCenter }
        Text {
          text: "月夜"
          color: root.mist
          opacity: 0.85
          font.family: root.serif
          font.weight: Font.Light
          font.pixelSize: 18 * root.unit
          font.letterSpacing: 6 * root.unit
        }
        Rectangle { width: 44 * root.unit; height: 1; color: root.faint; anchors.verticalCenter: parent.verticalCenter }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDate(root.now, "dddd  ·  d MMMM").toLowerCase()
        color: root.mist
        font.family: root.mono
        font.pixelSize: 14 * root.unit
        font.letterSpacing: 4 * root.unit
      }
    }

    // ── Password: a single hairline that fills with mist as you type ──
    Item {
      id: inputField
      width: 320 * root.unit
      height: 64 * root.unit
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.verticalCenter
      anchors.topMargin: 96 * root.unit

      opacity: root.loadBackground ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 1400; easing.type: Easing.OutCubic } }

      transform: Translate { id: shakeOffset }

      SequentialAnimation {
        id: shake
        NumberAnimation { target: shakeOffset; property: "x"; to: -10 * root.unit; duration: 60; easing.type: Easing.OutQuad }
        NumberAnimation { target: shakeOffset; property: "x"; to: 8 * root.unit; duration: 90; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeOffset; property: "x"; to: -5 * root.unit; duration: 90; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeOffset; property: "x"; to: 2 * root.unit; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 120; easing.type: Easing.OutQuad }
      }

      // Measures the masked password at full size so long passwords shrink to fit.
      TextMetrics {
        id: dotMetrics
        font.family: root.mono
        font.pixelSize: 20 * root.unit
        font.letterSpacing: 6 * root.unit
        text: "•".repeat(passwordInput.text.length)
      }

      TextInput {
        id: passwordInput
        anchors.fill: parent
        anchors.bottomMargin: 6 * root.unit
        anchors.leftMargin: 8 + (root.fingerprintConfigured ? 28 * root.unit : 0)
        anchors.rightMargin: 8 + (root.fingerprintConfigured ? 28 * root.unit : 0)
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        clip: true
        enabled: root.inputEnabled && !root.authenticatingPassword
        readOnly: root.authenticatingPassword
        echoMode: TextInput.Password
        passwordCharacter: "•"
        passwordMaskDelay: 0
        color: root.parchment
        selectionColor: Color.lock.selection
        selectedTextColor: root.parchment
        font.family: root.mono
        readonly property real fit: dotMetrics.advanceWidth > 0 ? Math.min(1, (width - 4) / dotMetrics.advanceWidth) : 1
        font.pixelSize: Math.max(1, Math.floor(20 * root.unit * fit))
        font.letterSpacing: 6 * root.unit * fit
        cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
        cursorDelegate: Rectangle {
          width: 1
          color: root.mist
          visible: passwordInput.cursorVisible
        }

        onTextChanged: {
          if (!root.syncingPasswordText) root.passwordTextEdited(text)
          if (text.length > 0) root.wakeRequested()
          if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
        }

        onAccepted: {
          var submitted = root.passwordText
          root.passwordTextEdited("")
          if (submitted.length > 0) root.submitPassword(submitted)
        }

        Keys.onPressed: function(event) {
          root.wakeRequested()
          if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
            root.passwordTextEdited("")
            event.accepted = true
          }
        }
      }

      Text {
        textFormat: Text.PlainText
        anchors.fill: passwordInput
        visible: !root.typing
        text: root.authenticatingPassword ? "checking" : (root.errorState ? root.failureMessage.toLowerCase() : "enter password")
        color: root.authenticatingPassword ? root.mist : (root.errorState ? root.ember : root.fog)
        font.family: root.mono
        font.pixelSize: 13 * root.unit
        font.letterSpacing: 3 * root.unit
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        Behavior on color { ColorAnimation { duration: 300 } }
      }

      // The hairline and its fill
      Rectangle {
        id: line
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 1
        color: root.faint

        Rectangle {
          anchors.centerIn: parent
          height: 1
          width: root.errorState || root.typing || root.authenticatingPassword ? parent.width : parent.width * 0.18
          color: root.errorState ? root.ember : root.mist
          opacity: root.errorState || root.typing || root.authenticatingPassword ? 0.9 : 0.55
          Behavior on width { NumberAnimation { duration: 520; easing.type: Easing.OutCubic } }
          Behavior on opacity { NumberAnimation { duration: 400 } }
          Behavior on color { ColorAnimation { duration: 300 } }
        }

        // Checking: a soft glint travels along the line
        Rectangle {
          id: glint
          visible: root.authenticatingPassword
          width: parent.width * 0.3
          height: 1
          y: 0
          gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: root.parchment }
            GradientStop { position: 1.0; color: "transparent" }
          }
          NumberAnimation on x {
            running: root.authenticatingPassword
            loops: Animation.Infinite
            from: -glint.width
            to: line.width
            duration: 1100
            easing.type: Easing.InOutSine
          }
        }
      }

      // Fingerprint hint, kept in the same place hyprlock draws it
      Text {
        id: fingerprintIcon
        objectName: "fingerprintIndicator"
        anchors.right: parent.right
        anchors.verticalCenter: passwordInput.verticalCenter
        visible: root.fingerprintConfigured
        text: "󰈷"
        color: root.fog
        font.family: root.mono
        font.pixelSize: 18 * root.unit
      }
    }

    // ── Footer ──
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 36 * root.unit
      opacity: root.loadBackground ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 1800; easing.type: Easing.OutCubic } }
      text: "enter ↵ unlock   ·   esc clear"
      color: Util.alpha(root.parchment, 0.22)
      font.family: root.mono
      font.pixelSize: 11 * root.unit
      font.letterSpacing: 2 * root.unit
    }
  }
}
