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

class SessionDetailsCellViewModelTests : XCTestCase {

    func test_storesSession_whenInitialized() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let session = testEvent.realm.objects(Session.self)[0]
        let model = SessionDetailsCellViewModel(provider: testApp, session: session)

        XCTAssertEqual(model.session, session)
    }

    func test_emitsIsFavorite_whenFavoritesToggled() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let session = testEvent.realm.objects(Session.self)[0]

        let model = SessionDetailsCellViewModel(provider: testApp, session: session)
        let items = model.isFavorite.asObservable()
            .subscribeOn(MainScheduler.instance)
            .shareReplay(1)

        model.activate()

        DispatchQueue.main.async {
            model.updateIsFavorite(isFavorite: true)
            model.updateIsFavorite(isFavorite: false)
        }

        let result = try! items.take(2).toBlocking().toArray()
        XCTAssertEqual([true, false], result)
    }
}

