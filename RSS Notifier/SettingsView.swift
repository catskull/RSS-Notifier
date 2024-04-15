import SwiftUI

struct SettingsView: View {
  private enum Tabs: Hashable {
    case general, advanced
  }
  
  var body: some View {
    TabView {
      GeneralView()
        .tabItem {
          Label("URLs", systemImage: "dot.radiowaves.up.forward")
        }
        .tag(Tabs.general)
      AdvancedView()
        .tabItem {
          Label("About", systemImage: "info.circle")
        }
        .tag(Tabs.advanced)
    }
    .padding(20)
  }
}
