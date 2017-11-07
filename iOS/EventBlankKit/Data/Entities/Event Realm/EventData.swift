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
import NSString_Color
import DynamicColor

public class EventData: Object {

    @objc public dynamic var title = ""
    @objc public dynamic var subtitle = ""
    @objc public dynamic var organizer = ""
    @objc public dynamic var logoUrl: String?
    @objc public dynamic var timeZone = "GMT"

    @objc internal dynamic var _mainColor = ""
    public var mainColor: UIColor {
        get {
            return _mainColor.representedColor() ?? UIColor.black
        }
        set {
            _mainColor = newValue.toHexString()
        }
    }
    
    //methods
    public static func `default`(in provider: RealmProvider = .event) -> EventData {
        return provider.realm.objects(EventData.self).first!
    }

    override public class func ignoredProperties() -> [String] {
        return ["mainColor"]
    }
}

extension EventData {
    var isValid: Bool {
        return !title.isEmpty && !subtitle.isEmpty && !organizer.isEmpty && !timeZone.isEmpty
    }
}
