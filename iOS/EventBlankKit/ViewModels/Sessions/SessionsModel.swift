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

class SessionsModel {

    private let provider: RealmProvider
    init(provider: RealmProvider = .event) {
        self.provider = provider
    }

    func sessions(_ day: Schedule.Day) -> Results<Session> {
        let predicate = NSPredicate(
            format: "%K >= %@ AND %K <= %@ AND %K == %@",
            argumentArray: [Session.keyBeginTime, day.startTime,
                            Session.keyBeginTime, day.endTime,
                            Session.keyVisible, true])

        return provider.realm.objects(Session.self)
            .filter(predicate)
            .sorted(byKeyPath: Session.keyBeginTime)
    }
}
