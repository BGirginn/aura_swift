//
//  NotificationManager.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        center.delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func updateDailyReminder(enabled: Bool) {
        if enabled {
            scheduleDailyReminder()
        } else {
            cancelReminders()
        }
    }
    
    func scheduleDailyReminder(hour: Int = 10, minute: Int = 0) {
        cancelReminders()
        
        let content = UNMutableNotificationContent()
        content.title = "Check Your Aura"
        content.body = "Open Aura to discover today’s colors and insights."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_aura_reminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("🔔 Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelReminders() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_aura_reminder"])
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}


