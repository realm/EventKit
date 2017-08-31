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

class ContainerMessageView: UIView {
    
    // MARK: input
    private var message = ""

    private let bg = UIView()
    private let label = UILabel()
    private let button = UIButton(type: .custom)
    
    // MARK: output
    private var tapHandler: (()->Void)?
    
    private let bag = DisposeBag()
    
    convenience init(text: String) {
        self.init()
        message = text

        bg.backgroundColor = .white
        addSubview(bg)

        label.text = text
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.white
        addSubview(label)
    }
    
    convenience init(text: String, buttonTitle: String, buttonTap: @escaping ()->Void) {
        self.init(text: text)

        bg.backgroundColor = .white
        addSubview(bg)

        button.setTitle(buttonTitle, for: UIControlState())
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.rx.tap.subscribe(onNext: didTapButton).disposed(by: bag)
        
        addSubview(button)
        
        tapHandler = buttonTap
    }
    
    func didTapButton() {
        tapHandler?()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard let newSuperview = newSuperview else {
            return
        }
        
        for sv in newSuperview.subviews {
            if let sv = sv as? ContainerMessageView {
                sv.removeFromSuperview()
            }
        }
        
        frame = newSuperview.bounds
        label.frame = bounds

        let tabBarHeight = ((UIApplication.shared.windows.first!).rootViewController as! UITabBarController).tabBar.frame.size.height
        
        button.sizeToFit()
        button.frame.size.width *= 1.2
        button.center = CGPoint(
            x: bounds.size.width/2,
            y: (bounds.size.height - button.bounds.size.height - tabBarHeight) * 0.9
        )

        fadeIn()
    }

    let transitionDuration = 1.0
    let transitionOffset: CGFloat = 80.0

    private func fadeIn() {
        label.center.x -= transitionOffset
        label.alpha = 0

        UIView.animate(withDuration: transitionDuration, delay: 0.0,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 0,
                       options: [], animations: {
                        self.label.alpha = 1.0
                        self.label.center.x += self.transitionOffset
        }, completion: nil)
    }

    private func fadeOut(completion: @escaping (()->Void)) {
        UIView.animate(withDuration: transitionDuration, delay: 0.0,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 0,
                       options: [], animations: {
                        self.label.alpha = 0.0
                        self.label.center.x += self.transitionOffset
        }, completion: {_ in
            completion()
            self.label.alpha = 1.0
            self.label.center.x -= self.transitionOffset
        })
    }

    static func removeViewFrom(_ view: UIView) {
        for sv in view.subviews {
            if let sv = sv as? ContainerMessageView {
                sv.fadeOut(completion: sv.removeFromSuperview)
            }
        }
    }
    
    static func toggle(_ superview: UIView, visible: Bool, text: String) {
        if visible {
            superview.addSubview(ContainerMessageView(text: text))
        } else {
            ContainerMessageView.removeViewFrom(superview)
        }
    }
}
