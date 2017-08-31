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
import Reachability

extension Reactive where Base: Reachability {
    static var isReachable: Observable<Bool> {
        return Observable.create { observer in
            let reach = Reachability()

            reach.reachableBlock = { reachability in
                observer.on(.next(true))
            }

            reach.unreachableBlock = { reachability in
                observer.on(.next(false))
            }
            
            reach.startNotifier()

            return Disposables.create {
                reach.stopNotifier()
            }
        }.shareReplay(1)
    }
}

extension ObservableType {
    func retryOnConnect(default value: E) -> Observable<E> {
        return catchError { error in
            Reachability.rx.isReachable
                .filter { $0 }
                .flatMap { _ in
                    Observable.error(error)
                }
                .startWith(value)
            }
            .retry()
    }
}
