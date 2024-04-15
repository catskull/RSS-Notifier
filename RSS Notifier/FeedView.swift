//
//  FeedView.swift
//  RSS Notifier
//
//  Created by David DeGraw on 4/15/24.
//

import SwiftUI
import FeedKit

struct FeedView: View {
  var urlString: String
  @State private var feedTitle: String = "Loading feed..."
  @State private var feedType: String = ""
  @State private var feedSummary: String = ""
  
  var body: some View {
    VStack {
      Text(feedTitle).padding()
      Text(feedType).padding()
    }
    .onChange(of: urlString) { _, _ in
      loadFeed()
    }
  }
  
  func loadFeed() {
    print(urlString)
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
    switch feed {
    case .atom(let atomFeed):
      let item = atomFeed.entries?.first
      feedType = item?.id ?? "No ID"
      feedTitle = item?.title ?? "No Title"
    case .rss(let rssFeed):
      let item = rssFeed.items?.first
      feedType = item?.guid?.value ?? "No ID"
      feedTitle = item?.title ?? "No Title"
    case .json(let jsonFeed):
      feedType = "JSON"
      feedTitle = jsonFeed.title ?? "No Title"
    }
  }
}
