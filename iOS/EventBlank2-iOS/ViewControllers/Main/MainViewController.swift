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
import RealmSwift
import DynamicColor

import EventBlankKit
import Kingfisher

class MainViewController: UIViewController {

    // MARK: outlets
    @IBOutlet weak var imgConfLogo: UIImageView!
    @IBOutlet weak var lblConfName: UILabel!
    @IBOutlet weak var lblConfSubtitle: UILabel!
    @IBOutlet weak var lblRightNow: UILabel!
    @IBOutlet weak var lblOrganizer: UILabel!
    
    // MARK: variables
    private let viewModel = MainViewModel()
    private let bag = DisposeBag()

    private enum Event {
        case timer
    }

    // MARK: methods
    override func viewDidLoad() {
        super.viewDidLoad()

        Observable<Any>.system(
            initialState: viewModel,
            reduce: updateState,
            scheduler: MainScheduler.instance,
            scheduledFeedback: bindUI)
        .subscribe()
        .disposed(by: bag)
    }

    private func updateState(state: MainViewModel, event: Event) -> MainViewModel {
        switch event {
        case .timer:
            showNextSession(state.nextSession)
        }
        return state
    }

    private var bindUI: ((RxFeedback.ObservableSchedulerContext<MainViewModel>) -> Observable<Event>) {
        return RxFeedback.bind(self) { this, state in
            let eventData = this.viewModel.eventData.share(replay: 1)
            let subscriptions = [
                // bind texts
                eventData.map { $0.title }.bind(to: this.lblConfName.rx.text),
                eventData.map { $0.subtitle }.bind(to: this.lblConfSubtitle.rx.text),
                eventData.map { $0.organizer }.bind(to: this.lblOrganizer.rx.text),
                eventData.map { $0.logoUrl }.bind(to: this.imgConfLogo.rx.kfUrlString),

                // bind color
                eventData.map { $0.mainColor }.bind(to: this.lblConfName.rx.textColor),
                eventData.map { $0.mainColor }.bind(to: this.lblConfSubtitle.rx.textColor)
            ]

            let events = [
                this.viewModel.timer.map { _ in Event.timer }
            ]

            return RxFeedback.Bindings(subscriptions: subscriptions, events: events)
        }
    }
    
    func showNextSession(_ next: Schedule.NextEventResult?) {
        guard let next = next else {
            lblRightNow.text = nil
            return
        }
        
        switch next {
        case .next(let session):
            lblRightNow.text = "Next: \(session.date.toString(format: .custom("hh:mm"))) \(session.title) (\(session.speaker?.name ?? ""))"
        case .eventFinished:
            lblRightNow.text = "This event has finished"
        case .eventStartsIn(let seconds):
            switch seconds {
            case 0..<60*60:
                lblRightNow.text = "The event starts any moment"
            case 60*60..<23*60*60:
                let hours = 1 + Int(seconds / 60 / 60)
                lblRightNow.text = "The event starts in \(hours) hours"
            default:
                let days = 1 + Int(seconds / 60 / 60 / 24)
                lblRightNow.text = "The event starts in \(days) days"
            }
        }
    }
}

extension Reactive where Base: UIImageView {
    public var kfUrlString: Binder<String?> {
        return Binder(base) { imageView, urlString in
            guard let urlString = urlString, let url = URL(string: urlString) else { return }
            imageView.kf.setImage(with: url)
        }
    }
}
