import Foundation

enum RemoteModifier: String, Codable, CaseIterable {
    case command, option, control, shift
}

enum RemoteKey: String, Codable {
    case delete, returnKey, tab, escape, left, right, up, down, space
}

enum RemoteMessage: Codable {
    case text(String, modifiers: Set<RemoteModifier>)
    case key(RemoteKey, modifiers: Set<RemoteModifier>)
}
