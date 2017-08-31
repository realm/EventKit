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

private func countSpeakers(in sections: [SpeakerSection]) -> Int {
    return sections.reduce(0, { (acc, section) -> Int in
        return acc + section.items.count
    })
}

class SpeakerViewModelTests : XCTestCase {

    func test_emitsFavoritesSpeakers_whenFavoritesToggled() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let model = SpeakersViewModel(eventProvider: testEvent, appProvider: testApp)
        model.activate()

        let items = model.speakers
            .subscribeOn(MainScheduler.asyncInstance)
            .toBlocking(timeout: 5)

        let sid = testEvent.realm.objects(Speaker.self)[0].uuid

        DispatchQueue.main.async {
            model.updateOnlyFavorites(to: true)
        }
        let first = try! items.first()!
        XCTAssertEqual(0, countSpeakers(in: first))

        DispatchQueue.main.async {
            //favorite a Speaker
            let speaker = testEvent.realm.object(ofType: Speaker.self, forPrimaryKey: sid)!
            FavoritesModel.default(provider: testApp).updateSpeakerFavoriteTo(speaker, to: true)
        }
        let second = try! items.first()!
        XCTAssertEqual(1, countSpeakers(in: second))

        DispatchQueue.global(qos: .background).async {
            //un-favorite a Speaker
            let speaker = testEvent.realm.object(ofType: Speaker.self, forPrimaryKey: sid)!
            FavoritesModel.default(provider: testApp).updateSpeakerFavoriteTo(speaker, to: false)
        }
        let third = try! items.first()!
        XCTAssertEqual(0, countSpeakers(in: third))
    }

    func test_emitsSpeakersResults_whenSearchTermGiven() {
        let testApp = TestingRealm.mockApp()
        let testEvent = TestingRealm.mockEvent()
        TestingRealm.createDataSet1(app: testApp, event: testEvent)

        //create the model
        let model = SpeakersViewModel(eventProvider: testEvent, appProvider: testApp)
        model.activate()

        let items = model.speakers.asObservable()
            .subscribeOn(MainScheduler.instance)
            .map(countSpeakers)
            .toBlocking()

        DispatchQueue.main.async {
            model.searchTerm.value = "test"
        }
        let first = try! items.first()!
        XCTAssertEqual(0, first)

        DispatchQueue.main.async {
            model.searchTerm.value = "speaker"
        }
        let second = try! items.first()!
        XCTAssertEqual(1, second)
    }

}

