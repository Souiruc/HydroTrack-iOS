//
//  PartnerView.swift
//  HydroTrack
//
//  Created by Batuhan Aydin on 9/24/25.
//

import SwiftUI

struct PartnerView: View {
    // Mock partner data
    @State private var partnerName: String = "Sarah"
    @State private var partnerIntake: Int = 1800 // ml consumed today
    @State private var partnerGoal: Int = 2250   // ml daily goal
    @State private var isConnected: Bool = true
    
    // Mock drinking timeline
    @State private var drinkingHistory: [DrinkEntry] = [
        DrinkEntry(time: "8:30 AM", amount: 300),
        DrinkEntry(time: "10:15 AM", amount: 200),
        DrinkEntry(time: "12:45 PM", amount: 250),
        DrinkEntry(time: "2:20 PM", amount: 200),
        DrinkEntry(time: "4:10 PM", amount: 225),
        DrinkEntry(time: "6:30 PM", amount: 300),
        DrinkEntry(time: "7:45 PM", amount: 325)
    ]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Connection Status
                    HStack {
                        Circle()
                            .fill(isConnected ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(isConnected ? "Connected to \(partnerName)" : "Not Connected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Partner Progress Circle
                    VStack(spacing: 15) {
                        Text("\(partnerName)'s Progress")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                                .frame(width: 160, height: 160)
                            
                            // Progress circle
                            Circle()
                                .trim(from: 0, to: partnerProgressPercentage)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .frame(width: 160, height: 160)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.5), value: partnerProgressPercentage)
                            
                            // Progress text
                            VStack {
                                Text("\(Int(partnerProgressPercentage * 100))%")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("\(partnerIntake)ml")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Text("of \(partnerGoal)ml")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Today's Timeline
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Today's Timeline")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(drinkingHistory.reversed(), id: \.id) { entry in
                                TimelineRow(entry: entry)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.top, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Partner")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // Computed property for partner progress percentage
    private var partnerProgressPercentage: Double {
        return min(Double(partnerIntake) / Double(partnerGoal), 1.0)
    }
}

// Drink Entry Model
struct DrinkEntry: Identifiable {
    let id = UUID()
    let time: String
    let amount: Int
}

// Timeline Row Component
struct TimelineRow: View {
    let entry: DrinkEntry
    
    var body: some View {
        HStack(spacing: 15) {
            // Time indicator
            VStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2, height: 30)
            }
            
            // Entry details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.time)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(entry.amount)ml")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
                
                Text("Water logged")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

#Preview {
    PartnerView()
}