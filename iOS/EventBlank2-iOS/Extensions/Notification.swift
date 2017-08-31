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

extension NSObject {
    
    func observeNotification(_ name: String, selector: Selector?) {
        if let selector = selector {
            NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: name), object: nil)
        }
    }
    
    func notification(_ name: String, object: AnyObject? = nil) {
        if let dict = object as? NSDictionary {
            NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil, userInfo: dict as? [AnyHashable : Any])
        } else if let object: AnyObject = object {
            NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil, userInfo: ["object": object])
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil, userInfo: nil)
        }
    }
    
}
