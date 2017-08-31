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

import RxSwift
import RxCocoa
import RxDataSources

public class SpeakerDetailsViewModel: BaseViewModel {

    private let bag = DisposeBag()
    private let provider: RealmProvider

    private lazy var favoritesModel: FavoritesModel = {
        FavoritesModel.default(provider: self.provider)
    }()

    public private(set) var speaker: Speaker!

    // MARK: - Output
    public let tableItems = BehaviorSubject<[SpeakerSection]>(value: [])

    //init
    public init(provider: RealmProvider = .app, speaker: Speaker) {
        self.speaker = speaker
        self.provider = provider

        super.init()

        //bind table items
        Observable.from(object: speaker)
            .map { speaker -> [SpeakerSection] in
                return [SpeakerSection(model: "speaker details", items: [speaker])]
            }
            .bind(to: tableItems)
            .disposed(by: bag)
    }
}
