////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import UIKit
import RealmSwift
import MAThemeKit

import EventBlankKit
import UserNotifications
import Kingfisher

import Keys

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var appTheme: AppTheme!
    private var connector: Connector!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // set defaults & start app
        UNUserNotificationCenter.current().delegate = self
        ImageCache.default.pathExtension = "jpg"
        let config = EventBlank2IOSKeys()
        connector = Connector(host: config.host, port: config.port, scheme: config.scheme, path: config.path)
        initialize()
        
        return true
    }

    func initialize() {
        RealmProvider.app.createInitialAppState()

        if let connector = connector {
            let defaultVC = window!.rootViewController as! DefaultViewController

            if SyncUser.current == nil {
                defaultVC.startConnecting()
            }
            let config = EventBlank2IOSKeys()
            connector.connect(user: config.username, pass: config.password, completion: { [weak self] success in
                guard success else {
                    defaultVC.showError("To fetch the initial data you need to be connected to the Internet") {
                        self?.initialize()
                    }
                    return
                }
                self?.fetchInitialData()
            })
        } else {
            //use local database
            _ = RealmProvider.event.realm
            presentMainUI()
        }
    }

    func fetchInitialData() {
        _ = RealmProvider.event.realm

        // already has initial data, let's start the app

        if RealmProvider.event.validateInitialData() {
            presentMainUI()
            return
        }

        // fetch initial data

        guard let connector = connector else {
            initialize()
            return
        }

        let defaultVC = window!.rootViewController as! DefaultViewController
        defaultVC.startInitialData()

        connector.syncInitialData(
            initialDataIsValid: RealmProvider.event.validateInitialData,
            progress: defaultVC.updateProgress,
            completion: {
                defaultVC.stopConnecting { [weak self] in
                    self?.presentMainUI()
                }
        })
    }

    func presentMainUI() {
        guard let window = window else { fatalError("No window at start time") }
        // apply app theme
        appTheme = AppTheme(event: EventData.default(in: RealmProvider.event), window: window)

        // push root view controller
        let navigator = Navigator.default
        navigator.show(segue: .tabs, sender: nil, transition: .root(in: window))
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
