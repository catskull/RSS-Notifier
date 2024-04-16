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

