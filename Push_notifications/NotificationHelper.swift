//
//  NotificationHelper.swift
//  TestProject
//
//  Created by george on 18/01/2021.
//

import Foundation
import UserNotifications
import UIKit


enum NotificationIdentifiers {
    static let viewAction = "VIEW_IDENTIFIER"
    static let likeAction = "LIKE_IDENTIFIER"
    static let replyAction = "REPLY_IDENTIFIER"
    static let dismissAction = "DISMISS_IDENTIFIER"
    static let newCategory = "NEW_CATEGORY"
}


struct NotificationHelper {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? AppDelegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, error) in
            guard isGranted else { return }
            getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                makeNotificationActionable()
            }
        }
    }
    
    func makeNotificationActionable(categoryIdentifier: String = NotificationIdentifiers.newCategory) {
        let viewAction = UNNotificationAction(identifier: NotificationIdentifiers.viewAction, title: "View", options: [.foreground]) // launches app
        let likeAction = UNNotificationAction(identifier: NotificationIdentifiers.likeAction, title: "Like", options: [])
        let replyAction = UNTextInputNotificationAction(identifier: NotificationIdentifiers.replyAction, title: "Reply", options: [], textInputButtonTitle: "Send", textInputPlaceholder: "Your reply")
        let dismissAction = UNNotificationAction(identifier: NotificationIdentifiers.dismissAction, title: "Dismiss", options: [])
        
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [viewAction, likeAction, replyAction, dismissAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}


extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    /**
     When the app is running either in the foreground or the background and receives a notification
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }

        print(aps)
    }
    
    /**
     Call this from `didFinishLaunchingWithOptions` to handle push notification taps when the app is not running. Fill in accordingly (e.g open app to a specific screen).
     */
    func handleRemoteNotificationTap(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        
        guard let notification = notificationOption as? [String: Any],
              let aps = notification["aps"] as? [String: AnyObject]
        else { return }
        
        print(aps)
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let aps = userInfo["aps"] as? [String: AnyObject] else { return }
        
        switch response.actionIdentifier {
        case NotificationIdentifiers.viewAction: break
        case NotificationIdentifiers.likeAction: break
        case NotificationIdentifiers.replyAction: break
        case NotificationIdentifiers.dismissAction: break
        default: break
        }
        
        completionHandler()
    }
}
