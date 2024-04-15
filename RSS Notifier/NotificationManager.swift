//
//  NotificationManager.swift
//  RSS Notifier
//
//  Created by David DeGraw on 4/14/24.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager {
  static let shared = NotificationManager()
  
  func requestAuthorization() {
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
      if success {
        print("Authorization granted.")
      } else if let error = error {
        print("Authorization failed: \(error.localizedDescription)")
      }
    }
  }
  
  func sendNotification() {
    // Create the content of the notification
    let content = UNMutableNotificationContent()
    content.title = "Test Notifiwqrwerwcation"
    content.subtitle = "This is a test notification from SwiftUI."
    content.sound = UNNotificationSound.default
    
    // Create the trigger for the notification
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    // Create the request for the notification
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    // Add the request to the notification center
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("Error scheduling notification: \(error.localizedDescription)")
      }
    }
  }
}
