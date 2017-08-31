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

public struct FilePath: CustomStringConvertible {
    
    //MARK: - properties
    
    var filePath: String
    var url: URL {
        return URL(fileURLWithPath: filePath)
    }
    
    public var description: String { return String(describing: self.filePath) }

    //MARK: - conveniece inits
    
    init(_ path: String) {
        filePath = path
    }

    init(_ url: URL) {
        filePath = url.absoluteString
    }

    init(inDocuments fileName: String) {
        filePath = type(of: self).inDocuments(fileName)
    }
    
    init(inLibrary fileName: String) {
        filePath = type(of: self).inLibrary(fileName)
    }
    
    init?(inBundle fileName: String) {
        if let existingFile = type(of: self).inBundle(fileName) {
            filePath = existingFile
        } else {
            return nil
        }
    }
    
    //MARK: - internal string path functions
    
    static func inDocuments(_ fileName: String) -> String {
        let folderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return folderPath + ("/"+fileName)
    }
    
    static func inLibrary(_ fileName: String) -> String {
        let folderPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        return folderPath + ("/"+fileName)
    }
    
    static func inBundle(_ fileName: String) -> String? {
        return Bundle.main.path(forResource: fileName, ofType: nil)
    }
    
    //MARK: - compare modification dates
    func isItemNewerThanItemAtPath(_ toPath: FilePath) -> Bool {
        
        let manager = FileManager.default
        
        if  let atAttributes = try? manager.attributesOfItem(atPath: self.filePath),
            let atModDate = atAttributes[FileAttributeKey.modificationDate] as? Date,
            let toAttributes = try? manager.attributesOfItem(atPath: toPath.filePath),
            let toModDate = toAttributes[FileAttributeKey.modificationDate] as? Date
        {
            return atModDate.compare(toModDate) == ComparisonResult.orderedDescending
        } else {
            return false
        }
    }
    
    //MARK: - copy functions
    
    func copyOnceTo(_ toPath: FilePath) throws {
        let manager = FileManager.default
        
        if manager.fileExists(atPath: toPath.filePath) == false {
            print("copy \(self) to \(toPath)")
            try copyAndReplaceItemToPath(toPath)
        }
    }
    
    func copyIfNewer(_ toPath: FilePath) throws {
        if isItemNewerThanItemAtPath(toPath) {
            try copyAndReplaceItemToPath(toPath)
        }
    }
    
    func copyAndReplaceItemToPath(_ toPath: FilePath) throws {
        let manager = FileManager.default
        
        if manager.fileExists(atPath: toPath.filePath) {
            print("file exists! delete it first")
            
            do {
                try manager.removeItem(atPath: toPath.filePath)
            } catch let error as NSError {
                print("failed to delete file: \(error.description)")
                throw error
            }
        }
        
        do {
            try manager.copyItem(atPath: self.filePath, toPath: toPath.filePath)
        } catch let error as NSError {
            print("failed to copy file: \(error.description)")
            throw error
        }
    }
}
