import Carbon
import Foundation

func switchToEnglish() {
    guard let sources = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource]
    else { return }
    for source in sources {
        guard let idRef = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { continue }
        let id = Unmanaged<CFString>.fromOpaque(idRef).takeUnretainedValue() as String
        if id == "com.apple.keylayout.ABC" {
            TISSelectInputSource(source)
            break
        }
    }
}

// Subcommand: switch to English and exit
if CommandLine.arguments.count > 1 && CommandLine.arguments[1] == "switch-english" {
    switchToEnglish()
    exit(0)
}

func updateTmuxStatus() {
    guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
          let idRef = TISGetInputSourceProperty(source, kTISPropertyInputSourceID),
          let id = Unmanaged<CFString>.fromOpaque(idRef).takeUnretainedValue() as String?
    else { return }

    let isKorean = id.contains("Korean") || id.contains("han")

    let style = isKorean
        ? "bg=colour214,fg=colour0"
        : "bg=green,fg=black"
    let tmux = "/opt/homebrew/bin/tmux"

    let borderFg = isKorean ? "colour214" : "brightgreen"
    let c1 = isKorean ? "colour214" : "green"       // segment 1 (index)
    let c2 = isKorean ? "colour130" : "colour22"    // segment 2 (path)
    let c3 = "colour238"                              // segment 3 (cmd)

    let setStyle = Process()
    setStyle.executableURL = URL(fileURLWithPath: tmux)
    setStyle.arguments = ["set", "-g", "status-style", style]
    try? setStyle.run()

    let setBorder = Process()
    setBorder.executableURL = URL(fileURLWithPath: tmux)
    setBorder.arguments = ["set", "-g", "pane-active-border-style", "fg=\(borderFg)"]
    try? setBorder.run()

    // Powerline segment style with Nerd Font icons
    let pw = "\u{E0B0}"       //
    let iIdx = "\u{F489}"     //  (terminal)
    let iDir = "\u{F07B}"     //  (folder)
    let iCmd = "\u{F427}"     //  (command)
    let borderFormat = "#{?pane_active,"
        + "#[bg=\(c1) fg=black] \(iIdx) #{pane_index} "
        + "#[bg=\(c2) fg=\(c1) nobold]\(pw)"
        + "#[fg=white] \(iDir) #{pane_current_path} "
        + "#[bg=\(c3) fg=\(c2)]\(pw)"
        + "#[fg=white] \(iCmd) #{pane_current_command} "
        + "#[bg=default fg=\(c3)]\(pw)#[default]"
        + ",}"
    let setBorderFormat = Process()
    setBorderFormat.executableURL = URL(fileURLWithPath: tmux)
    setBorderFormat.arguments = ["set", "-g", "pane-border-format", borderFormat]
    try? setBorderFormat.run()

    // Use /bin/sh + printf to pass NFC bytes directly,
    // bypassing Foundation's NFD normalization of Korean characters
    let label = isKorean ? "$(printf '\\xed\\x95\\x9c')" : "EN"
    let setVar = Process()
    setVar.executableURL = URL(fileURLWithPath: "/bin/sh")
    setVar.arguments = ["-c", "\(tmux) set -g @im-status \"\(label)\""]
    try? setVar.run()
}

let callback: CFNotificationCallback = { _, _, _, _, _ in
    updateTmuxStatus()
}

CFNotificationCenterAddObserver(
    CFNotificationCenterGetDistributedCenter(),
    nil,
    callback,
    "com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged" as CFString,
    nil,
    .deliverImmediately
)

// Set initial state
updateTmuxStatus()

RunLoop.main.run()
