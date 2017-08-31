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

import XCTest
import RxSwift
import RxTest
import RxBlocking

import EventBlankKit

@testable import EventBlank2_iOS

class FavoritesModelTests : XCTestCase {

    func test_defaultSharedInstanceIsSame_whenAccessed() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        XCTAssertNotNil(FavoritesModel.default(provider: testApp))
    }

    func test_favoriteSpeakerExists_whenAdded() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let model = FavoritesModel.default(provider: testApp)

        let speakers = model.speakers.asObservable().subscribeOn(MainScheduler.instance)
        let speaker = testEvent.realm.objects(Speaker.self).first!

        model.updateSpeakerFavoriteTo(speaker, to: true)

        XCTAssertTrue(try! speakers.toBlocking().first()!.contains(where: { id -> Bool in
            return id == speaker.uuid
        }))
    }


    func test_favoriteSpeakerNotFound_whenRemoved() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let model = FavoritesModel.default(provider: testApp)
        let speaker = testEvent.realm.objects(Speaker.self).first!

        model.updateSpeakerFavoriteTo(speaker, to: true)

        let speakers = model.speakers.asObservable().subscribeOn(MainScheduler.instance)

        model.updateSpeakerFavoriteTo(speaker, to: false)

        XCTAssertFalse(try! speakers.toBlocking().first()!.contains(where: { id -> Bool in
            return id == speaker.uuid
        }))
    }

    func test_favoriteSessionExists_whenAdded() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let model = FavoritesModel.default(provider: testApp)

        let sessions = model.sessions.asObservable().subscribeOn(MainScheduler.instance)
        let session = testEvent.realm.objects(Session.self).first!

        model.updateSessionFavoriteTo(session, to: true)

        XCTAssertTrue(try! sessions.toBlocking().first()!.contains(where: { id -> Bool in
            return id == session.uuid
        }))
    }

    func test_favoriteSessionNotFound_whenRemoved() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let model = FavoritesModel.default(provider: testApp)
        let session = testEvent.realm.objects(Session.self).first!

        model.updateSessionFavoriteTo(session, to: true)

        let sessions = model.sessions.asObservable().subscribeOn(MainScheduler.instance)

        model.updateSessionFavoriteTo(session, to: false)

        XCTAssertFalse(try! sessions.toBlocking().first()!.contains(where: { id -> Bool in
            return id == session.uuid
        }))
    }
}

