//
//  AppDelegate.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit
import UserNotifications

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private var pendingDailyNotification: DailyNotificationKind?
    private var lastNotificationDates: [DailyNotificationKind: Date] = [:]

    var onDailyNotification: ((DailyNotificationKind) -> Void)? {
        didSet {
            guard let kind = pendingDailyNotification, let onDailyNotification else {
                return
            }
            pendingDailyNotification = nil
            onDailyNotification(kind)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await handleNotificationResponse(response)
    }

    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let notification = response.notification
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier,
            let kind = DailyNotificationKind.allCases.first(where: { $0.identifier == notification.request.identifier }),
            kind != .horoscope,
            lastNotificationDates[kind] != notification.date else {
            return
        }
        lastNotificationDates[kind] = notification.date
        if let onDailyNotification {
            onDailyNotification(kind)
        } else {
            pendingDailyNotification = kind
        }
    }
}
