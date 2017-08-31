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

class SpeakerModelTests : XCTestCase {

    func test_getsSpeakers_whenGivenSearchTerm() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let speaker = testEvent.realm.objects(Speaker.self)[0]

        let items = SpeakersModel(provider: testEvent).speakers()
            .observeOn(MainScheduler.instance)
            .map { $0.count }
            .toBlocking()

        let first = try! items.first()!
        XCTAssertEqual(testEvent.realm.objects(Speaker.self).count, first)

        let items2 = SpeakersModel(provider: testEvent).speakers(searchTerm: "marin")
            .observeOn(MainScheduler.asyncInstance)
            .map { $0.count }
            .toBlocking()

        let second = try! items2.first()!
        XCTAssertEqual(0, second)

        try! testEvent.realm.write {
            speaker.name = "marin todorov"
        }

        let third = try! items2.first()!
        XCTAssertEqual(1, third)

        try! testEvent.realm.write {
            speaker.name = "test test"
        }

        let fourth  = try! items2.first()!
        XCTAssertEqual(0, fourth)
    }
}

