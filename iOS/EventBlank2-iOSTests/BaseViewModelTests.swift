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

class BaseViewModelTests : XCTestCase {
    func test_emitsActive_whenActivated() {
        let model = BaseViewModel()

        let items = model.active.asObservable()
            .subscribeOn(MainScheduler.instance)
            .share(replay: 1)

        DispatchQueue.main.async {
            model.activate()
        }

        let result = try! items.take(1).toBlocking().toArray()
        XCTAssertEqual([true], result)
    }

    func test_emitsActive_whenSubclassed() {
        class TestBaseViewModel: BaseViewModel {
            var activated = false
            override func didActivate() {
                activated = true
            }
        }

        let model = TestBaseViewModel()

        let items = model.active.asObservable()
            .subscribeOn(MainScheduler.instance)
            .share(replay: 1)

        DispatchQueue.main.async {
            model.activate()
        }

        let result = try! items.take(1).toBlocking().toArray()
        XCTAssertEqual([true], result)
        XCTAssertTrue(model.activated)
    }
}

