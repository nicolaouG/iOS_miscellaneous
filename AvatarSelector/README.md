# AvatarSelectionAlert

<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift5.0-compatible-4BC51D.svg?style=flat" alt="Swift 5.0 compatible" /></a>


- Handles the photo library and camera permissions (just add the following in .plist)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>$(PRODUCT_NAME) requests access to the photo library for avatar image selection</string>
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) requests access to the camera for avatar image selection</string>
```
- Option to save an image when captured from camera
- Handles iPad's popover presentation of action sheets (just initialise with a sourceView and arrow direction)
- Implement the delegate to get image or its removal
- Saves the selected image in user defaults (give you key - probably a distinctive one in case of multiple users / logins)
- On iOS >= 14 the new *PHPickerViewController* is used


![](demo.gif)
