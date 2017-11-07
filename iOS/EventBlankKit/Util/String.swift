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

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return String(self[index(startIndex, offsetBy: r.lowerBound) ..< index(startIndex, offsetBy: r.upperBound)])
    }
}

extension String {
    public func contains(_ substring: String,
        ignoreCase: Bool = false,
        ignoreDiacritic: Bool = false) -> Bool {
            
            if substring == "" { return true }
            var options = NSString.CompareOptions()
            
            if ignoreCase { options.insert(.caseInsensitive) }
            if ignoreDiacritic { options.insert(.diacriticInsensitive) }
            
            return range(of: substring, options: options) != nil
    }
}
