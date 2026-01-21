//
//  NotificationService.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation
import UserNotifications

// MARK: - Notification Service
@MainActor
final class NotificationService {
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Request Permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    // MARK: - Check Permission Status
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Schedule Daily Quote Notification
    func scheduleDailyQuoteNotification(at time: Date, quote: String, author: String) async {
        // Remove existing daily quote notifications
        center.removePendingNotificationRequests(
            withIdentifiers: [Constants.Notifications.dailyQuoteIdentifier]
        )
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "✨ Your Daily Inspiration"
        content.body = "\"\(quote)\" — \(author)"
        content.sound = .default
        content.categoryIdentifier = "DAILY_QUOTE"
        
        // Create trigger for specified time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: Constants.Notifications.dailyQuoteIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        do {
            try await center.add(request)
            print("Daily quote notification scheduled for \(components.hour ?? 8):\(components.minute ?? 30)")
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    // MARK: - Cancel Daily Quote Notification
    func cancelDailyQuoteNotification() {
        center.removePendingNotificationRequests(
            withIdentifiers: [Constants.Notifications.dailyQuoteIdentifier]
        )
    }
    
    // MARK: - Update Notification Time
    func updateNotificationTime(to time: Date, quote: String, author: String) async {
        await scheduleDailyQuoteNotification(at: time, quote: quote, author: author)
    }
}
