//
//  SettingsView.swift
//  HydroTrack
//
//  Created by Batuhan Aydin on 9/24/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingMessageEditor: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Daily Goal Section
                    SettingsSection(title: "Daily Goal") {
                        HStack {
                            Text("Target")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Button(action: { 
                                    if dataManager.dailyGoal > 500 { 
                                        dataManager.updateDailyGoal(dataManager.dailyGoal - 250)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                
                                Text("\(dataManager.dailyGoal)ml")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 80)
                                
                                Button(action: { 
                                    if dataManager.dailyGoal < 5000 { 
                                        dataManager.updateDailyGoal(dataManager.dailyGoal + 250)
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                    }
                    
                    // Partner Connection Section
                    SettingsSection(title: "Share Progress") {
                        VStack(spacing: 15) {
                            HStack {
                                Text("Connect Support Person")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: .init(
                                    get: { dataManager.partnerConnected },
                                    set: { newValue in
                                        dataManager.updatePartnerSettings(connected: newValue, name: dataManager.partnerName)
                                    }
                                ))
                                    .labelsHidden()
                            }
                            
                            if dataManager.partnerConnected {
                                VStack(spacing: 10) {
                                    TextField("Partner's name", text: .init(
                                        get: { dataManager.partnerName },
                                        set: { newName in
                                            dataManager.updatePartnerSettings(connected: dataManager.partnerConnected, name: newName)
                                        }
                                    ))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Text("They will receive your progress updates and 8PM reminders")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                    }
                    
                    // Reminder Messages Section
                    SettingsSection(title: "Reminder Messages") {
                        VStack(spacing: 15) {
                            Button(action: { showingMessageEditor = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Customize 8PM Messages")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text("Edit default and partner messages")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Settings")
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
        .sheet(isPresented: $showingMessageEditor) {
            MessageEditorView(dataManager: dataManager)
        }
    }
}

// Settings Section Component
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// Message Editor View
struct MessageEditorView: View {
    @ObservedObject var dataManager: DataManager
    @State private var tempDefaultMessage: String = ""
    @State private var tempPartnerMessage: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Default Message
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Default Message")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Message you receive at 8PM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $tempDefaultMessage)
                            .frame(minHeight: 80)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Partner Message
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Partner Message")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Message your partner receives at 8PM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $tempPartnerMessage)
                            .frame(minHeight: 80)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💡 Tip")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Use {volume} in your message to show the remaining water amount.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(15)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding(20)
            }
            .background(Color(.systemBackground))
            .onAppear {
                tempDefaultMessage = dataManager.defaultMessage
                tempPartnerMessage = dataManager.partnerMessage
            }
            .navigationTitle("Edit Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dataManager.updateMessages(default: tempDefaultMessage, partner: tempPartnerMessage)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    SettingsView(dataManager: DataManager())
}