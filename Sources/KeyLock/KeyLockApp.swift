import SwiftUI

@main
struct KeyLockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var locker = KeyboardLocker()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locker)
                .frame(width: 320, height: 440)
                .background(WindowConfigurator())
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

/// Hides the title bar so the whole window reads as one surface.
struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert(.fullSizeContentView)
            window.styleMask.remove(.resizable)
            window.isMovableByWindowBackground = true
            window.backgroundColor = .clear
            window.isOpaque = false
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
