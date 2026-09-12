import SwiftUI

@main
struct PortwayApp: App {
    @State private var store = BottleStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
        .windowResizability(.contentSize)
    }
}
