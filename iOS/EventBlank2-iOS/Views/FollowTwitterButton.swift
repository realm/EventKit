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

enum FollowingOnTwitter {
    case checking, sendingRequest, na
    case notFollowing(String)
    case following(String)
}

class FollowTwitterButton: UIButton {

    fileprivate let bag = DisposeBag()
    
    // MARK: input
    let isFollowing = PublishSubject<FollowingOnTwitter>()
    
    // MARK: life cycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard superview != nil else {
            return
        }
        
        setupUI()
        bindUI()
    }
    
    func setupUI() {
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        backgroundColor = UIColor.white
    }

    func bindUI() {
        isFollowing.map(colorForFollowState)
            .map { $0.cgColor }
            .bind(to: layer.rx.borderColor)
            .disposed(by: bag)
        
        isFollowing.map(titleForFollowState)
            .subscribe(onNext: {[weak self] title in
                self?.setTitle(title, for: .normal)
            })
            .disposed(by: bag)
        
        isFollowing.map(colorForFollowState)
            .subscribe(onNext: {[weak self] color in
                self?.setTitleColor(color, for: .normal)
            })
            .disposed(by: bag)
    }
    
    // MARK: private
    fileprivate func colorForFollowState(_ state: FollowingOnTwitter) -> UIColor {
        switch state {
            case .checking: return UIColor.orange
            case .notFollowing: return UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
            case .sendingRequest: return UIColor.darkGray
            case .following: return UIColor.blue
            case .na: return UIColor.lightGray
        }
    }
    
    fileprivate func titleForFollowState(_ state: FollowingOnTwitter) -> String {
        switch state {
            case .checking: return "Checking..."
            case .notFollowing(let username): return "  Follow \(username) on twitter "
            case .sendingRequest: return "Sending request..."
            case .following(let username): return "  Following \(username)  "
            case .na: return "  n/a  "
        }
    }
    
}
