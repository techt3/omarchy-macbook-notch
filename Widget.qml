import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import qs.Ui as Ui

// MacBook Notch Spacer: Fills the dead zone under the display notch
// and moves usable status bar widgets/apps away from the obscured region.
BarWidget {
  id: root
  moduleName: "wilk.macbook-notch"

  Commons.Translations {
    id: strings
    directory: Qt.resolvedUrl("i18n")
  }

  // --- Settings & State ---
  readonly property int initialWidth: Math.max(0, Number(setting("width", 200)))
  property int liveWidth: initialWidth
  property string currentNotchStyle: String(setting("notchStyle", "spacer"))
  property bool currentOnlyOnNotch: Boolean(setting("onlyOnNotchScreen", true))

  onSettingsChanged: {
    var w = Math.max(0, Number(setting("width", 200)))
    if (liveWidth !== w) liveWidth = w
    var s = String(setting("notchStyle", "spacer"))
    if (currentNotchStyle !== s) currentNotchStyle = s
    var o = Boolean(setting("onlyOnNotchScreen", true))
    if (currentOnlyOnNotch !== o) currentOnlyOnNotch = o
  }

  // Detect whether this instance sits on the built-in laptop screen with a notch
  readonly property var activeWindow: root.QsWindow ? root.QsWindow.window : null
  readonly property var activeScreen: activeWindow ? activeWindow.screen : null
  readonly property string screenName: activeScreen ? String(activeScreen.name) : ""
  readonly property int screenPixelWidth: activeScreen ? Math.round(activeScreen.width * (activeScreen.devicePixelRatio || 1)) : 0
  readonly property int screenPixelHeight: activeScreen ? Math.round(activeScreen.height * (activeScreen.devicePixelRatio || 1)) : 0
  readonly property real screenScale: activeScreen ? (activeScreen.devicePixelRatio || 1) : 1

  readonly property bool isNotchScreen: {
    if (screenName === "") return true
    // Built-in laptop displays use eDP (embedded DisplayPort)
    return screenName.indexOf("eDP") === 0
  }

  readonly property bool shouldDisplay: !currentOnlyOnNotch || isNotchScreen
  readonly property int effectiveWidth: shouldDisplay ? liveWidth : 0

  readonly property real windowWidth: activeWindow ? activeWindow.width : (activeScreen ? activeScreen.width : 1512)
  readonly property int notchCenterX: Math.round(windowWidth / 2)
  readonly property int notchX: Math.round(notchCenterX - (effectiveWidth / 2))

  // In the bar layout grid, keep implicitWidth: 0 so this widget does not displace
  // or sit on any adjacent icons.
  implicitWidth: 0
  implicitHeight: barSize
  visible: effectiveWidth > 0

  Behavior on liveWidth {
    NumberAnimation {
      duration: Style.duration(150)
      easing.type: Easing.OutCubic
    }
  }

  // Shape contract for shell.summon/hide/toggle routing
  readonly property bool opened: popup.open

  function open() {
    popup.open = true
  }

  function close() {
    popup.open = false
  }

  function toggle() {
    popup.open = !popup.open
  }

  function applyPreset(width) {
    liveWidth = width
    saveSettings()
  }

  function saveSettings() {
    var entry = {
      id: root.moduleName,
      width: liveWidth,
      notchStyle: currentNotchStyle,
      onlyOnNotchScreen: currentOnlyOnNotch
    }
    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function") {
      root.bar.shell.updateEntryInline(root.moduleName, entry)
    }
  }

  // --- Visuals in Bar ---
  // Automatic Notch Centering:
  // Anchors directly to the bar window contentItem.
  // This guarantees it is ALWAYS positioned at the exact center under the notch,
  // without displacing or overlapping any right-side icons.
  Rectangle {
    id: notchSurface
    parent: root.activeWindow ? root.activeWindow.contentItem : root
    x: root.notchX
    y: 0
    width: root.effectiveWidth
    height: root.barSize
    z: 100
    visible: root.shouldDisplay && (root.currentNotchStyle === "notch" || mouseArea.containsMouse)
    color: root.currentNotchStyle === "notch" ? "#000000" : Qt.rgba(1, 1, 1, 0.08)
    bottomLeftRadius: 10
    bottomRightRadius: 10
    topLeftRadius: 0
    topRightRadius: 0

    Behavior on color {
      ColorAnimation {
        duration: Style.duration(140)
        easing.type: Easing.OutCubic
      }
    }

    Behavior on x {
      NumberAnimation {
        duration: Style.duration(150)
        easing.type: Easing.OutCubic
      }
    }

    Behavior on width {
      NumberAnimation {
        duration: Style.duration(150)
        easing.type: Easing.OutCubic
      }
    }

    // Camera dot indicator
    Rectangle {
      anchors.centerIn: parent
      width: Style.space(6)
      height: Style.space(6)
      radius: width / 2
      color: mouseArea.containsMouse ? Commons.Color.accent : Qt.rgba(1, 1, 1, 0.25)
      visible: mouseArea.containsMouse || root.currentNotchStyle !== "spacer"

      Behavior on color {
        ColorAnimation {
          duration: Style.duration(140)
          easing.type: Easing.OutCubic
        }
      }
    }

    MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.toggle()
      onEntered: {
        if (root.bar && typeof root.bar.showTooltip === "function") {
          root.bar.showTooltip(root, strings.t("widget.tooltip"))
        }
      }
      onExited: {
        if (root.bar && typeof root.bar.hideTooltip === "function") {
          root.bar.hideTooltip(root)
        }
      }
    }
  }

  // --- Settings Dropdown Panel (Dynamic Island / Notch Card) ---
  PopupCard {
    id: popup
    anchorItem: notchSurface
    bar: root.bar
    owner: root
    open: false
    contentWidth: popup.fittedContentWidth(Style.space(340))
    contentHeight: popup.fittedContentHeight(cardColumn.implicitHeight)

    Column {
      id: cardColumn
      anchors.fill: parent
      spacing: Style.space(12)

      // Header
      Row {
        spacing: Style.space(10)
        width: parent.width

        Rectangle {
          width: Style.space(36)
          height: Style.space(36)
          radius: 8
          color: Style.normalFillFor(root.bar ? root.bar.foreground : Commons.Color.foreground, Commons.Color.accent)

          Text {
            anchors.centerIn: parent
            textFormat: Text.PlainText
            text: "󰌢"
            font.pixelSize: Style.font.title
            color: root.bar ? root.bar.foreground : Commons.Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
          }
        }

        Column {
          width: parent.width - Style.space(48)
          spacing: Style.space(2)

          Text {
            textFormat: Text.PlainText
            text: strings.t("popup.title")
            font.pixelSize: Style.font.subtitle
            font.bold: true
            color: root.bar ? root.bar.foreground : Commons.Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
          }

          Text {
            textFormat: Text.PlainText
            text: strings.t("popup.subtitle")
            font.pixelSize: Style.font.caption
            color: Qt.darker(root.bar ? root.bar.foreground : Commons.Color.foreground, 1.4)
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            elide: Text.ElideRight
            width: parent.width
          }
        }
      }

      PanelSeparator {
        foreground: root.bar ? root.bar.foreground : Commons.Color.foreground
      }

      // Width Control Section
      Column {
        width: parent.width
        spacing: Style.space(6)

        Row {
          width: parent.width
          Text {
            textFormat: Text.PlainText
            text: strings.t("popup.widthLabel").arg(Commons.I18n.formatNumber(root.liveWidth))
            font.pixelSize: Style.font.bodySmall
            font.bold: true
            color: root.bar ? root.bar.foreground : Commons.Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
          }
        }

        PanelSlider {
          width: parent.width
          bar: root.bar
          minimum: 60
          maximum: 360
          step: 2
          value: root.liveWidth
          onMoved: function(v) {
            root.liveWidth = Math.round(v)
          }
          onReleased: function(v) {
            root.liveWidth = Math.round(v)
            root.saveSettings()
          }
        }
      }

      // Presets Section
      Column {
        width: parent.width
        spacing: Style.space(6)

        PanelSectionHeader {
          text: strings.t("popup.presetsHeader")
          foreground: root.bar ? root.bar.foreground : Commons.Color.foreground
        }

        Grid {
          columns: 2
          spacing: Style.space(6)
          width: parent.width

          Ui.Button {
            width: (parent.width - Style.space(6)) / 2
            text: strings.t("popup.preset14")
            selected: root.liveWidth === 200
            onClicked: root.applyPreset(200)
          }

          Ui.Button {
            width: (parent.width - Style.space(6)) / 2
            text: strings.t("popup.preset16")
            selected: root.liveWidth === 230
            onClicked: root.applyPreset(230)
          }

          Ui.Button {
            width: (parent.width - Style.space(6)) / 2
            text: strings.t("popup.presetAir")
            selected: root.liveWidth === 180
            onClicked: root.applyPreset(180)
          }

          Ui.Button {
            width: (parent.width - Style.space(6)) / 2
            text: strings.t("popup.presetCompact")
            selected: root.liveWidth === 140
            onClicked: root.applyPreset(140)
          }
        }
      }

      // Options
      Column {
        width: parent.width
        spacing: Style.space(8)

        PanelSectionHeader {
          text: strings.t("popup.optionsHeader")
          foreground: root.bar ? root.bar.foreground : Commons.Color.foreground
        }

        // Option 1: Simulated Notch Pill
        Row {
          width: parent.width
          spacing: Style.space(8)

          Text {
            width: parent.width - Style.space(48)
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: strings.t("popup.blackPill")
            font.pixelSize: Style.font.bodySmall
            color: root.bar ? root.bar.foreground : Commons.Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
          }

          ToggleSwitch {
            anchors.verticalCenter: parent.verticalCenter
            checked: root.currentNotchStyle === "notch"
            onToggled: {
              root.currentNotchStyle = (root.currentNotchStyle === "notch" ? "spacer" : "notch")
              root.saveSettings()
            }
          }
        }

        // Option 2: Only on Laptop Screen
        Row {
          width: parent.width
          spacing: Style.space(8)

          Text {
            width: parent.width - Style.space(48)
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: strings.t("popup.onlyOnNotch")
            font.pixelSize: Style.font.bodySmall
            color: root.bar ? root.bar.foreground : Commons.Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
          }

          ToggleSwitch {
            anchors.verticalCenter: parent.verticalCenter
            checked: root.currentOnlyOnNotch
            onToggled: {
              root.currentOnlyOnNotch = !root.currentOnlyOnNotch
              root.saveSettings()
            }
          }
        }
      }

      PanelSeparator {
        foreground: root.bar ? root.bar.foreground : Commons.Color.foreground
      }

      // Detection & Status Footer
      Column {
        width: parent.width
        spacing: Style.space(4)

        Text {
          textFormat: Text.PlainText
          text: strings.t("popup.detectedScreen")
            .arg(root.screenName || "eDP-1")
            .arg(root.screenPixelWidth || 3024)
            .arg(root.screenPixelHeight || 1964)
            .arg(root.screenScale || 2)
          font.pixelSize: Style.font.caption
          color: Qt.darker(root.bar ? root.bar.foreground : Commons.Color.foreground, 1.5)
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          elide: Text.ElideRight
          width: parent.width
        }

        Row {
          spacing: Style.space(6)
          Text {
            textFormat: Text.PlainText
            text: "✓"
            font.bold: true
            font.pixelSize: Style.font.caption
            color: Commons.Color.accent
          }
          Text {
            textFormat: Text.PlainText
            text: strings.t("popup.statusProtected")
            font.pixelSize: Style.font.caption
            color: Qt.darker(root.bar ? root.bar.foreground : Commons.Color.foreground, 1.3)
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            elide: Text.ElideRight
            width: parent.width - Style.space(16)
          }
        }
      }
    }
  }
}
