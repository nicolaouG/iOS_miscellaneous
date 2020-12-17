//
//  Biometrics.swift
//  Eshop
//
//  Created by george on 16/12/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import Foundation
import LocalAuthentication

/**
 Authenticate using touch or face ID
  
 # Sample code:
 ```
 Biometrics.authenticate(fallsBackToDevicePasscode: false) { (context, error) in
     print(error?.localizedDescription)
 }
 ```
 */
enum Biometrics {
    /**
     Depending on the hardware supported, the respective authentication method (touchID or faceID) will be prompted to the user
     
     - Parameters:
        - fallsBackToDevicePasscode: When biometrics fail, prompt user to input the device password.
        - completion: Returns the context and the authentication error if any.
            - context: LAContext
            - error : Error?
     */
    static func authenticate(fallsBackToDevicePasscode: Bool = false, completion: @escaping (_ context: LAContext?, _ error: Error?) -> () = { _,_ in } ) {
        let context = LAContext()
        var error: NSError?
        
        /// custom message for the Cancel button
        //context.localizedCancelTitle = "Enter Username/Password"
        
        let policy: LAPolicy = fallsBackToDevicePasscode ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics

        /// check whether biometric authentication is possible
        if context.canEvaluatePolicy(policy, error: &error) {
            /// reason to present for touchID... for faceID the reason is in the plist
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "The app"
            let reason = "\(appName) would like to authenticate using touch ID"

            context.evaluatePolicy(policy, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(context, nil)
                    } else {
                        /// Failed to authenticate
                        completion(context, authenticationError)
                    }
                }
            }
        } else {
            /// Device does not support biometrics authentication
            completion(context, error)
        }
    }
}
