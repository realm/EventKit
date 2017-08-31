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

class SessionsModelTests : XCTestCase {

    func test_getsSessions_whenGivenDay() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let firstSession = testEvent.realm.objects(Session.self)[0]
        try! testEvent.realm.write {
            firstSession.beginTime = Date().adjust(.day, offset: -10)
        }

        let schedule = Schedule(provider: testEvent)
        let firstDay = schedule.dayRanges()[0]
        let sessions = SessionsModel(provider: testEvent).sessions(firstDay).toArray()

        XCTAssertEqual(sessions[0], firstSession)
    }
}

