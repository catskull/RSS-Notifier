import Foundation

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
