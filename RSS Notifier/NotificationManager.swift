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
  
  func sendNotification(title: String = "Default Title", subtitle: String = "Default subtitle.", shouldPlaySound: Bool = false) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.subtitle = subtitle
    content.sound = shouldPlaySound ? UNNotificationSound.default : nil
    
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
