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

class SessionViewModelTests : XCTestCase {

    func test_storesParams_whenInitialized() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let day = Schedule(provider: testEvent).dayRanges()[0]
        let model = SessionsViewModel(appProvider: testApp, day: day)

        XCTAssertEqual(model.day.text, day.text)
        XCTAssertNotNil(model.appState)
    }

    func test_emitsFavoritesSessions_whenFavoritesToggled() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let day = Schedule(provider: testEvent).dayRanges()[0]
        let model = SessionsViewModel(eventProvider: testEvent, appProvider: testApp, day: day)

        let items = model.sessions.asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .map { $0.count }

        let sid = testEvent.realm.objects(Session.self)[0].uuid

        try! testApp.realm.write {
            AppState.default(in: testApp).scheduleOnlyFavorites = true
        }

        DispatchQueue.main.async {
            model.activate()

            //favorite a session
            let session = testEvent.realm.object(ofType: Session.self, forPrimaryKey: sid)!
            FavoritesModel.default(provider: testApp).updateSessionFavoriteTo(session, to: true)
        }

        DispatchQueue.main.async {
            //favorite a session
            let session = testEvent.realm.object(ofType: Session.self, forPrimaryKey: sid)!
            FavoritesModel.default(provider: testApp).updateSessionFavoriteTo(session, to: false)
        }

        let result = try! items.take(3).toBlocking().toArray()

        XCTAssertEqual(0, result[0])
        XCTAssertEqual(1, result[1])
        XCTAssertEqual(0, result[2])
    }
}

