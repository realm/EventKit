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

import RxSwift
import RxCocoa
import RxGesture

extension ObservableType {
    func replaceWith<R>(_ value: R) -> Observable<R> {
        return map { _ in value }
    }
}

extension Reactive where Base: UIResponder {
    public var isFirstResponder: AnyObserver<Bool> {
        return Binder(base) {control, shouldRespond in
            if shouldRespond {
                control.becomeFirstResponder()
            } else {
                control.resignFirstResponder()
            }
        }
        .asObserver()
    }
}

extension Observable where Element: Equatable {
    public func filterOut(_ targetValue: Element) -> Observable<Element> {
        return self.filter {value in targetValue != value}
    }
}

protocol Optionable
{
    associatedtype WrappedType
    func unwrap() -> WrappedType
    func isEmpty() -> Bool
}

extension Optional : Optionable
{
    typealias WrappedType = Wrapped
    func unwrap() -> WrappedType {
        return self!
    }
    
    func isEmpty() -> Bool {
        return !(flatMap({_ in true}) == true)
    }
}

extension Observable where Element: Optionable {
    func unwrap() -> Observable<Element.WrappedType> {
        return self
            .filter {value in
                return !value.isEmpty()
            }
            .map {value -> Element.WrappedType in
                value.unwrap()
            }
    }
}

extension Collection where Self.Iterator.Element: Optionable {
    func unwrap() -> [Self.Iterator.Element.WrappedType] {
        return self
            .filter {value in
                return !value.isEmpty()
            }
            .map {value in
                return value.unwrap()
            }
    }
}

extension Reactive where Base: UIView {
    public var visible: AnyObserver<Bool> {
        return Binder(base, binding: { (view, visible) in
            view.isHidden = !visible
        })
        .asObserver()
    }

    public var taps: Observable<Void> {
        return tapGesture().when(.recognized).map({_ in ()})
    }
}

extension Reactive where Base: UILabel {
    public var textColor: AnyObserver<UIColor> {
        return AnyObserver { event in
            MainScheduler.ensureExecutingOnScheduler()

            switch event {
            case .next(let value):
                self.base.textColor = value
            case .error(let error):
                fatalError(error.localizedDescription)
                break
            case .completed:
                break
            }
        }
    }
}

extension Reactive where Base: CALayer {
    public var borderColor: AnyObserver<CGColor?> {
        return Binder(base) { layer, color in
            self.base.borderColor = color
        }
        .asObserver()
    }
}
