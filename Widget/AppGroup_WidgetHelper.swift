//
//  AppGroup_WidgetHelper.swift
//  TestProject
//
//  Created by george on 14/01/2021.
//  Copyright © 2021 George Nicolaou. All rights reserved.
//

import Foundation
import WidgetKit
import UIKit

public enum AppGroup {
    static let bundleId: String = "com.company.project"
    static let groupId: String = "group.com.company.project"
}


public enum AppGroupKeys: String {
    case points
    case didReceiveNotification
}


public enum WidgetLink: String {
    case points = "urlschemes://openToPoints"
}


@available(iOS 14, *)
public struct WidgetGroupHelper {
    
    init() {}
    
    public func storeInGroup(key: String, data: Any, reload: Bool = true) {
        let group = UserDefaults(suiteName: AppGroup.groupId)
        
        if let imgData = data as? UIImage {
            group?.setValue(imgData.pngData(), forKey: key)
        } else if let strData = data as? String {
            group?.setValue(strData, forKey: key)
        } else if let dataData = data as? Data {
            group?.setValue(dataData, forKey: key)
        } else if let boolData = data as? Bool {
            group?.setValue(boolData, forKey: key)
        } else {
            group?.setValue(data, forKey: key)
        }
        
        guard reload else { return }
        reloadAllTimelines()
    }

    public func removeFromGroup(key: String) {
        let userDefaults = UserDefaults(suiteName: AppGroup.groupId)
        userDefaults?.removeObject(forKey: key)
        reloadAllTimelines()
    }

    public func removeAllInGroup() {
        UserDefaults.standard.removePersistentDomain(forName: AppGroup.groupId)
        reloadAllTimelines()
    }
    
    public func reloadTimelines(_ kind: String) {
        #if arch(arm64) || arch(i386) || arch(x86_64)
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
        #endif
    }

    public func reloadAllTimelines() {
        #if arch(arm64) || arch(i386) || arch(x86_64)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
