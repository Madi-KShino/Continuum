//
//  AppDelegate.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkAccountStatus { (success) in
            let checkedUserInfo = success ? "Successfully retrieved a logged in user!" : "Failed to retrieve logged in user"
            print(checkedUserInfo)
        }
        return true
    }
    
    func checkAccountStatus(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { (accountStatus, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(false)
                return
            } else {
                DispatchQueue.main.async {
                    let tabBarController = self.window?.rootViewController
                    let errorMessage = "Please Sign in to iCloud in your User Settings"
                    switch accountStatus {
                    case .available:
                        completion(true);
                    case .couldNotDetermine:
                        tabBarController?.presentSimpleAlertWith(title: errorMessage, message: "Unknown error fetching your account data")
                        completion(false)
                    case .noAccount:
                        tabBarController?.presentSimpleAlertWith(title: errorMessage, message: "No account found")
                        completion(false)
                    case .restricted:
                        tabBarController?.presentSimpleAlertWith(title: errorMessage, message: "This account is restricted")
                        completion(false)
                    default:
                        tabBarController?.presentSimpleAlertWith(title: errorMessage, message: "Unknown Error")
                        completion(false)
                    }
                }
            }
        }
    }
}

