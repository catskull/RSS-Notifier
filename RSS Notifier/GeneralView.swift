import SwiftUI
import FeedKit

struct GeneralView: View {
  @AppStorage("URLs") private var urlsJsonString: String = "[{\"url\":\"https://catskull.net/feed.xml\"}]"
  @State private var isAddingURL = false
  @State private var isShowingConfirmation = false
  @State private var newURLString = ""
  @State private var multiSelection = Set<String>()
  @State private var currentURLs: Set<Source>? = Set()
  
  private var sources: [Source] {
    decodeSources()
  }
  
  private func decodeSources() -> [Source] {
    guard let data = urlsJsonString.data(using: .utf8) else {
      return []
    }
    return (try? JSONDecoder().decode([Source].self, from: data)) ?? []
  }
  
  private func encodeSources(_ sources: [Source]) {
    let data = try? JSONEncoder().encode(sources)
    urlsJsonString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
  }
  
  private func addNewSource() {
    guard let newSource = Source(url: newURLString) else {
      print("Invalid URL")
      return
    }
    var updatedSources = decodeSources()
    updatedSources.append(newSource)
    encodeSources(updatedSources)
    print(urlsJsonString)
    newURLString = ""
    isAddingURL = false
  }
  
  private func removeSelectedURLs() {
    let updatedSources = decodeSources().filter { !multiSelection.contains($0.id) }
    encodeSources(updatedSources)
    multiSelection = []
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
      
      FeedView(urlString: newURLString)
      
      Button("Add") {
        addNewSource()
      }
      .disabled(false)
      .padding()
      
      Spacer() // Pushes the content to the top
    }
    .frame(minWidth: 600, minHeight: 400) // Example sizes
    .padding()
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
            isShowingConfirmation = true
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
