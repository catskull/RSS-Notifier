//
//  FeedManager.swift
//  RSS Notifier
//
//  Created by David DeGraw on 4/14/24.
//

import Foundation

// https://stackoverflow.com/a/72284727
struct FavIcon {
  enum Size: Int, CaseIterable { case s = 16, m = 32, l = 64, xl = 128, xxl = 256, xxxl = 512 }
  private let domain: String
  init(_ domain: String) { self.domain = domain }
  subscript(_ size: Size) -> String {
    "https://www.google.com/s2/favicons?sz=\(size.rawValue)&domain=\(domain)"
  }
}

class FeedManager {
  var url: URL
  var isValid: Bool = false
  var data: Data?
  
  init(urlString: String) {
    self.url = URL(string: urlString)!
    validateURL()
  }
  
  private func validateURL() {
    // Perform basic URL checks (synchronously)
    guard let scheme = url.scheme, (scheme == "http" || scheme == "https") else {
      self.isValid = false
      return
    }
    
    // Lowercase the path to ensure case-insensitive comparison
    let pathLowercased = url.path.lowercased()
    if pathLowercased.hasSuffix(".rss") || pathLowercased.hasSuffix(".xml") || pathLowercased.hasSuffix(".atom") {
      self.isValid = true
    } else {
      self.isValid = false
    }
  }
  func fetchFeed() async -> Bool {
    guard isValid else { return false }
    
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        return false
      }
      self.data = data
      return true
    } catch {
      print("Network request failed: \(error)")
      return false
    }
  }
  
//  func parseFeed() -> [FeedItem]? {
//    guard let data = data else { return nil }
//    // Implement parsing logic here, depending on the format of the feed
//    return []
//  }
}

