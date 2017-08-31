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

public class SessionCellViewModel: BaseViewModel {

    private lazy var favoritesModel: FavoritesModel = {
        FavoritesModel.default(provider: self.provider)
    }()
    private let bag = DisposeBag()
    private var reuseBag = DisposeBag()
    private let provider: RealmProvider

    public private(set) var session: Session!

    // MARK: output
    public var isFavorite: Observable<Bool> {
        return self.favoritesModel.sessions
            .map { favorites in
                favorites.contains(self.session.uuid)
            }
    }

    public var isFavoriteSpeaker: Observable<Bool> {
        return self.favoritesModel.speakers
            .map { favorites in
                favorites.contains(self.session.speaker?.uuid ?? "")
        }
    }

    private let _didChange = PublishSubject<Void>()
    public lazy var didChange: Observable<Void> = {
        return self._didChange.asObservable()
    }()

    private func detectDeepChanges() {
        reuseBag = DisposeBag()

        var collection = Array<Observable<Bool>>()
        collection.append(Observable.from(object: session).map {_ in true})
        if let track = session.track {
            collection.append(Observable.from(object: track).map {_ in true})
        }
        if let location = session.location {
            collection.append(Observable.from(object: location).map {_ in true})
        }
        if let speaker = session.speaker {
            collection.append(Observable.from(object: speaker).map {_ in true})
        }

        Observable.combineLatest(collection)
            .skip(1)
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?._didChange.onNext(())
                self?.detectDeepChanges()
            })
            .disposed(by: reuseBag)
    }

    public init(provider: RealmProvider = .app, with session: Session) {
        self.provider = provider
        self.session = session
        super.init()
        detectDeepChanges()
    }

    public func updateIsFavorite(isFavorite: Bool) {
        favoritesModel.updateSessionFavoriteTo(session, to: isFavorite)
    }

    
}
