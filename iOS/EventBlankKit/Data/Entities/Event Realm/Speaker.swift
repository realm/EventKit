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
import RxDataSources

public class Speaker: Object {
    public static let keyName = "name"
    public static let keyVisible = "visible"

    @objc public dynamic var uuid = UUID().uuidString
    @objc public dynamic var visible = false
    
    @objc public dynamic var name = ""
    @objc public dynamic var bio: String?
    @objc public dynamic var url: String?
    @objc public dynamic var twitter: String?
    
    @objc public dynamic var photoUrl: String?
    
    override public class func primaryKey() -> String {
        return "uuid"
    }
}

extension Speaker: IdentifiableType {
    public var identity: Int {
        return self.isInvalidated ? 0 : uuid.hashValue
    }
}

