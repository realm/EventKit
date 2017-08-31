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

class SpeakerCellViewModelTests : XCTestCase {

    func test_storesSpeaker_whenInitialized() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        let speaker = testEvent.realm.objects(Speaker.self)[0]
        let model = SpeakerCellViewModel(provider: testApp, with: speaker)

        XCTAssertEqual(model.speaker, speaker)
    }

    func test_emitsIsFavorite_whenFavoritesToggled() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let speaker = testEvent.realm.objects(Speaker.self)[0]

        let model = SpeakerCellViewModel(provider: testApp, with: speaker)
        let items = model.isFavorite.asObservable()
            .subscribeOn(MainScheduler.instance)
            .shareReplay(1)

        DispatchQueue.main.async {
            model.updateIsFavorite(isFavorite: true)
        }

        let result = try! items.take(2).toBlocking().toArray()
        XCTAssertEqual([false, true], result)
    }
}

