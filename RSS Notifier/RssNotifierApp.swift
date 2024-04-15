import SwiftUI
import AppKit

@main
struct RSSNotifierApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  @Environment(\.openWindow) private var openWindow
  @State var currentNumber: String = "1"
  
  var body: some Scene {
    WindowGroup(id: "config-viewer") {
      SettingsView()
    }
    MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
      Button("Open Config...") {
        openWindow(id: "config-viewer")
      }
      .keyboardShortcut("c")
      Divider()
      Button("Quit") {
        NSApplication.shared.terminate(nil)
      }.keyboardShortcut("q")
    }
  }
}
