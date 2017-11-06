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
import RxFeedback
import RxViewController

import XLPagerTabStrip
import EventBlankKit
import UserNotifications

class ScheduleViewController: ButtonBarPagerTabStripViewController, Navigatable, ClassIdentifier {
    
    private let btnFavorites = FavoritesBarButtonItem.instance()
    private let bag = DisposeBag()

    var navigator: Navigator!

    enum Event {
        case toggleFavorites
        case themeRefresh
    }

    // MARK: - ViewController / UI

    override func viewDidLoad() {
        configBar()
        navigator = Navigator.default

        super.viewDidLoad()
        setupUI()

        let appState = AppState.default(in: RealmProvider.app)

        Observable<Any>.system(
            initialState: appState,
            reduce: updateState,
            scheduler: MainScheduler.instance,
            scheduledFeedback: bindUI)
        .subscribe()
        .disposed(by: bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()

        if let target = navigationController?.navigationBar.topItem?.rightBarButtonItem?.customView {
            Tutorial.showScheduleTutorial(target: target)
        }
    }

    private func configBar() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor.white.darkened(amount: 0.05)
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarItemTitleColor = .white

        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        settings.style.buttonBarRightContentInset = 60.0
    }

    private func configureNavigationBar() {
        buttonBarView.backgroundColor = .clear
        buttonBarView.removeFromSuperview()
        buttonBarView.frame.size.width -= settings.style.buttonBarRightContentInset!
        navigationController!.navigationBar.addSubview(buttonBarView)
        navigationItem.rightBarButtonItem = btnFavorites
    }

    private func setupUI() {
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }

            oldCell?.label.textColor = UIColor(white: 1, alpha: 0.6)
            newCell?.label.textColor = .white

            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
            } else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
    }

    // MARK: - Feedback

    fileprivate var bindUI: (ObservableSchedulerContext<AppState>) -> Observable<Event> {
        return RxFeedback.bind(self) { this, state in
            let subscriptions = [
                // only favorites
                state.map { $0.scheduleOnlyFavorites }
                    .bind(to: this.btnFavorites.rx.isSelected),

                // shows/hides button bar on top
                Observable.merge(this.rx.viewWillAppear.map {_ in false }, this.rx.viewWillDisappear.map {_ in true })
                    .bind(to: this.buttonBarView.rx.isHidden)
            ]

            let events = [
                this.btnFavorites.button.rx.tap
                    .map { _ in Event.toggleFavorites },

                // theme refresh
                Observable.from(object: EventData.default(in: RealmProvider.event), emitInitialValue: false, properties: ["_mainColor"])
                    .map { _ in Event.themeRefresh }
            ]

            return RxFeedback.Bindings(subscriptions: subscriptions, events: events)
        }
    }

    private func updateState(state: AppState, event: Event) -> AppState {
        switch event {
        case .toggleFavorites:
            try! state.realm?.write {
                state.scheduleOnlyFavorites = !state.scheduleOnlyFavorites
            }
        case .themeRefresh:
            configBar()
            configureNavigationBar()
            btnFavorites.updateBackgroundColor()
        }
        return state
    }

    // MARK: - PagerTabStripViewController
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return Schedule().dayRanges().map { day in
            return navigator.get(segue: .sessions(day), storyboard: storyboard!).then { vc in
                if var vc = vc as? Navigatable {
                    vc.navigator = navigator
                }
            }
        }
    }

    override func configureCell(_ cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo) {
        super.configureCell(cell, indicatorInfo: indicatorInfo)
        cell.backgroundColor = .clear
    }
}
