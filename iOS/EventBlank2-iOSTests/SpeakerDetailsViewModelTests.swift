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

class SpeakerDetailsViewModelTests : XCTestCase {

    func test_storesSpeaker_whenInitialized() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let speaker = testEvent.realm.objects(Speaker.self)[0]
        let model = SpeakerDetailsViewModel(speaker: speaker)

        XCTAssertEqual(model.speaker, speaker)
    }

    func test_emitsTableItems_whenSpeakerUpdated() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let speaker = testEvent.realm.objects(Speaker.self)[0]
        try! testEvent.realm.write {
            speaker.name = "speaker name"
        }

        let model = SpeakerDetailsViewModel(speaker: speaker)
        let items = model.tableItems.asObservable()
            .map { return $0[0].items[0].name }
            .subscribeOn(MainScheduler.instance)

        let first = try! items.toBlocking().first()!
        XCTAssertEqual("speaker name", first)

        try! testEvent.realm.write {
            speaker.name = "changed name"
        }

        let second = try! items.toBlocking().first()!
        XCTAssertEqual("changed name", second)
    }
}

