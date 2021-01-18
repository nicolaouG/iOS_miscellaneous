# Widget (iOS 14)

### Simple demo widget :

Notes:
- *File > New > Target > Widget Extension*

- Any file used by both the app and the widget must have its *target membership* checked accordingly (in *file inspector*).

- Add the AppGroup capability to share data between targets:
    - enable it for *bundle identifier* in [Apple Developer](#https://developer.apple.com/account/resources/identifiers/).
    - add it in Xcode for each necessary target: *Signing & Capabilities > + Capability > App Groups > + group.com.name.your.group*

- Test saving in the app group to trigger a timeline reload and update the widget. E.g:
```swift
let testPoints = "\(Int.random(in: 20...90))"
WidgetGroupHelper().storeInGroup(key: AppGroupKeys.points.rawValue, data: testPoints)
```

- To open a specific screen by tapping on the widget add a `widgetUrl` or `Link` to it or to a subview.
    - Medium or large widgets can have multiple actions.
    - The action is handled in `onOpenURL(perform:)` or `application(_:open:options:)` or `application(_:open:)`, depending on the app's life cycle.
```swift
var  body: some  View {
    Link(destination: URL(string: WidgetLink.points.rawValue)!, label: {
        // rest of body
    }
}
// OR: small widgets need the widgetURL
var  body: some  View {
    SomeView()
        .widgetURL(URL(string: WidgetLink.points.rawValue)!)
}
```
```swift
/** SAMPLE */
extension  AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.absoluteString == WidgetLink.points.rawValue {
            openAppInAccountDetails()
        }
        return true
    }

    func  openAppInAccountDetails() {
        let tabbar = window?.rootViewController as? BaseTabBarController
        let homeNav = tabbar?.viewControllers?.first as? BaseNavigationController
        let homeNavVCs = homeNav?.viewControllers
        tabbar?.selectedViewController = homeNav

        if  let accountVC = homeNavVCs?.first(where: {$0 is  AccountViewController}) as? AccountViewController {
            homeNav?.popToViewController(accountVC, animated: false)
        } else {
            homeNav?.popToRootViewController(animated: false)
            let accountVC = AccountViewController()
            homeNav?.pushViewController(accountVC, animated: true)
        }
    }
}
```

- For an `IntentConfiguration` with user-configurable properties and so an `IntentTimelineProvider`, a SiriKit Intent Definition File is needed (*.intentdefinition*).
    - Add a parameter, set its type from the drop down menu.
    - Edit the parameter accordingly.
    - Run the widget target, long-press the widget, edit, and see your changes.
    - In the widget's `getTimeline` add the configuration to the entry to be handled in the `WidgetEntryView`.
    
<img src="https://github.com/nicolaouG/iOS_miscellaneous/blob/main/Widget/WidgetIntent.png" width="666">
<img src="https://github.com/nicolaouG/iOS_miscellaneous/blob/main/Widget/IntentEnumProperty.png" width="507">

- To show an image from a url, it must be loaded synchronously so, instead of using Kingfisher, use the `URLImage.swift` helper file or load a UIImage from `Data(contentsOf: url)`.

- To support multiple widgets:
```swift
/** Remove @main from the `Widget` struct */
@main
struct WidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        Widget1()
        Widget2()
    }
}
```
