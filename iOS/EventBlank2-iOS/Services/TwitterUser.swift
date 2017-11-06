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
import SwiftyJSON
import Kingfisher

class TwitterUser: Object {
    
    @objc dynamic var id: Int32 = 0
    @objc dynamic var name = ""
    @objc dynamic var username = ""
    
    @objc dynamic var _avatarUrl: String?
    
    var avatarUrl: URL? {
        set {
            _avatarUrl = newValue?.absoluteString
        }
        get {
            guard let avatarUrl = _avatarUrl else {
                return nil
            }
            return URL(string: avatarUrl)
        }
    }

    static override func primaryKey() -> String {
        return "id"
    }
    
    static override func ignoredProperties() -> [String] {
        return ["avatarUrl"]
    }
    
    convenience init?(jsonObject obj: JSON) {
        self.init()
        
        //required properties
        guard let name = obj["name"].string,
            let id = obj["id"].int32,
            let username = obj["screen_name"].string,
            let avatarUrlString = obj["profile_image_url_https"].string,
            let avatarUrl = URL(string: avatarUrlString)
            else {
                return nil
        }
        
        self.name = name
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        
        ImagePrefetcher(urls: [avatarUrl]).start()
    }
    
}
