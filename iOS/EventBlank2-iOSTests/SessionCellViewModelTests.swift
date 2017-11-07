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

@testable import EventBlankKit

class SessionCellViewModelTests : XCTestCase {

    func test_storesSession_whenInitialized() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let session = testEvent.realm.objects(Session.self)[0]
        let model = SessionCellViewModel(provider: testApp, with: session)

        XCTAssertEqual(model.session, session)
    }

    func test_emitsIsFavorite_whenFavoritesToggled() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let session = testEvent.realm.objects(Session.self)[0]

        let model = SessionCellViewModel(provider: testApp, with: session)
        let items = model.isFavorite.asObservable()
            .subscribeOn(MainScheduler.instance)
            .share(replay: 1)

        DispatchQueue.main.async {
            model.updateIsFavorite(isFavorite: true)
        }

        let result = try! items.take(2).toBlocking().toArray()
        XCTAssertEqual([false, true], result)
    }

    func test_emitsSpeakerIsFavorite_whenSpeakerFavoritesToggled() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let session = testEvent.realm.objects(Session.self)[0]

        let model = SessionCellViewModel(provider: testApp, with: session)
        let items = model.isFavoriteSpeaker.asObservable()
            .subscribeOn(MainScheduler.instance)
            .share(replay: 1)

        DispatchQueue.main.async {
            let session = testEvent.realm.objects(Session.self)[0]
            FavoritesModel.default(provider: testApp)
                .updateSpeakerFavoriteTo(session.speaker!, to: true)
        }

        let result = try! items.take(2).toBlocking().toArray()
        XCTAssertEqual([false, true], result)
    }

    func test_emitsDidChange_whenLocationTrackSpeakerChanged() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let session = testEvent.realm.objects(Session.self)[0]
        let location = testEvent.realm.objects(Location.self)[0]
        let track = testEvent.realm.objects(Track.self)[0]
        try! testEvent.realm.write {
            session.location = location
            session.track = track
        }

        let model = SessionCellViewModel(provider: testApp, with: session)
        var counter = 1

        let items = model.didChange.asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .do { counter += 1 }
            .map { counter }

        // change event object
        DispatchQueue.main.async {
            let location = testEvent.realm.objects(Location.self)[0]
            try! testEvent.realm.write {
                location.location = "changed name"
            }
        }
        let first = try! items.toBlocking().first()!
        XCTAssertEqual(1, first)

        // change track object
        DispatchQueue.global(qos: .background).async {
            let track = testEvent.realm.objects(Track.self)[0]
            try! testEvent.realm.write {
                track.track = "changed name"
            }
        }
        let second = try! items.toBlocking().first()!
        XCTAssertEqual(2, second)

        // change speaker
        DispatchQueue.main.async {
            let session = testEvent.realm.objects(Session.self)[0]
            try! testEvent.realm.write {
                session.speaker!.name = "changed name"
            }
        }
        let third = try! items.toBlocking().first()!
        XCTAssertEqual(3, third)
    }
}

