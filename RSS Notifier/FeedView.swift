//
//  FeedView.swift
//  RSS Notifier
//
//  Created by David DeGraw on 4/15/24.
//

import SwiftUI
import FeedKit
import UserNotifications

struct FeedView: View {
  var urlString: String
  @State private var feedTitle: String = "Loading feed..."
  @State private var feedItemTitle: String = ""
  @State private var validFeed: Bool = false
  
  var body: some View {
    VStack {
      Text(feedTitle).padding()
      Text(feedItemTitle).padding()
    }
    .onChange(of: urlString) { _, _ in
      loadFeed()
    }
    .onAppear() {
      loadFeed()
    }
    Button("Send Test Notification") {
      NotificationManager.shared.sendNotification(title: feedTitle, subtitle: feedItemTitle)
    }
    .padding()
    .disabled(!validFeed)
  }
  
  func loadFeed() {
    guard let url = URL(string: urlString) else {
      feedTitle = "Invalid URL"
      return
    }
    let parser = FeedParser(URL: url)
    parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let feed):
          updateUI(with: feed)
        case .failure(let error):
          feedTitle = "Error: \(error.localizedDescription)"
        }
      }
    }
  }
  
  func updateUI(with feed: Feed) {
    validFeed = true
    switch feed {
    case .atom(let atomFeed):
      let item = atomFeed.entries?.first
      feedTitle = decodeHTMLEntities(htmlEncodedString: atomFeed.title ?? "None")
      feedItemTitle = decodeHTMLEntities(htmlEncodedString: item?.title ?? "No Title")
    case .rss(let rssFeed):
      let item = rssFeed.items?.first
      feedTitle = decodeHTMLEntities(htmlEncodedString: rssFeed.title ?? "None")
      feedItemTitle = decodeHTMLEntities(htmlEncodedString: item?.title ?? "No Title")
    case .json:
      validFeed = false
      feedItemTitle = "WTF is a JSON feed?"
    }
  }
  
  func decodeHTMLEntities(htmlEncodedString: String) -> String {
    let entities = [
      ("&amp;", "&"),
      ("&lt;", "<"),
      ("&gt;", ">"),
      ("&quot;", "\""),
      ("&apos;", "'"),
      ("&#39;", "'")
    ]
    var decodedString = htmlEncodedString
    for (encoded, decoded) in entities {
      decodedString = decodedString.replacingOccurrences(of: encoded, with: decoded)
    }
    return decodedString
  }
}
