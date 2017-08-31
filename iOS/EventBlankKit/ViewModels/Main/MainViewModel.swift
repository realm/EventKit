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

import Foundation

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

public class MainViewModel {

    internal lazy var schedule: Schedule = {
        return Schedule(provider: self.provider)
    }()

    private let provider: RealmProvider

    // MARK: output
    public let timer = Observable<NSInteger>.interval(1, scheduler: MainScheduler.instance)
    public lazy var eventData: Observable<EventData> = {
        return Observable.from(object: EventData.default(in: self.provider))
    }()
    public var nextSession: Schedule.NextEventResult {
        return self.schedule.nextEvent()
    }

    // MARK: init
    public init(provider: RealmProvider = .event) {
        self.provider = provider
    }
}
