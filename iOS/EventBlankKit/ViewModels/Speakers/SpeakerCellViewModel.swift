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

public class SpeakerCellViewModel: BaseViewModel {

    private let bag = DisposeBag()
    private let provider: RealmProvider

    private lazy var favoritesModel: FavoritesModel = {
        FavoritesModel.default(provider: self.provider)
    }()

    // MARK: input
    public private(set) var speaker: Speaker!

    // MARK: output
    public var isFavorite: Observable<Bool> {
        return self.favoritesModel.speakers
            .map { favorites in
                favorites.contains(self.speaker.uuid)
        }
    }

    public init(provider: RealmProvider = .app ,with speaker: Speaker) {
        self.provider = provider
        self.speaker = speaker
        super.init()
    }

    public func updateIsFavorite(isFavorite: Bool) {
        favoritesModel.updateSpeakerFavoriteTo(speaker, to: isFavorite)
    }
}
