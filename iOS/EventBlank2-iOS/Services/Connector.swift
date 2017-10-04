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

import Foundation
import RealmSwift

import EventBlankKit

class Connector {

    init?(host: String, port: String = "9080", scheme: String, path: String) {
        guard let portNr = Int(port) else { return nil }

        var serverComps = URLComponents()
        serverComps.host = host
        serverComps.port = portNr
        serverComps.scheme = scheme

        var fileComps = URLComponents()
        fileComps.host = host
        fileComps.port = portNr
        fileComps.scheme = "realm"
        fileComps.path = path

        guard let serverUrl = serverComps.url, let fileUrl = fileComps.url else {
            return nil
        }

        self.serverUrl = serverUrl
        self.fileUrl = fileUrl
    }

    let serverUrl: URL
    let fileUrl: URL

    private(set) var user: SyncUser?
    private var syncedRealm: Realm?

    func connect(user: String, pass: String, completion: @escaping (Bool) -> Void) {
        print("connecting to \(serverUrl)")


        let cred = SyncCredentials.usernamePassword(username: user, password: pass, register: false)

        SyncUser.logIn(with: cred, server: serverUrl) { [weak self] user, error in
            guard let fileUrl = self?.fileUrl else { return }

            if let error = error {
                print("[connect error]: \(error.localizedDescription)")
            }

            guard let user = user else {
                completion(false)
                return
            }

            self?.user = user
            RealmProvider.event.setSyncConfiguration(
                SyncConfiguration(user: user, realmURL: fileUrl))

            Realm.asyncOpen(configuration: RealmProvider.event.configuration, callbackQueue: DispatchQueue.main, callback: { [weak self] realm, error in
                self?.syncedRealm = realm
                if let error = error {
                    print("Error connecting: \(error.localizedDescription)")
                }
                completion(error == nil)
            })
        }
    }

    private var token: SyncSession.ProgressNotificationToken?

    public func syncInitialData(initialDataIsValid: @escaping ()->Bool, progress updateProgress: @escaping (Double)->Void, completion: @escaping ()->Void) {
        guard let user = user else {
            fatalError("syncInitialData called without a logged user")
        }

        if initialDataIsValid() {
            completion()
            return
        }

        token?.stop()
        token = user.session(for: fileUrl)!.addProgressNotification(for: .download, mode: .reportIndefinitely) { progress in
            updateProgress(progress.fractionTransferred)
            
            if progress.isTransferComplete {
                DispatchQueue.main.async { [weak self] in
                    if initialDataIsValid() {
                        self?.token?.stop()
                        completion()
                    }
                }
            }
        }
    }

    func disconnect() {
        RealmProvider.event.setSyncConfiguration(nil);
        syncedRealm = nil
        user?.logOut()
    }

}
