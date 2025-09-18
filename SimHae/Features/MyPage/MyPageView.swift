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
    @Environment(\.dismiss) private var dismiss
    
    @State private var time: Date = Date()
    @State private var showSettingsAlert = false
    
    private let notifID = "daily_reminder"
    
    @EnvironmentObject private var authVM: AuthViewModel   // 추가
    @State private var showLogoutConfirm = false            // 추가
    
    
    var body: some View {
        Form {
            Section {
                Text("내정보")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text("user_138132")
                    .foregroundStyle(.white)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section(header: Text("꿈 기록 리마인더 설정").font(.headline).foregroundStyle(.white)        .padding(.horizontal, -16)) {
                Toggle(isOn: $reminderEnabled) {
                    Text("리마인더 활성화")
                        .foregroundStyle(.white)
                }
                .tint(Color(hex: "#9963FF"))
                
                .onChange(of: reminderEnabled) { enabled in
                    Task { await handleEnableToggle(enabled: enabled) }
                }
                
                VStack {
                    DatePicker("알림 시간 설정", selection: $time, displayedComponents: .hourAndMinute)
                        .foregroundStyle(.white)
                        .disabled(!reminderEnabled)
                        .onChange(of: time) { _ in
                            if reminderEnabled {
                                Task { await reschedule() }
                            }
                        }
                    
                    HStack {
                        if reminderEnabled {
                            Text("*매일 \(formatted(time))에 꿈 기록을 위해 \n알림을 보내드릴게요.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                
            }
            .padding(4)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: "7534E4").opacity(0.1))
            )
            
            Section {
                Text("결제 내역")
                    .foregroundStyle(.white)
                HStack(alignment: .top) {
                    Text("2025.09.14")
                        .foregroundStyle(Color(hex: "FFFFFF").opacity(0.5))
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("조개 한 주먹 (5개)")
                            .foregroundStyle(.white)
                        Text("900원")
                            .foregroundStyle(Color(hex: "#843CFF"))
                    }
                }
                HStack(alignment: .top) {
                    Text("2025.09.13")
                        .foregroundStyle(Color(hex: "FFFFFF").opacity(0.5))
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("조개 한 주먹 (5개)")
                            .foregroundStyle(.white)
                        Text("900원")
                            .foregroundStyle(Color(hex: "#843CFF"))
                    }
                }
                HStack(alignment: .top) {
                    Text("2025.09.11")
                        .foregroundStyle(Color(hex: "FFFFFF").opacity(0.5))
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("조개 한 주먹 (5개)")
                            .foregroundStyle(.white)
                        Text("900원")
                            .foregroundStyle(Color(hex: "#843CFF"))
                    }
                }
                
            }
            .padding(.horizontal, -4)
            .listRowBackground(Color.clear)
            
            Section(header: Text("계정").foregroundStyle(.secondary)) {
                Button(role: .destructive) {
                    showLogoutConfirm = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("로그아웃")
                    }
                }
            }
            .listRowBackground(Color.clear) // 스타일은 취향대로
        }
        .background(
            Color(hex: "#111111")
        )
        .confirmationDialog("로그아웃 하시겠어요?",
                            isPresented: $showLogoutConfirm,
                            titleVisibility: .visible) {
            Button("로그아웃", role: .destructive) {
                // (선택) 알림 예약 취소 같은 부가 정리
                Task { await NotificationManager.shared.cancelAll() }
                
                // 실제 로그아웃
                authVM.logout()
                // 여기서 화면 전환은 SimHaeApp의 isAuthenticated 바인딩이 알아서 처리
            }
            Button("취소", role: .cancel) { }
        }
                            .navigationBarBackButtonHidden()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        dismiss()
                                    }) {
                                        Image(systemName: "arrow.left")
                                            .foregroundStyle(Color(hex: "#B184FF"))
                                            .padding(.leading, 12)
                                    }
                                }
                            }
                            .padding(.horizontal, -8)
                            .navigationTitle("마이페이지")
                            .navigationBarTitleDisplayMode(.inline)
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
        .preferredColorScheme(.dark)
}
