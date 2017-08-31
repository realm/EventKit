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

class MainViewModelTests : XCTestCase {

    func test_eventDataEmits_whenChanged() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let model = MainViewModel(provider: testEvent)

        let eventData = model.eventData.asObservable().subscribeOn(MainScheduler.instance)
        let data = testEvent.realm.objects(EventData.self).first!

        try! testEvent.realm.write {
            data.title = "changed name"
        }

        let emittedTitles = try! eventData.toBlocking().first()

        XCTAssertEqual("changed name", emittedTitles!.title)
    }

    func test_timerEmits_whenSubscribed() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let model = MainViewModel(provider: testEvent)

        let timer = model.timer.asObservable().subscribeOn(MainScheduler.instance)
        XCTAssertEqual([0,1,2,3,4], try! timer.take(5).toBlocking().toArray())
    }
    
    func test_nextEventCurrent_whenAccessed() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let model = MainViewModel(provider: testEvent)

        let session = testEvent.realm.objects(Session.self)[0]
        let session2 = testEvent.realm.objects(Session.self)[1]

        try! testEvent.realm.write {
            session.beginTime = Date()
            session.lengthInMinutes = 45
            session2.beginTime = Date().adjust(.hour, offset: 1)
            session2.lengthInMinutes = 45
        }

        let beforeFirst = model.schedule.nextEvent( Date().adjust(.hour, offset: -1) )
        if case .eventStartsIn = beforeFirst {
            XCTAssertTrue(true)
        } else {
            XCTAssertTrue(false, "Didn't get about to start")
        }

        let nextEvent = model.schedule.nextEvent(Date().adjust(.minute, offset: 30))
        if case .next(let nextSession) = nextEvent {
            XCTAssertTrue(nextSession.title == session2.title)
        } else {
            XCTAssertTrue(false, "Didn't get the next session")
        }

        let beyondLast = model.schedule.nextEvent( Date().adjust(.hour, offset: 5) )
        if case .eventFinished = beyondLast {
            XCTAssertTrue(true)
        } else {
            XCTAssertTrue(false, "Didn't get finished")
        }

    }
}

