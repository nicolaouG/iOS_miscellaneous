//
//  NotificationService.swift
//  NotificationService
//
//  Created by george on 19/01/2021.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any],
               let imageURL = aps["attachment_url"] as? String,
               let imageAttachment = getImageAttachment(fromURL: imageURL, imgExtension: .gif) {
                bestAttemptContent.attachments = [imageAttachment]
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    
    enum ImageExtension: String {
        case gif, png, jpg
    }
    
    func getImageAttachment(fromURL urlString: String?, imgExtension: ImageExtension = .png) -> UNNotificationAttachment? {
        guard let str = urlString,
              let url = URL(string: str) else { return nil }
        
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        let uniqueString = ProcessInfo.processInfo.globallyUniqueString
        let directoryPath = tempDirectory.appendingPathComponent(uniqueString, isDirectory: true)
        
        do {
            // create an empty directory to store the data
            try FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
            let fileURL = directoryPath.appendingPathComponent("attachment.\(imgExtension.rawValue)")
            let imgData = try Data(contentsOf: url)
            try imgData.write(to: fileURL)
            return try UNNotificationAttachment(identifier: "image", url: fileURL, options: nil)
        } catch {
            return nil
        }
    }
}
