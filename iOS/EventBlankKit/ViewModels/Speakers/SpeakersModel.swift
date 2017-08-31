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

import UIKit

import RealmSwift
import RxSwift

class SpeakersModel {
    private let provider: RealmProvider
    init(provider: RealmProvider = .event) {
        self.provider = provider
    }

    func speakers(searchTerm term: String = "") -> Observable<[Speaker]> {
        // filter speakers
        var filterFormat = "%K == %@"
        var variables: [Any] = [Speaker.keyVisible, true]

        if !term.isEmpty {
            filterFormat += " AND %K contains[c] %@"
            variables += [Speaker.keyName, term]
        }

        let predicate = NSPredicate(
            format: filterFormat,
            argumentArray: variables)

        // return speakers observable
        return Observable.array(from:
            provider.realm.objects(Speaker.self)
                .filter(predicate)
                .sorted(byKeyPath: Speaker.keyName))
    }
}
