//
//  DataManager.swift
//  HydroTrack
//
//  Created by Batuhan Aydin on 9/24/25.
//

import Foundation

class DataManager: ObservableObject {
    // MARK: - Published Properties
    @Published var todayIntake: Int = 0
    @Published var dailyGoal: Int = 2250
    @Published var lastResetDate: Date = Date()
    
    // Settings
    @Published var partnerConnected: Bool = false
    @Published var partnerName: String = ""
    @Published var defaultMessage: String = "You still have {volume}ml left to reach your daily goal. Keep hydrating!"
    @Published var partnerMessage: String = "My love, you still have {volume}ml of water you need to drink. Please complete it while knowing that I love you."
    
    // Daily history for analytics
    @Published var dailyHistory: [DailyRecord] = []
    
    init() {
        loadAllData()
        checkForNewDay()
    }
    
    // MARK: - Water Logging
    
    func logWater(_ amount: Int) {
        todayIntake += amount
        saveWaterData()
        
        // Update today's record
        updateTodayRecord()
    }
    
    func resetDailyProgress() {
        // Save yesterday's final total before resetting
        saveDailyRecord()
        
        todayIntake = 0
        lastResetDate = Date()
        saveWaterData()
    }
    
    // MARK: - Settings Management
    
    func updateDailyGoal(_ newGoal: Int) {
        dailyGoal = newGoal
        saveSettings()
    }
    
    func updatePartnerSettings(connected: Bool, name: String) {
        partnerConnected = connected
        partnerName = name
        saveSettings()
    }
    
    func updateMessages(default: String, partner: String) {
        defaultMessage = `default`
        partnerMessage = partner
        saveSettings()
    }
    
    // MARK: - Data Persistence
    
    private func saveWaterData() {
        UserDefaults.standard.set(todayIntake, forKey: "todayIntake")
        UserDefaults.standard.set(lastResetDate, forKey: "lastResetDate")
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
        UserDefaults.standard.set(partnerConnected, forKey: "partnerConnected")
        UserDefaults.standard.set(partnerName, forKey: "partnerName")
        UserDefaults.standard.set(defaultMessage, forKey: "defaultMessage")
        UserDefaults.standard.set(partnerMessage, forKey: "partnerMessage")
    }
    
    private func saveDailyHistory() {
        if let encoded = try? JSONEncoder().encode(dailyHistory) {
            UserDefaults.standard.set(encoded, forKey: "dailyHistory")
        }
    }
    
    private func loadAllData() {
        // Load water data
        todayIntake = UserDefaults.standard.integer(forKey: "todayIntake")
        lastResetDate = UserDefaults.standard.object(forKey: "lastResetDate") as? Date ?? Date()
        
        // Load settings
        dailyGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        if dailyGoal == 0 { dailyGoal = 2250 } // Default value
        
        partnerConnected = UserDefaults.standard.bool(forKey: "partnerConnected")
        partnerName = UserDefaults.standard.string(forKey: "partnerName") ?? ""
        
        defaultMessage = UserDefaults.standard.string(forKey: "defaultMessage") ?? 
            "You still have {volume}ml left to reach your daily goal. Keep hydrating!"
        partnerMessage = UserDefaults.standard.string(forKey: "partnerMessage") ?? 
            "My love, you still have {volume}ml of water you need to drink. Please complete it while knowing that I love you."
        
        // Load daily history
        if let data = UserDefaults.standard.data(forKey: "dailyHistory"),
           let history = try? JSONDecoder().decode([DailyRecord].self, from: data) {
            dailyHistory = history
        }
    }
    
    // MARK: - Daily Management
    
    private func checkForNewDay() {
        let calendar = Calendar.current
        let today = Date()
        
        // If it's a new day, reset progress
        if !calendar.isDate(lastResetDate, inSameDayAs: today) {
            resetDailyProgress()
        }
    }
    
    private func saveDailyRecord() {
        let today = Calendar.current.startOfDay(for: lastResetDate)
        let record = DailyRecord(
            date: today,
            totalIntake: todayIntake,
            goal: dailyGoal,
            completionPercentage: Double(todayIntake) / Double(dailyGoal)
        )
        
        // Remove existing record for this date if any
        dailyHistory.removeAll { Calendar.current.isDate($0.date, inSameDayAs: today) }
        
        // Add new record
        dailyHistory.append(record)
        
        // Keep only last 30 days
        dailyHistory = dailyHistory.sorted { $0.date > $1.date }.prefix(30).map { $0 }
        
        saveDailyHistory()
    }
    
    private func updateTodayRecord() {
        let today = Calendar.current.startOfDay(for: Date())
        let record = DailyRecord(
            date: today,
            totalIntake: todayIntake,
            goal: dailyGoal,
            completionPercentage: Double(todayIntake) / Double(dailyGoal)
        )
        
        // Update or add today's record
        if let index = dailyHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyHistory[index] = record
        } else {
            dailyHistory.append(record)
        }
        
        saveDailyHistory()
    }
    
    // MARK: - Analytics
    
    func getWeeklyAverage() -> Double {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklyRecords = dailyHistory.filter { $0.date >= oneWeekAgo }
        
        guard !weeklyRecords.isEmpty else { return 0 }
        
        let totalIntake = weeklyRecords.reduce(0) { $0 + $1.totalIntake }
        return Double(totalIntake) / Double(weeklyRecords.count)
    }
    
    func getStreakDays() -> Int {
        let sortedRecords = dailyHistory.sorted { $0.date > $1.date }
        var streak = 0
        
        for record in sortedRecords {
            if record.completionPercentage >= 1.0 {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
    
    func getBestDay() -> DailyRecord? {
        return dailyHistory.max { $0.totalIntake < $1.totalIntake }
    }
}

// MARK: - Supporting Models

struct DailyRecord: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let totalIntake: Int
    let goal: Int
    let completionPercentage: Double
    
    var isCompleted: Bool {
        return completionPercentage >= 1.0
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}