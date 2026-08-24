import AppKit
import MultipeerConnectivity
import OSLog

let receiverLog = Logger(subsystem: "com.adityaamit.iphone-mac-keyboard.mac", category: "receiver")

@MainActor
final class MacReceiver: NSObject, ObservableObject {
    @Published private(set) var connectedPeer: MCPeerID?
    @Published private(set) var status = "Ready for iPhone"

    private let peer = MCPeerID(displayName: Host.current().localizedName ?? "Mac")
    private lazy var session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .required)
    private lazy var advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "iphone-mac-kb")

    override init() {
        super.init()
        session.delegate = self
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        KeyboardInjector.requestAccess()
    }

    func disconnect() { session.disconnect() }
}

extension MacReceiver: MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        Task { @MainActor in
            guard connectedPeer == nil else { invitationHandler(false, nil); return }
            let alert = NSAlert()
            alert.messageText = "Connect \(peerID.displayName)?"
            alert.informativeText = "This device will be able to type in the currently focused app."
            alert.addButton(withTitle: "Connect")
            alert.addButton(withTitle: "Reject")
            NSApp.activate(ignoringOtherApps: true)
            invitationHandler(alert.runModal() == .alertFirstButtonReturn, session)
        }
    }

    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        receiverLog.info("Peer \(peerID.displayName, privacy: .public) state \(state.rawValue)")
        Task { @MainActor in
            connectedPeer = state == .connected ? peerID : nil
            status = state == .connected ? "Connected to \(peerID.displayName)" : "Ready for iPhone"
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(RemoteMessage.self, from: data) else {
            receiverLog.error("Could not decode \(data.count) bytes")
            return
        }
        receiverLog.info("Received input from \(peerID.displayName, privacy: .public)")
        KeyboardInjector.send(message)
    }

    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
