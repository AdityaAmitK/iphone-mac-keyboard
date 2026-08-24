import SwiftUI

@main
struct MacReceiverApp: App {
    @StateObject private var receiver = MacReceiver()

    var body: some Scene {
        MenuBarExtra("Phone Keyboard", systemImage: receiver.connectedPeer == nil ? "iphone.slash" : "iphone.and.arrow.forward.inward") {
            Text(receiver.status)
            Divider()
            Button("Request Accessibility Access") { KeyboardInjector.requestAccess() }
            if receiver.connectedPeer != nil {
                Button("Disconnect") { receiver.disconnect() }
            }
            Divider()
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }
    }
}
