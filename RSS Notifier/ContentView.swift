import SwiftUI
import AppKit
import UserNotifications

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
  
  private struct GeneralView: View {
    struct Source: Identifiable, Hashable {
      let url: URL
      var id: String { url.absoluteString }
      var valid: Bool
      
      init?(url: String) {
        guard let url = URL(string: url) else {
          return nil
        }
        self.url = url
        self.valid = Source.isValidURL(url)
      }
      
      private static func isValidURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme, scheme == "http" || scheme == "https" else {
          return false
        }
        
        if !url.path.hasSuffix(".rss") && !url.path.hasSuffix(".xml") && !url.path.hasSuffix(".atom") {
          return false
        }
        
        return true
      }
    }

    
    @AppStorage("URLs") private var urlsString = "https://catskull.net/feed.xml"
    @State private var isAddingURL = false
    @State private var isShowingConfirmation = false
    @State private var newURLString = ""
    @State private var multiSelection = Set<String>()
    @State private var currentURLs: Set<Source>? = Set()
    
    private var sources: [Source] {
      urlsString.split(separator: ",").compactMap { substring in
        Source(url: String(substring))
      }
    }
    
    private func urlSheet() -> some View {
      VStack {
        Text("Enter RSS feed URL")
          .font(.headline)
          .padding()
        
        TextField("URL", text: $newURLString)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()
          .textContentType(.URL)
          .disableAutocorrection(true)
        
        Button("Add") {
          if let url = URL(string: newURLString),
            let newSource = Source(url: url.absoluteString) {
            var currentUrls = self.sources
            currentUrls.append(newSource)
            
            // Convert each URL to a string and then join them into a single string
            self.urlsString = currentUrls.map { $0.url.absoluteString }.joined(separator: ",")
            newURLString = "" // Clear the text field after adding
            isAddingURL = false
          }
        }
        .disabled(!(Source(url: newURLString)?.valid ?? false))
        .padding()
        
        Spacer() // Pushes the content to the top
      }
      .frame(minWidth: 600, minHeight: 400) // Example sizes
      .padding()
    }

    private func removeSelectedURLs() {
      guard !multiSelection.isEmpty else { return }
      
      let currentUrls = self.sources.filter { !multiSelection.contains($0.url.absoluteString) }
      
      self.urlsString = currentUrls.map { $0.url.absoluteString }.joined(separator: ",")
      multiSelection = []
    }
    
    var body: some View {
      VStack(spacing: 0) {
        HStack {
          Text("Feed URLs")
          Spacer()
        }
        .padding(.leading, 5)
        .frame(height: 25)
        .background(Color.gray.opacity(0.1))
        .clipShape(.rect(
          topLeadingRadius: 0,
          bottomLeadingRadius: 5,
          bottomTrailingRadius: 5,
          topTrailingRadius: 0
        ))
        .overlay(
          UnevenRoundedRectangle(
            topLeadingRadius: 5,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 5
          ).stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        List(sources, selection: $multiSelection) { source in
          HStack {
            // Using AsyncImage to load the favicon
            if let host = source.url.host {
              AsyncImage(url: URL(string: FavIcon(host)[FavIcon.Size.m])) { image in
                image
                  .resizable()
                  .scaledToFit()
                  .frame(width: 12, height: 12) // Set the size of the favicon
              } placeholder: {
                ProgressView() // Show a progress indicator while loading
                  .frame(width: 12, height: 12)
              }
            }
            Text(source.url.absoluteString)
              .lineLimit(1) // Ensures the text does not wrap
          }
          .background(multiSelection.contains(source.id) ? Color.accentColor.opacity(0.3) : Color.clear)
        }
        .overlay(
          Rectangle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        Button("Send Test Notification") {
          NotificationManager.shared.sendNotification()
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(10)
        HStack(spacing: 0) {
          Button(action: {isAddingURL = true}) {
            Image(systemName: "plus")
            .frame(width: 20, height: 20)
            .contentShape(Rectangle())  // Make the entire padded area tappable
          }.buttonStyle(.borderless)
            .padding(0)
          Divider()
            .padding(.horizontal, 5)
          Button(action: {
            if multiSelection.count > 1 {
              isShowingConfirmation = true  // Assuming isShowingConfirmation is a @State variable
            } else {
              removeSelectedURLs()
            }
          }) {
            Image(systemName: "minus")
              .frame(width: 20, height: 20)
              .contentShape(Rectangle())  // Make the entire padded area tappable
          }
          .buttonStyle(.borderless)
          .disabled(multiSelection.isEmpty)
          .padding(0)
          Spacer()
        }
        .padding(.leading, 5)
        .frame(height: 10)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        
        .clipShape(.rect(
          topLeadingRadius: 0,
          bottomLeadingRadius: 5,
          bottomTrailingRadius: 5,
          topTrailingRadius: 0
        ))
        .overlay(
          UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 5,
            bottomTrailingRadius: 5,
            topTrailingRadius: 0
          ).stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .sheet(isPresented: $isAddingURL, content: { urlSheet() })
        .confirmationDialog("Confirm Deletion", isPresented: $isShowingConfirmation) {
          Button("Delete", role: .destructive) {
            removeSelectedURLs()
          }
          Button("Cancel", role: .cancel) {}
        } message: {
          Text("Delete \(multiSelection.count) URLs?")
        } .dialogIcon(Image(systemName: "trash"))
      }
      .padding(.vertical, 10)
    }
  }

  
  private struct AdvancedView: View {
    var body: some View {
      Text("hello advanced")
    }
  }
}

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
