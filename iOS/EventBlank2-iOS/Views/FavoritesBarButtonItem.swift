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

import RxSwift
import RxCocoa

import EventBlankKit

class FavoritesBarButtonItem: UIBarButtonItem {

    private let bag = DisposeBag()
    private(set) var button: UIButton!
    private static let kTagBg = 1000

    static func instance() -> FavoritesBarButtonItem {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        button.setImage(UIImage(named: "like-empty")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState())
        button.setImage(UIImage(named: "like-full")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState.selected)
        button.tintColor = UIColor.white
        button.backgroundColor = EventData.default(in: RealmProvider.event).mainColor

        let bg = UIView()
        bg.tag = kTagBg
        bg.backgroundColor = EventData.default(in: RealmProvider.event).mainColor
        bg.frame = CGRect(x: 0, y: 0, width: 100, height: button.frame.size.height)

        let view = UIView()
        view.frame = button.frame
        view.addSubview(bg)
        view.addSubview(button)

        let barItem = FavoritesBarButtonItem(customView: view)
        barItem.button = button
        barItem.bindUI()
        return barItem
    }

    func updateBackgroundColor() {
        button.backgroundColor = EventData.default(in: RealmProvider.event).mainColor
        customView?.viewWithTag(FavoritesBarButtonItem.kTagBg)?.backgroundColor = EventData.default(in: RealmProvider.event).mainColor
    }

    func bindUI() {
        precondition(button != nil)
        
        button.rx.tap
            .do(onNext: { [weak self] _ in
                self?.button.animateSelect(scale: 0.8, completion: nil)
            })
            .subscribe()
            .disposed(by: bag)
    }
    
    var selected: Bool {
        get {
            return button.isSelected
        }
        set {
            button.isSelected = newValue
        }
    }
}

extension Reactive where Base: FavoritesBarButtonItem {
    var isSelected: AnyObserver<Bool> {
        get {
            return base.button.rx.isSelected.asObserver()
        }
    }
}
