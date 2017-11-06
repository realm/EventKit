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

public typealias SpeakerSection = AnimatableSectionModel<String, Speaker>

public class SpeakersViewModel: BaseViewModel {
    
    private let bag = DisposeBag()
    private let appProvider: RealmProvider
    private let eventProvider: RealmProvider

    private lazy var favoritesModel: FavoritesModel = {
        FavoritesModel.default(provider: self.appProvider)
    }()
    private let _speakers = PublishSubject<[SpeakerSection]>()
    private lazy var appState: AppState = {
        AppState.default(in: self.appProvider)
    }()

    //
    // MARK: input
    //
    public let searchTerm = Variable<String>("")

    //
    // MARK: output
    //

    public let onlyFavorites = BehaviorRelay<Bool>(value: false)
    public lazy var speakers: Observable<[SpeakerSection]> = {
        return self._speakers.asObservable()
    }()
    
    //
    // MARK: init
    //
    public init(eventProvider: RealmProvider = .event, appProvider: RealmProvider = .app) {
        self.appProvider = appProvider
        self.eventProvider = eventProvider
        super.init()
    }

    override public func didActivate() {
        //generate the speaker list
        let search = searchTerm.asObservable()
            .throttle(0.1, scheduler: MainScheduler.instance)
            .flatMap {[weak self] search -> Observable<[Speaker]> in
                guard let this = self else { return Observable<[Speaker]>.empty() }
                return SpeakersModel(provider: this.eventProvider).speakers(searchTerm: search)
            }
            .distinctUntilChanged(distinctSpeakerFilter)
        
        Observable.combineLatest(search, onlyFavorites.asObservable(), favoritesModel.speakers) { results, onlyFavs, favoriteSpeakers -> [Speaker] in
            guard onlyFavs == true else {
                return results
            }
            
            return results.filter {speaker in
                favoriteSpeakers.contains(speaker.uuid)
            }
        }
        .map {[unowned self] speakers in
            return speakers.breakIntoSections(self.sectionTitleWithSpeakers)
        }
        .bind(to: _speakers)
        .disposed(by: bag)

        // onlyFavorites -> AppState
        Observable.from(object: appState)
            .map { $0.speakersOnlyFavorites }
            .bind(onNext: onlyFavorites.accept)
            .disposed(by: bag)
    }

    public func updateOnlyFavorites(to: Bool) {
        let appState = AppState.default(in: appProvider)
        try! appState.realm?.write {
            appState.speakersOnlyFavorites = to
        }
    }

    //
    // MARK: private methods
    //
    private func distinctSpeakerFilter(_ list1: [Speaker], list2: [Speaker]) -> Bool {
        return list1.count == list2.count //just good enough implementation
    }
    
    private func sectionTitleWithSpeakers(_ speaker1: Speaker, speaker2: Speaker?) -> String? {
        guard let speaker2 = speaker2 else {
            return String(speaker1.name[0])
        }

        let h1 = String(speaker1.name[0])
        let h2 = String(speaker2.name[0])

        if h1 == h2 {
            return nil
        }

        return h1
    }

}
