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
import RxRealm

private extension Array {
    func appending(_ value: Element) -> Array<Element> {
        return self + [value]
    }
}

private func reduceIds(_ ids: List<ObjectId>) -> [String] {
    return ids.reduce([String](), { (result, id) in
        return result.appending(id.id)
    })
}

public class FavoritesModel {
    private let provider: RealmProvider

    public static func `default`(provider: RealmProvider = .app) -> FavoritesModel {
        return FavoritesModel(provider: provider)
    }

    private let bag = DisposeBag()
    private let favorites: Favorites

    public var sessions: Observable<[String]> {
        return Observable.collection(from: favorites.sessions).map(reduceIds)
    }
    public var speakers: Observable<[String]> {
        return Observable.collection(from: favorites.speakers).map(reduceIds)
    }

    private init(provider: RealmProvider = .app) {
        self.provider = provider
        favorites = provider.realm.objects(Favorites.self).first!
    }
    
    public func updateSessionFavoriteTo(_ session: Session, to: Bool) {
        //remove favorite
        if to == false, let object = favorites.sessions.filter("id = %@", session.uuid).first {
            try! provider.realm.write {
                provider.realm.delete(object)
            }
            return
        }
        
        //add favorite
        if to, favorites.sessions.filter("id = %@", session.uuid).first == nil {
            try! provider.realm.write {
                let oid = provider.realm.objects(ObjectId.self).filter("id = %@", session.uuid).first ?? ObjectId(id: session.uuid)
                favorites.sessions.append(oid)
            }
        }
    }

    public func updateSpeakerFavoriteTo(_ speaker: Speaker, to: Bool) {
        //remove favorite
        if to == false, let object = favorites.speakers.filter("id = %@", speaker.uuid).first {
            try! provider.realm.write {
                provider.realm.delete(object)
            }
            return
        }
        
        //add favorite
        if to, favorites.speakers.filter("id = %@", speaker.uuid).first == nil {
            try! provider.realm.write {
                let oid = ObjectId(id: speaker.uuid)
                favorites.speakers.append(oid)
            }
        }
    }
}
