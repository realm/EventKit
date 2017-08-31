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

enum UIImageResizeMode {
    case fill(CGFloat, CGFloat)
    case fillSize(CGSize)
    case fit(CGFloat, CGFloat)
    case match(CGFloat, CGFloat)
}

extension Reactive where Base: UIImage {
    func resizedImage(_ newSizeMode: UIImageResizeMode, cornerRadius: CGFloat = 0.0) -> Observable<UIImage?> {
        return Observable.create({observer -> Disposable in

            self.base.asyncToSize(newSizeMode, cornerRadius: cornerRadius) { image in
                observer.onNext(image)
                observer.onCompleted()
            }

            return Disposables.create()
        })
    }
}

extension UIImage {

    func asyncToSize(_ newSizeMode: UIImageResizeMode, cornerRadius: CGFloat = 0.0, completion: ((UIImage?)->Void)? = nil) {

        var result: UIImage? = nil

        DispatchQueue.global(qos: .background).async {
            var newSize: CGSize!
            
            switch newSizeMode {
            case .fill(let w, let h):
                newSize = CGSize(width: w, height: h)
            case .fillSize(let s):
                newSize = s
            case .fit(let w, let h):
                newSize = CGSize(width: w, height: h)
            case .match(let w, let h):
                newSize = CGSize(width: w, height: h)
            }
            
            let aspectWidth = newSize.width / self.size.width
            let aspectHeight = newSize.height / self.size.height
            let aspectRatio: CGFloat!
            
            switch newSizeMode {
            case .fill(_, _): fallthrough
            case .fillSize(_):
                aspectRatio = max(aspectWidth, aspectHeight)
            case .fit(_, _):
                aspectRatio = min(aspectWidth, aspectHeight)
            case .match(_, _):
                aspectRatio = newSize.width / newSize.height
            }
            
            var rect = CGRect.zero
            
            rect.size.width = self.size.width * aspectRatio
            rect.size.height = self.size.height * aspectRatio
            rect.origin.x = (newSize.width - rect.size.width) / 2.0
            rect.origin.y = (newSize.height - rect.size.height) / 2.0

            UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
            if cornerRadius > 0.0 {
                let clipRect = CGRect(origin: CGPoint.zero, size: newSize)
                if let context = UIGraphicsGetCurrentContext() {
                    context.addPath(UIBezierPath(roundedRect: clipRect, cornerRadius: cornerRadius).cgPath)
                    context.clip()
                }
            }
            self.draw(in: rect)
            
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
}
