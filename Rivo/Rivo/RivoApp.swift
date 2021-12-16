

import SwiftUI

@main
struct RivoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            MenuCommands()
        }
    }
}
