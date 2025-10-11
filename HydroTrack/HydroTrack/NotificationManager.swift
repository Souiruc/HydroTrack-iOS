//
//  NotificationManager.swift
//  HydroTrack
//
//  Created by Batuhan Aydin on 9/24/25.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    @Published var hasPermission = false
    
    // AI Learning Data
    @Published var userDrinkingPattern: [DrinkingSession] = []
    @Published var optimalReminderTimes: [Int] = [9, 13, 17] // Start with 3 smart times
    @Published var lastWaterLogTime: Date = Date()
    @Published var averageGapBetweenDrinks: TimeInterval = 3 * 3600 // 3 hours default
    
    init() {
        checkPermission()
        loadUserPatterns()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.hasPermission = granted
                if granted {
                    self.scheduleWaterReminders()
                }
            }
        }
    }
    
    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleWaterReminders() {
        // Clear existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule 8PM daily completion check
        scheduleDailyCompletionCheck()
        
        // Schedule AI-powered adaptive reminders
        scheduleAdaptiveReminders()
    }
    
    private func scheduleDailyCompletionCheck() {
        let content = UNMutableNotificationContent()
        content.title = getPersonalizedTitle(for: .dailyCheck)
        content.body = getPersonalizedMessage(for: .dailyCheck)
        content.sound = .default
        
        // 8PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-completion-check", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleAdaptiveReminders() {
        // Use AI-learned optimal times instead of fixed schedule
        for hour in optimalReminderTimes {
            let content = UNMutableNotificationContent()
            content.title = getPersonalizedTitle(for: .adaptiveReminder)
            content.body = getPersonalizedMessage(for: .adaptiveReminder)
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = Int.random(in: 0...30) // Randomize minutes for natural feel
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "adaptive-reminder-\(hour)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - AI Learning Functions
    
    func logWaterIntake(amount: Int) {
        let session = DrinkingSession(
            timestamp: Date(),
            amount: amount,
            timeSinceLastDrink: Date().timeIntervalSince(lastWaterLogTime)
        )
        
        userDrinkingPattern.append(session)
        lastWaterLogTime = Date()
        
        // Learn from this session
        updateAILearning()
        
        // Reschedule reminders based on new learning
        if hasPermission {
            scheduleWaterReminders()
        }
    }
    
    private func updateAILearning() {
        // Analyze drinking patterns to optimize reminder times
        analyzeOptimalReminderTimes()
        analyzeAverageGaps()
        
        // Save learned patterns
        saveUserPatterns()
    }
    
    private func analyzeOptimalReminderTimes() {
        guard userDrinkingPattern.count >= 10 else { return } // Need enough data
        
        // Find hours when user typically drinks
        let drinkingHours = userDrinkingPattern.map { session in
            Calendar.current.component(.hour, from: session.timestamp)
        }
        
        // Find most common drinking times and set reminders 1-2 hours before
        let hourFrequency = Dictionary(grouping: drinkingHours, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        // Take top 3 most common hours and set reminders before them
        optimalReminderTimes = Array(hourFrequency.prefix(3).map { max($0.key - 1, 8) })
    }
    
    private func analyzeAverageGaps() {
        guard userDrinkingPattern.count >= 5 else { return }
        
        let gaps = userDrinkingPattern.compactMap { $0.timeSinceLastDrink }
        averageGapBetweenDrinks = gaps.reduce(0, +) / Double(gaps.count)
    }
    
    // MARK: - Personalized Messages
    
    private func getPersonalizedTitle(for type: NotificationType) -> String {
        let titles: [NotificationType: [String]] = [
            .dailyCheck: [
                "💧 Evening Hydration Check",
                "🌊 How's Your Water Journey?",
                "💙 Daily Wellness Check"
            ],
            .adaptiveReminder: [
                "💧 Gentle Reminder",
                "🌊 Hydration Moment",
                "💙 Time for Self-Care",
                "🌿 Wellness Break"
            ]
        ]
        
        return titles[type]?.randomElement() ?? "💧 HydroTrack"
    }
    
    private func getPersonalizedMessage(for type: NotificationType) -> String {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        switch type {
        case .dailyCheck:
            return [
                "How did your hydration go today? Every sip counts! 🌊",
                "Reflecting on today's water journey. You're doing great! 💙",
                "Time to celebrate your hydration wins today! ✨"
            ].randomElement() ?? "Check your daily progress!"
            
        case .adaptiveReminder:
            if currentHour < 12 {
                return [
                    "Good morning! Start your day with some refreshing water 🌅",
                    "Morning hydration sets the tone for a great day! ☀️",
                    "Your body is ready for some morning refreshment 💧"
                ].randomElement() ?? "Morning hydration time!"
            } else if currentHour < 17 {
                return [
                    "Afternoon energy boost: time for some water! ⚡",
                    "Keep your momentum going with a hydration break 🌊",
                    "Your afternoon self will thank you for this water break 💙"
                ].randomElement() ?? "Afternoon hydration break!"
            } else {
                return [
                    "Evening wind-down with some gentle hydration 🌙",
                    "End your day on a healthy note with some water 🌟",
                    "Evening self-care: time for hydration 💫"
                ].randomElement() ?? "Evening hydration time!"
            }
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveUserPatterns() {
        // Save to UserDefaults for now (will move to backend later)
        if let encoded = try? JSONEncoder().encode(userDrinkingPattern) {
            UserDefaults.standard.set(encoded, forKey: "userDrinkingPattern")
        }
        UserDefaults.standard.set(optimalReminderTimes, forKey: "optimalReminderTimes")
        UserDefaults.standard.set(averageGapBetweenDrinks, forKey: "averageGapBetweenDrinks")
    }
    
    private func loadUserPatterns() {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "userDrinkingPattern"),
           let patterns = try? JSONDecoder().decode([DrinkingSession].self, from: data) {
            userDrinkingPattern = patterns
        }
        
        if let times = UserDefaults.standard.array(forKey: "optimalReminderTimes") as? [Int] {
            optimalReminderTimes = times
        }
        
        averageGapBetweenDrinks = UserDefaults.standard.double(forKey: "averageGapBetweenDrinks")
        if averageGapBetweenDrinks == 0 {
            averageGapBetweenDrinks = 3 * 3600 // Default 3 hours
        }
    }
}

// MARK: - Supporting Models

struct DrinkingSession: Codable {
    let timestamp: Date
    let amount: Int
    let timeSinceLastDrink: TimeInterval
}

enum NotificationType {
    case dailyCheck
    case adaptiveReminder
}