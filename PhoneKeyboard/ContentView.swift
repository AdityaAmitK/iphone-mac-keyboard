import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var connection: PhoneConnection
    @State private var modifiers: Set<RemoteModifier> = []
    @State private var locked: Set<RemoteModifier> = []

    var body: some View {
        NavigationStack {
            Group {
                if connection.connectedMac == nil { deviceList } else { keyboard }
            }
            .navigationTitle("Mac Keyboard")
        }
    }

    private var deviceList: some View {
        List {
            Section { Text(connection.status).foregroundStyle(.secondary) }
            Section("Available Macs") {
                ForEach(connection.macs, id: \.self) { mac in
                    Button(mac.displayName) { connection.connect(to: mac) }
                }
            }
        }
    }

    private var keyboard: some View {
        VStack(spacing: 16) {
            Text(connection.status).font(.subheadline).foregroundStyle(.green)
            KeyboardInput(onText: sendText, onDelete: { send(.key(.delete, modifiers: modifiers)) })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 18))
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "keyboard").font(.system(size: 44))
                        Text("Tap here, then type").font(.headline)
                    }.foregroundStyle(.secondary).allowsHitTesting(false)
                }

            HStack {
                modifierButton("⌃", .control)
                modifierButton("⌥", .option)
                modifierButton("⇧", .shift)
                modifierButton("⌘", .command)
            }
            HStack {
                keyButton("esc", .escape)
                keyButton("tab", .tab)
                keyButton("↵", .returnKey)
                keyButton("⌫", .delete)
            }
            HStack {
                keyButton("←", .left); keyButton("↓", .down)
                keyButton("↑", .up); keyButton("→", .right)
            }
            Button("Disconnect", role: .destructive) { connection.disconnect() }
        }
        .padding()
    }

    private func modifierButton(_ title: String, _ modifier: RemoteModifier) -> some View {
        Button(title) {
            if locked.contains(modifier) {
                locked.remove(modifier); modifiers.remove(modifier)
            } else if modifiers.contains(modifier) {
                locked.insert(modifier)
            } else {
                modifiers.insert(modifier)
            }
        }
        .buttonStyle(KeyButtonStyle(active: modifiers.contains(modifier)))
        .accessibilityLabel("\(modifier.rawValue), double tap to lock")
    }

    private func keyButton(_ title: String, _ key: RemoteKey) -> some View {
        Button(title) { send(.key(key, modifiers: modifiers)) }
            .buttonStyle(KeyButtonStyle())
    }

    private func sendText(_ text: String) { send(.text(text, modifiers: modifiers)) }
    private func send(_ message: RemoteMessage) {
        connection.send(message)
        modifiers = modifiers.intersection(locked)
    }
}

private struct KeyButtonStyle: ButtonStyle {
    var active = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 44)
            .background(active ? Color.accentColor : Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(active ? .white : .primary).opacity(configuration.isPressed ? 0.6 : 1)
    }
}
