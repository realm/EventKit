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
import UIKit

import MAThemeKit
import EventBlankKit

import RxSwift
import RxRealm

class AppTheme {

    private let bag = DisposeBag()

    init(event: EventData, window: UIWindow) {
        window.backgroundColor = UIColor.white

        Observable.from(object: event)
            .bind(onNext: setupUI)
            .disposed(by: bag)
    }

    private func setupUI(event: EventData) {
        let primaryColor = event.mainColor

        MAThemeKit.customizeNavigationBarColor(primaryColor, textColor: UIColor.white, buttonColor: UIColor.white)
        MAThemeKit.customizeButtonColor(primaryColor)
        MAThemeKit.customizeSwitch(on: primaryColor)
        MAThemeKit.customizeActivityIndicatorColor(primaryColor)
        MAThemeKit.customizeSegmentedControl(withMainColor: UIColor.white, secondaryColor: primaryColor)
        MAThemeKit.customizeSliderColor(primaryColor)
        MAThemeKit.customizePageControlCurrentPageColor(primaryColor)
        MAThemeKit.customizeTabBarColor(UIColor.white.mixedRGB(withColor: primaryColor, weight: 0.025), textColor: primaryColor)
    }

}
