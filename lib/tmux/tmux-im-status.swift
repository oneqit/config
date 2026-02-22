import Carbon
import Foundation

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

    let setStyle = Process()
    setStyle.executableURL = URL(fileURLWithPath: tmux)
    setStyle.arguments = ["set", "-g", "status-style", style]
    try? setStyle.run()

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
