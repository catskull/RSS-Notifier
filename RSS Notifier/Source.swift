import Foundation

struct Source: Identifiable, Codable, Hashable {
  let id: String
  let url: URL
  var urlString: String { url.absoluteString }
  
  enum CodingKeys: String, CodingKey {
    case url
    case id
  }
  
  init?(url: String, id: String = UUID().uuidString) {
    guard let url = URL(string: url) else {
      return nil
    }
    self.id = id
    self.url = url
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let urlString = try container.decode(String.self, forKey: .url)
    let id = try container.decode(String.self, forKey: .id)
    guard let url = URL(string: urlString) else {
      throw DecodingError.dataCorruptedError(forKey: .url, in: container, debugDescription: "Invalid URL format.")
    }
    self.id = id
    self.url = url
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(url.absoluteString, forKey: .url)
    try container.encode(id, forKey: .id)
  }
}
