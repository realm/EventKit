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
import UserNotifications

import RxSwift
import RxCocoa
import RxFeedback

import Then
import EventBlankKit

class SessionCell: UITableViewCell, ClassIdentifier {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var speakerLabel: UILabel!
    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    @IBOutlet weak var btnSpeakerIsFavorite: UIButton!

    private var reuseBag = DisposeBag()
    private var viewModel: SessionCellViewModel! {
        didSet { populateFromViewModel() }
    }

    enum Event {
        case setIsFavorite(Bool)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.withRenderingMode(.alwaysTemplate), for: .selected)
        btnSpeakerIsFavorite.setImage(UIImage(named: "like-full")?.withRenderingMode(.alwaysTemplate), for: .selected)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        reuseBag = DisposeBag()
        speakerImageView.image = nil
    }

    static func createWith(_ dataSource: SectionedViewDataSourceType, tableView: UITableView, index: IndexPath, session: Session) -> SessionCell {
        return tableView.dequeueReusableCell(SessionCell.self).then { cell in
            cell.reuseBag = DisposeBag()
            cell.viewModel = SessionCellViewModel(with: session)
            cell.willAppear()
        }
    }

    func willAppear() {
        Observable<Any>.system(
            initialState: viewModel,
            reduce: updateState,
            scheduler: MainScheduler.instance,
            scheduledFeedback: bindUI)
        .subscribe()
        .disposed(by: reuseBag)
    }

    private func updateState(state: SessionCellViewModel, event: Event) -> SessionCellViewModel {
        switch event {
        case .setIsFavorite(let isFavorite):

            viewModel.updateIsFavorite(isFavorite: isFavorite)
            btnToggleIsFavorite.animateSelect(scale: 0.8, completion: nil)

            _ = Notifications.toggleNotification(for: viewModel.session, on: isFavorite)
                .subscribe(onError: { print($0) })
        }
        return state
    }

    private var bindUI: ((RxFeedback.ObservableSchedulerContext<SessionCellViewModel>) -> Observable<Event>) {
        return RxFeedback.bind(self) { this, state in
            let subscriptions = [
                // is session favorite
                state.flatMap { $0.isFavorite }
                    .bind(to: this.btnToggleIsFavorite.rx.isSelected),

                // is speaker favorite
                state.flatMap { $0.isFavoriteSpeaker }
                    .bind(to: this.btnSpeakerIsFavorite.rx.isSelected),

                state.flatMap { $0.didChange }
                    .subscribe(onNext: { [weak self] in
                        self?.populateFromViewModel(animated: true)
                    })
            ]

            let events = [
                // toggle is favorite session
                this.viewModel.isFavorite
                    .sample(this.btnToggleIsFavorite.rx.tap)
                    .map { isFavorite in Event.setIsFavorite(!isFavorite) }
            ]

            return RxFeedback.Bindings(subscriptions: subscriptions, events: events)
        }
    }

    private func populateFromViewModel(animated: Bool) {
        if animated {
            UIView.transition(with: self, duration: 0.33, options: [.transitionFlipFromTop, .allowAnimatedContent, .beginFromCurrentState], animations: populateFromViewModel, completion: nil)
        } else {
            populateFromViewModel()
        }
    }

    private func populateFromViewModel() {
        guard let session = viewModel.session else { return }

        let event = EventData.default(in: RealmProvider.event)

        //updateUI
        titleLabel.text = session.title
        speakerLabel.text = session.speaker?.name
        trackLabel.text = session.track?.track ?? ""

        timeLabel.text = shortStyleDateFormatter.string(from: session.date)

        if let photoUrl = session.speaker?.photoUrl, let url = URL(string: photoUrl) {
            let size = speakerImageView.bounds.size
            speakerImageView.kf.indicatorType = .activity
            speakerImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.1))], completionHandler: { [weak self] (image, error, cacheType, imageUrl) in
                guard let image = image else { return }

                image.asyncToSize(.fillSize(size), cornerRadius: size.width/2, completion: { result in
                    self?.speakerImageView.image = result
                })
            })
        }

        locationLabel.text = session.location?.location

        //theme
        titleLabel.textColor = event.mainColor
        trackLabel.textColor = event.mainColor.lighter(amount: 0.1).desaturated()
        speakerLabel.textColor = UIColor.black
        locationLabel.textColor = UIColor.black

        //check if in the past
        if Date().compare(.isLater(than: session.date)) {
            titleLabel.textColor = titleLabel.textColor.desaturated(amount: 0.5).lighter()
            trackLabel.textColor = titleLabel.textColor
            speakerLabel.textColor = UIColor.gray
            locationLabel.textColor = UIColor.gray
        }
    }
}
