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

import RxDataSources

extension Collection where Self.Iterator.Element: IdentifiableType & Equatable {
    
    public typealias ItemType = Self.Iterator.Element
    public typealias SectionItemType = AnimatableSectionModel<String, ItemType>
    
    public func breakIntoSections(_ breakCondition: (ItemType, ItemType?) -> String?) -> [SectionItemType] {
        
        var items: [SectionItemType] = []
        var currentSectionItems: [ItemType] = []
        
        var index = self.startIndex
        while index != endIndex {
            currentSectionItems.append(self[index])
            
            let nextItem: Self.Iterator.Element? = self.distance(from: index, to: endIndex) > 1 ? self[self.index(after: index)] : nil
            
            if let newSectionTitle = breakCondition(self[index], nextItem) {
                //add section
                items.append(SectionItemType(model: newSectionTitle, items: currentSectionItems))
                
                //reset current items
                currentSectionItems = []
            }
            
            index = self.index(after: index)
        }

        return items
    }
}
