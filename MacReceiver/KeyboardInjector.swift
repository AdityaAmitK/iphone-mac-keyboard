import AppKit
import ApplicationServices

enum KeyboardInjector {
    static func requestAccess() {
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    static func send(_ message: RemoteMessage) {
        guard AXIsProcessTrusted() else {
            receiverLog.error("Input blocked: accessibility permission is not active")
            return
        }
        receiverLog.info("Posting keyboard event")
        switch message {
        case let .text(text, modifiers):
            if text.count == 1, !modifiers.isEmpty, let keyCode = keyCodes[text.lowercased()] {
                post(keyCode, modifiers: modifiers)
            } else {
                post(text, modifiers: modifiers)
            }
        case let .key(key, modifiers):
            post(specialKeys[key]!, modifiers: modifiers)
        }
    }

    private static func post(_ text: String, modifiers: Set<RemoteModifier>) {
        let source = CGEventSource(stateID: .hidSystemState)
        let down = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
        var utf16 = Array(text.utf16)
        down?.keyboardSetUnicodeString(stringLength: utf16.count, unicodeString: &utf16)
        down?.flags = flags(modifiers)
        down?.post(tap: .cghidEventTap)
        let up = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
        up?.flags = flags(modifiers)
        up?.post(tap: .cghidEventTap)
    }

    private static func post(_ keyCode: CGKeyCode, modifiers: Set<RemoteModifier>) {
        let source = CGEventSource(stateID: .hidSystemState)
        for isDown in [true, false] {
            let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: isDown)
            event?.flags = flags(modifiers)
            event?.post(tap: .cghidEventTap)
        }
    }

    private static func flags(_ modifiers: Set<RemoteModifier>) -> CGEventFlags {
        modifiers.reduce(into: CGEventFlags()) { result, modifier in
            let flag: CGEventFlags = switch modifier {
            case .command: .maskCommand
            case .option: .maskAlternate
            case .control: .maskControl
            case .shift: .maskShift
            }
            result.insert(flag)
        }
    }

    private static let specialKeys: [RemoteKey: CGKeyCode] = [
        .delete: 51, .returnKey: 36, .tab: 48, .escape: 53,
        .left: 123, .right: 124, .down: 125, .up: 126, .space: 49
    ]

    private static let keyCodes: [String: CGKeyCode] = [
        "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7,
        "c": 8, "v": 9, "b": 11, "q": 12, "w": 13, "e": 14, "r": 15,
        "y": 16, "t": 17, "1": 18, "2": 19, "3": 20, "4": 21, "6": 22,
        "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29,
        "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35, "l": 37,
        "j": 38, "'": 39, "k": 40, ";": 41, "\\": 42, ",": 43, "/": 44,
        "n": 45, "m": 46, ".": 47, "`": 50
    ]
}
