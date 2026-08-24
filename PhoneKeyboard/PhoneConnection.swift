import Foundation
import MultipeerConnectivity

@MainActor
final class PhoneConnection: NSObject, ObservableObject {
    @Published private(set) var macs: [MCPeerID] = []
    @Published private(set) var connectedMac: MCPeerID?
    @Published var status = "Looking for your Mac…"

    private let peer = MCPeerID(displayName: UIDevice.current.name)
    private lazy var session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .required)
    private lazy var browser = MCNearbyServiceBrowser(peer: peer, serviceType: "iphone-mac-kb")

    override init() {
        super.init()
        session.delegate = self
        browser.delegate = self
        browser.startBrowsingForPeers()
    }

    func connect(to mac: MCPeerID) {
        status = "Waiting for approval on \(mac.displayName)…"
        browser.invitePeer(mac, to: session, withContext: nil, timeout: 30)
    }

    func disconnect() { session.disconnect() }

    func send(_ message: RemoteMessage) {
        guard !session.connectedPeers.isEmpty,
              let data = try? JSONEncoder().encode(message) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}

extension PhoneConnection: MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        Task { @MainActor in
            if !macs.contains(peerID) { macs.append(peerID) }
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in macs.removeAll { $0 == peerID } }
    }

    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            connectedMac = state == .connected ? peerID : nil
            status = switch state {
            case .connected: "Connected to \(peerID.displayName)"
            case .connecting: "Connecting…"
            case .notConnected: "Looking for your Mac…"
            @unknown default: "Connection changed"
            }
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
