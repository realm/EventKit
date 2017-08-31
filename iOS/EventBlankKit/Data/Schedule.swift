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
import AFDateHelper

public class Schedule {
    public struct Day {
        public let startTime: Date
        public let endTime: Date
        public let text: String
    }

    private let provider: RealmProvider
    public init(provider: RealmProvider = .event) {
        self.provider = provider
    }

    internal lazy var shortStyleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = .short
        formatter.dateFormat = .none
        formatter.timeZone = TimeZone(abbreviation: EventData.default(in: self.provider).timeZone)
        return formatter
    }()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "EE, MMM dd"
        dateFormatter.timeZone = TimeZone(abbreviation: EventData.default(in: self.provider).timeZone)
        return dateFormatter
    }()
    
    public func dayRanges() -> [Day] {
        let sessions = provider.realm.objects(Session.self).sorted(byKeyPath: "beginTime", ascending: true)
        
        precondition(sessions.first!.beginTime != nil)
        
        let eventBeginDate = sessions.first!.date
        let eventEndDate = sessions.last!.date
        
        let nrOfDays = eventEndDate.since(eventBeginDate, in: .day)
        
        return (0...nrOfDays).map { i in
            let dayDate = eventBeginDate.adjust(.day, offset: Int(i))
            return Day(
                startTime: dayDate.dateFor(.startOfDay),
                endTime: dayDate.dateFor(.endOfDay),
                text: dateFormatter.string(from: dayDate))
        }
    }
    
    public enum NextEventResult {
        case next(Session)
        case eventStartsIn(TimeInterval)
        case eventFinished
    }
    
    public func nextEvent(_ date: Date = Date()) -> NextEventResult {
        let sessions = provider.realm.objects(Session.self).filter("beginTime > %@", date).sorted(byKeyPath: "beginTime", ascending: true)
        guard let nextSession = sessions.first else {
            return .eventFinished
        }
        let allSessions = provider.realm.objects(Session.self).sorted(byKeyPath: "beginTime", ascending: true)
        if allSessions.first!.uuid == nextSession.uuid {
            return .eventStartsIn(nextSession.date.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate)
        }
        return .next(nextSession)
    }
}
