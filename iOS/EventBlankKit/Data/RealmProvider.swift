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
import RealmContent

public struct RealmProvider {

    // MARK: - private configurations
    internal static var appConfig = Realm.Configuration(
        fileURL: FilePath(inLibrary: "app.realm").url,
        schemaVersion: 1,
        deleteRealmIfMigrationNeeded: true,
        objectTypes: [Favorites.self, ObjectId.self, AppState.self]
    )

    internal static var eventConfig = Realm.Configuration(
        fileURL: FilePath(inLibrary: "event.realm").url,
        schemaVersion: 1,
        objectTypes: [
            // event data
            EventData.self, Session.self, Speaker.self, Location.self, Track.self,

            // content
            ContentPage.self, ContentElement.self
        ]
    )

    internal init(config: Realm.Configuration) {
        configuration = config
    }

    mutating public func setSyncConfiguration(_ config: SyncConfiguration?) {
        var updated = configuration
        updated.syncConfiguration = config
        configuration = updated
    }

    // MARK: - enum cases
    public static var app: RealmProvider = {
        return RealmProvider(config: appConfig)
    }()

    public static var event: RealmProvider = {
        return RealmProvider(config: eventConfig)
    }()

    // MARK: - current configuration
    public var configuration: Realm.Configuration

    public var realm: Realm {
        // dev need insure the configuration is valid before calling `.realm`
        return try! Realm(configuration: configuration)
    }

    // MARK: - initialization
    public func createInitialAppState() {
        if realm.objects(AppState.self).count == 0 {
            try! realm.write {
                realm.add(AppState())
                realm.add(Favorites())
            }
        }
    }

    // MARK: - validate data
    public func validateInitialData() -> Bool {
        guard let event = realm.objects(EventData.self).first, event.isValid,
            let session = realm.objects(Session.self).first, session.isValid
            else {
                return false
        }
        return true
    }
}
