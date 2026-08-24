import SwiftUI

@main
struct PhoneKeyboardApp: App {
    @StateObject private var connection = PhoneConnection()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(connection)
        }
    }
}
