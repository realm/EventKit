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
import Kingfisher

import RxSwift
import RxCocoa

class PhotoPopupView: UIView {

    private let bag = DisposeBag()
    
    static func showImage(_ image: UIImage, inView: UIView) {
        let popup = PhotoPopupView()
        inView.addSubview(popup)
        
        popup.photo = image
    }
    
    static func showImageWithUrl(_ url: URL, inView: UIView) {
        let popup = PhotoPopupView()
        inView.addSubview(popup)
        
        popup.photoUrl = url
    }
    
    var photoUrl: URL! {
        didSet {
            precondition(backdrop == nil)
            setupUI()

            imgView.kf.setImage(with: photoUrl, placeholder: nil, options: nil) {[weak self] image, error, cacheType, imageURL in
                if let image = image {
                    self?.imgView.image = image
                    if self?.spinner != nil {
                        self?.spinner.removeFromSuperview()
                    }
                } else {
                    UIViewController.alert("Couldn't fetch image.", buttons: ["Close"], completion: {_ in self?.didTapPhoto()})
                }
            }
            displayPhoto()
        }
    }
    
    var photo: UIImage! {
        didSet {
            precondition(backdrop == nil)
            setupUI()
            imgView.image = photo
            displayPhoto()
        }
    }
    
    private var backdrop: UIView!
    private var imgView: UIImageView!
    private var spinner: UIActivityIndicatorView!
    
    func setupUI() {
        guard superview != nil else {
            return
        }
        
        frame = superview!.bounds
        
        //add background
        backdrop = UIView(frame: bounds)
        backdrop.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        backdrop.alpha = 0.0
        addSubview(backdrop)
        
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        spinner.center = center
        spinner.startAnimating()
        spinner.backgroundColor = UIColor.clear
        spinner.layer.masksToBounds = true
        spinner.layer.cornerRadius = 5

        imgView = UIImageView()
        imgView.frame = bounds.insetBy(dx: 20, dy: 40)
        imgView.layer.cornerRadius = 10
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFit
        imgView.alpha = 0
    }
    
    func displayPhoto() {
        //add image view
        backdrop.addSubview(imgView)
        UIView.animate(withDuration: 0.2, animations: {[unowned self] in
            self.backdrop.alpha = 1.0
        })

        //spinner
        if imgView.image == nil {
            backdrop.addSubview(spinner)
        }
        
        imgView.rx.anyGesture(.tap(), .swipe([.up, .down, .left, .right])).when(.recognized)
            .subscribe(onNext: {[weak self] _ in
                self?.didTapPhoto()
            })
            .disposed(by: bag)
        
        UIView.animate(withDuration: 0.67, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.imgView.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 0.67, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            let yDelta = ((UIApplication.shared.windows.first!).rootViewController as! UITabBarController).tabBar.frame.size.height/2
            self.imgView.center.y -= yDelta
            self.spinner.center.y -= yDelta
        }, completion: nil)
    }
    
    func didTapPhoto() {
        
        imgView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.alpha = 0
        }, completion: {_ in
            self.removeFromSuperview()
        })
    }
    
    func didSwipePhoto(_ swipe: UISwipeGestureRecognizer) {
        
        imgView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.imgView.center.y += (swipe.direction == .down ? 1 : -1) * ((UIApplication.shared.windows.first!).rootViewController as! UITabBarController).tabBar.frame.size.height/2
            self.alpha = 0
            }, completion: {_ in
                self.removeFromSuperview()
        })
    }
}
