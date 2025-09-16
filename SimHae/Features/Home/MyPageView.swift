//
//  MyPageView.swift
//  SimHae
//
//  Created by 홍준범 on 9/16/25.
//

import SwiftUI

struct MyPageView: View {
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 9
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0
    
    @State private var time: Date = Date()
    @State private var showSettingsAlert = false
    
    private let notifID = "daily_reminder"
    
    var body: some View {
        Form {
            Section(header: Text("꿈 기록 리마인더")) {
                Toggle(isOn: $reminderEnabled) {
                    Text("리마인더 활성화")
                }
                .onChange(of: reminderEnabled) { enabled in
                    Task { await handleEnableToggle(enabled: enabled) }
                }
                
                DatePicker("시간", selection: $time, displayedComponents: .hourAndMinute)
                    .disabled(!reminderEnabled)
                    .onChange(of: time) { _ in
                        if reminderEnabled {
                            Task { await reschedule() }
                        }
                    }
                
                if reminderEnabled {
                    Text("매일 \(formatted(time))에 알림이 울려요.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            
        }
        .onAppear {
            var comps = DateComponents()
            comps.hour = reminderHour
            comps.minute = reminderMinute
            time = Calendar.current.date(from: comps) ?? Date()
        }
        .alert("알림 권한이 꺼져 있어요", isPresented: $showSettingsAlert) {
            Button("설정 열기") {
                NotificationManager.shared.openSystemSettings()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("설정 > SimHae > 알림에서 허용을 켜주세요.")
        }
        .navigationTitle("마이페이지")
    }
    
    private func handleEnableToggle(enabled: Bool) async {
        if enabled {
            let status = await NotificationManager.shared.authorizationStatus()
            switch status {
            case .authorized, .provisional, .ephemeral:
                await reschedule()
            case .notDetermined:
                do {
                    let granted = try await NotificationManager.shared.requestAutorization()
                    if granted {
                        await reschedule()
                    } else {
                        reminderEnabled = false
                        showSettingsAlert = true
                    }
                } catch {
                    reminderEnabled = false
                    showSettingsAlert = true
                }
            case .denied:
                reminderEnabled = false
                showSettingsAlert = true
            @unknown default:
                reminderEnabled = false
            }
        } else {
            await NotificationManager.shared.cancelNotification(id: notifID)
        }
    }
    private func reschedule() async {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let hour = comps.hour ?? 9
        let minute = comps.minute ?? 0
        
        reminderHour = hour
        reminderMinute = minute
        
        do {
            try await NotificationManager.shared.scheduleDailyReminder(
                id: notifID, hour: hour, minute: minute, title: "오늘의 꿈 기록", body: "방금 꾼 꿈, 잊어버리기 전에 적어볼까요?"
        )
        } catch {
            print("Scedule error: \(error)")
        }
    }
    
    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateStyle = .none
        f.timeStyle = .short
        return f.string(from: date)
    }
}
#Preview {
    MyPageView()
}
