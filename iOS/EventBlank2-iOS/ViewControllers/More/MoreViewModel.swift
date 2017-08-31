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

import RxSwift
import RxCocoa
import RxDataSources
import RxRealm

import RealmContent

import EventBlankKit

class MoreViewModel: BaseViewModel {
    
    private let bag = DisposeBag()
    
    //output

    let tableItems: Observable<[AnySection]> = {
        let dataSource = ContentListDataSource(style: .plain)
        dataSource.loadContent(from: RealmProvider.event.realm)

        let morePages = dataSource.asResults().filter("tag = %@", "more")

        // dynamc pages
        return Observable.array(from: morePages)
            .map { (pages: Array<ContentPage>) -> [AnySection] in
                return [AnySection(model: "", items: pages)]
            }
    }()

    override func didActivate() {
        // nothing
    }
}
