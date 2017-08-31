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
import SwiftSpinner

class DefaultViewController: UIViewController {

    func startConnecting() {
        DispatchQueue.main.async {
            SwiftSpinner.sharedInstance.clearTapHandler()
            SwiftSpinner.show("Initial connect...")
        }
    }

    func startInitialData() {
        DispatchQueue.main.async {
            SwiftSpinner.show("Getting initial data...")
        }
    }

    func stopConnecting(completion: @escaping ()->Void) {
        DispatchQueue.main.async {
            SwiftSpinner.hide(completion)
        }
    }

    func updateProgress(_ progress: Double) {
        DispatchQueue.main.async {
            SwiftSpinner.show(progress: progress, title: progress > 0.99 ? "Waiting for initial data" : "Downloading...")
        }
    }

    func showError(_ text: String, completion: @escaping ()->Void) {
        DispatchQueue.main.async {
            SwiftSpinner.show(text)
            SwiftSpinner.sharedInstance.addTapHandler(completion, subtitle: "Try connecting one more time")
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
