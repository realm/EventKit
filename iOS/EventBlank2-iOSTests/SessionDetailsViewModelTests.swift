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

class SessionDetailsViewModelTests : XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_storesSession_whenInitialized() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let session = testEvent.realm.objects(Session.self)[0]
        let model = SessionDetailsViewModel(session: session)

        XCTAssertEqual(model.session, session)
    }

    func test_emitsTableItems_whenSessionUpdated() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let session = testEvent.realm.objects(Session.self)[0]
        try! testEvent.realm.write {
            session.title = "session name"
        }

        let model = SessionDetailsViewModel(session: session)
        let items = model.tableItems.asObservable()
            .map { return $0[0].items[0].title }
            .subscribeOn(MainScheduler.instance)
            .share(replay: 1)

        let result = try! items.toBlocking().first()!
        XCTAssertEqual("session name", result)

        try! testEvent.realm.write {
            session.title = "changed name"
        }

        let result2 = try! items.take(2).toBlocking().toArray().last!
        XCTAssertEqual("changed name", result2)
    }
}

