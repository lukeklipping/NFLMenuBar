import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        MenuBarExtra("My util", systemImage: "bolt"){
            Button("refresh"){
                print("refreshed")
            }
            Divider()
            Button("Quit"){
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
