# Push notifications

### Notes:

- *Target > Signing & Capabilities > + Capability > Push Notifications*

- [Apple Developer](#https://developer.apple.com/account/resources/identifiers/) > push notif capability for that bundle identifier (already enabled if followed step 1 first)
	- It needs a certificate (*Configure*):
		- Keychain Access > Certificate Assistant > Request from a CA > Save to disk

*Optional*
- Use [Pusher](https://github.com/noodlewerk/NWPusher) to test on a real device (it needs the token and the cert you created in step 2 - p12 private key).

- Request permission in application didFinishLaunchingWithOptions:
```swift
func registerForPushNotifications() {
    UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? AppDelegate
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (isGranted, error) in
        guard isGranted else { return }
        self?.getNotificationSettings()
    }
}

func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
```

- Get the device token on success or the error on failure:
```swift
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
```

- To push a notification on the simulator:
	- Create a `filename.apn` with the notification json you want to test
	- Go to *Windows > Devices and Simulators > Simulators tab to select your active one > copy its identifier*
	- From the terminal (replace `device_identifier` and `bundle_identifier` accordingly):
```bash
cd to/the/folder/with/the/filename.apn/file
xcrun simctl push device_identifier bundle_identifier filename.apn
```


## Actionable notification

After `registerForRemoteNotifications` you can call the function `makeNotificationActionable` with your desired custom actions and handle them in `userNotificationCenter didReceive response` of the `UNUserNotificationCenterDelegate` (set the `UNUserNotificationCenter.current().delegate` to capture it)

```json
{
	"aps": {
		...
		"category": "NEW_CATEGORY"
	}
}
```
```swift
switch response.actionIdentifier {
case NotificationIdentifiers.viewAction: break
case NotificationIdentifiers.likeAction: break
case NotificationIdentifiers.replyAction: break
case NotificationIdentifiers.dismissAction: break
default: break
}
```
<img src="https://github.com/nicolaouG/iOS_miscellaneous/blob/main/Push_notifications/notification_actions.png" width="250">

## Silent push notification

Choose your *Target > Signing & Capabilities > + Capability > Background Modes > Remote notifications*
```json
{
    "aps": {
		"content-available": 1
	}
}
```
And in `didReceiveRemoteNotification`:
```swift
let isSilent = aps["content-available"] as? Int == 1
```

## Rich push notification

- Modify the notification before displaying it (e.g to display images)
- *File > New > Target > Notification Service Extension*
- Check its *Deployment info* for the iOS version

```json
{
	"aps": {
		...
        "mutable-content": 1,
        "attachment_url": "https://www.nairaland.com/attachments/51410_manU_gifbda075058576073a13aed6f1ea2ceb30"
	}
}
```
```swift
let isMutable = aps["mutable-content"] as? Int == 1
```

- Get the image attachment using the url from the payload and save it in a temporary file to display it. 
```swift
if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any],
	let imageURL = aps["attachment_url"] as? String,
	let imageAttachment = getImageAttachment(fromURL: imageURL, imgExtension: .gif) {
	bestAttemptContent.attachments = [imageAttachment]
}
```
<img src="https://github.com/nicolaouG/iOS_miscellaneous/blob/main/Push_notifications/rich_notification.jpg" width="250">

### Test payload
```json
{
  "aps": {
    "alert": {
      "title": "This is a title",
      "subtitle": "This is a subtitle",
      "body": "This is the notification body."
    },
    "sound": "default",
    "badge": 1,
    "category": "NEW_CATEGORY",
    "mutable-content": 1,
    "attachment_url": "https://www.nairaland.com/attachments/51410_manU_gifbda075058576073a13aed6f1ea2ceb30"
  }
}
```
