//
//  NotificationManager.swift
//  SimHae
//
//  Created by 홍준범 on 9/16/25.
//

import Foundation
import UIKit
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private override init() { super.init() }
    
    func configure() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }
    
    // 권한 요청
    func requestAutorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    //현재 권한 상태 확인
    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    func scheduleDailyReminder(
        id: String = "daily_reminder",
        hour: Int,
        minute: Int,
        title: String,
        body: String
    ) async throws {
        await cancelNotification(id: id)
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
    
    //특정 알림 취소
    func cancelNotification(id: String) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    //전부 취소
    func cancelAll() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // 포그라운드에서도 배너 보이기
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    // 설정 앱 열기(권한 거부 시 안내용)
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}
