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

@testable import EventBlankKit

struct TestingRealm {

    public static func mockApp(id: String = #function) -> RealmProvider {
        var app = RealmProvider.app
        app.configuration.inMemoryIdentifier = "app-\(id)"
        return app
    }
    public static func mockEvent(id: String = #function) -> RealmProvider {
        var event = RealmProvider.event
        event.configuration.syncConfiguration = nil
        event.configuration.inMemoryIdentifier = "event-\(id)"
        return event
    }

    static func resetRealm(in provider: RealmProvider) {
        try! provider.realm.write {
            provider.realm.deleteAll()
        }
    }

    static func createDataSet1(app: RealmProvider, event: RealmProvider) {
        resetRealm(in: app)
        resetRealm(in: event)
        app.createInitialAppState()

        // prepare the db
        let speaker = Speaker()
        speaker.name = "speaker name"
        speaker.visible = true

        let session = Session()
        session.title = "session name"
        session.speaker = speaker
        session.beginTime = Date().adjust(.minute, offset: 15)
        session.lengthInMinutes = 60
        session.visible = true

        let session2 = Session()
        session2.title = "second session name"
        session2.speaker = speaker
        session2.beginTime = Date().adjust(.minute, offset: 75)
        session2.lengthInMinutes = 60
        session2.visible = true

        let eventData = EventData()
        eventData.title = "event name"

        let location = Location()
        location.location = "location name"
        let track = Track()
        track.track = "track name"

        let realm = event.realm
        try! realm.write {
            realm.add(speaker)
            realm.add(session)
            realm.add(session2)
            realm.add(eventData)
            realm.add(track)
            realm.add(location)
        }
    }
}
