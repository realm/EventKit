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
import Social

extension UIViewController {

    @discardableResult
    static func alert(_ message: String, buttons: [String] = ["OK"], completion: ((Int)->Void)?) -> UIAlertController {
        return (UIApplication.shared.windows.first!).rootViewController!.alert(message, buttons: buttons, completion: completion)
    }

    @discardableResult
    func alert(_ message: String, buttons: [String] = ["OK"], completion: ((Int)->Void)?) -> UIAlertController {
        
        let alertVC = UIAlertController(title: "",
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)
        
        for i in 0..<buttons.count {
            let btnAction = UIAlertAction(title: buttons[i], style: UIAlertActionStyle.default, handler: {_ in
                completion?(i)
            })
            alertVC.addAction(btnAction)
        }
        
        present(alertVC, animated: true, completion: nil)
        
        return alertVC
    }

    func tweet(_ message: String, image: UIImage? = nil, urlString: String? = nil, completion: ((Bool)->Void)?) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            
            let composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            composer?.setInitialText(message)
            
            if let image = image {
                composer?.add(image)
            }
            
            if let urlString = urlString, let url = URL(string: urlString) {
                composer?.add(url)
            }
            
            composer?.completionHandler = {result in
                composer?.dismiss(animated: true, completion: nil)
                completion?(result == SLComposeViewControllerResult.done)
            }
            
            present(composer!, animated: false, completion: nil)
        }

    }
}
