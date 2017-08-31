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
import RxRealm

import RealmSwift

public typealias SessionSection = AnimatableSectionModel<String, Session>

public class SessionsViewModel: BaseViewModel {

    private let bag = DisposeBag()
    private let _sessions = PublishSubject<[SessionSection]>()
    private lazy var favoritesModel: FavoritesModel = {
        FavoritesModel.default(provider: self.appProvider)
    }()
    private(set) var appState: AppState!
    private let eventProvider: RealmProvider
    private let appProvider: RealmProvider

    private lazy var shortStyleDateFormatter: DateFormatter = {
        Schedule(provider: self.eventProvider).shortStyleDateFormatter
    }()

    // MARK: input
    public private(set) var day: Schedule.Day!

    //
    // MARK: output
    //
    public let onlyFavorites = PublishSubject<Bool>()
    public lazy var sessions: Observable<[SessionSection]> = {
        return self._sessions.asObservable()
    }()

    //
    // MARK: init
    //
    public init(eventProvider: RealmProvider = .event, appProvider: RealmProvider = .app, day: Schedule.Day) {
        self.eventProvider = eventProvider
        self.appProvider = appProvider
        self.day = day
        self.appState = AppState.default(in: appProvider)
        super.init()
    }

    override public func didActivate() {
        // input
        let daySessions = Observable.array(from: SessionsModel(provider: eventProvider).sessions(day))

        // bind sessions
        Observable.combineLatest(onlyFavorites.asObservable(), daySessions, favoritesModel.sessions) { (onlyFavorites, sessions, sessionFavorites) -> [Session] in
            //no filtering
            guard onlyFavorites else { return sessions }

            // filtering
            return sessions.filter { session in
                return sessionFavorites.contains(session.uuid)
            }
        }
        .map { results in
            return results.breakIntoSections(self.sectionTitleWithSessions)
        }
        .bind(to: _sessions)
        .disposed(by: bag)

        // onlyFavorites -> AppState
        Observable.from(object: appState)
            .map { $0.scheduleOnlyFavorites }
            .bind(onNext: onlyFavorites.onNext)
            .disposed(by: bag)
    }

    //
    // MARK: private methods
    //
    private func updateOnlyFavorites(only: Bool) {
        try! appProvider.realm.write {
            AppState.default(in: appProvider).scheduleOnlyFavorites = only
        }
    }

    private func distinctCountFilter(_ list1: [Session], list2: [Session]) -> Bool {
        return list1.count == list2.count //just good enough implementation
    }

    private func sectionTitleWithSessions(_ session1: Session, session2: Session?) -> String? {
        guard let session2 = session2 else {
            return shortStyleDateFormatter.string(from: session1.date)
        }
        
        return shortStyleDateFormatter.string(from: session1.date) != shortStyleDateFormatter.string(from: session2.date)
            ? shortStyleDateFormatter.string(from: session1.date)
            : nil
    }

}
