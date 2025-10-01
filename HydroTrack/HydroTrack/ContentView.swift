//
//  ContentView.swift
//  HydroTrack
//
//  Created by Batuhan Aydin on 9/24/25.
//

import SwiftUI

struct ContentView: View {
    // State to track daily water intake
    @State private var todayIntake: Int = 1462 // ml consumed today
    @State private var dailyGoal: Int = 2250   // ml daily goal
    @State private var customAmount: String = ""
    @State private var selectedUnit: VolumeUnit = .ml
    @State private var showingCustomInput: Bool = false
    @State private var showingSettings: Bool = false
    
    enum VolumeUnit: String, CaseIterable {
        case ml = "ml"
        case oz = "oz"
        
        var conversionToMl: Double {
            switch self {
            case .ml: return 1.0
            case .oz: return 29.5735 // 1 oz = 29.5735 ml
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // App Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("💧 HydroTrack")
                    .font(.title2)
                    .fontWeight(.medium)
                Spacer()
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            // Progress Circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                
                // Progress text
                VStack {
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("\(todayIntake)ml")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("\(dailyGoal)ml")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Volume Buttons
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    VolumeButton(volume: 200, action: { logWater(200) })
                    VolumeButton(volume: 225, action: { logWater(225) })
                }
                HStack(spacing: 20) {
                    VolumeButton(volume: 300, action: { logWater(300) })
                    VolumeButton(volume: 350, action: { logWater(350) })
                }
                
                // Custom Amount Button
                Button(action: { showingCustomInput = true }) {
                    Text("Custom Amount")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .background(
            // Water-themed background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.cyan.opacity(0.05),
                    Color.blue.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                // Floating water bubbles animation
                WaterBubblesView()
            )
            .ignoresSafeArea(.all)
        )
        .sheet(isPresented: $showingCustomInput) {
            CustomAmountView(
                customAmount: $customAmount,
                selectedUnit: $selectedUnit,
                onLog: { amount in
                    let mlAmount = Int(amount * selectedUnit.conversionToMl)
                    logWater(mlAmount)
                    customAmount = ""
                    showingCustomInput = false
                }
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(dailyGoal: $dailyGoal)
        }
    }
    
    // Computed property for progress percentage
    private var progressPercentage: Double {
        return min(Double(todayIntake) / Double(dailyGoal), 1.0)
    }
    
    // Function to log water intake
    private func logWater(_ amount: Int) {
        withAnimation {
            todayIntake += amount
        }
    }
}

// Volume Button Component
struct VolumeButton: View {
    let volume: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(volume)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("ml")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(width: 120, height: 80)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.7), Color.cyan.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: volume)
    }
}

// Custom Amount Input View
struct CustomAmountView: View {
    @Binding var customAmount: String
    @Binding var selectedUnit: ContentView.VolumeUnit
    let onLog: (Double) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Log Custom Amount")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 20) {
                    // Amount Input
                    TextField("Enter amount", text: $customAmount)
                        .keyboardType(.decimalPad)
                        .font(.title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)
                    
                    // Unit Picker
                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(ContentView.VolumeUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal, 20)
                
                // Log Button
                Button(action: {
                    if let amount = Double(customAmount), amount > 0 {
                        onLog(amount)
                    }
                }) {
                    Text("Log Water")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 20)
                .disabled(customAmount.isEmpty || Double(customAmount) == nil)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Water Bubbles Animation Background
struct WaterBubblesView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: CGFloat.random(in: 20...40))
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: animate ? -50 : 900
                    )
                    .animation(
                        .linear(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 0.5),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    ContentView()
}
