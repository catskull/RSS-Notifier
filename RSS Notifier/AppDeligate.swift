//
//  AppDeligate.swift
//  RSS Notifier
//
//  Created by David DeGraw on 4/15/24.
//

import Foundation
import UserNotifications
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    // Set up notifications on launch
    setupNotifications()
  }
  
  func setupNotifications() {
    // Request notification permissions
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if granted {
        print("Notification permission granted.")
      } else if let error = error {
        print("Notification permission error: \(error.localizedDescription)")
      }
    }
    // Correctly set the delegate
    UNUserNotificationCenter.current().delegate = self
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Handle foreground notification
    completionHandler([.banner, .sound])
  }
}

