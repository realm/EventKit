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
import Then
import RxFeedback
import RxGesture

import EventBlankKit

class SessionDetailsCell: UITableViewCell, ClassIdentifier {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var sessionTitleLabel: UITextView!
    @IBOutlet weak var trackTitleLabel: UILabel!

    private var reuseBag = DisposeBag()
    private var viewModel: SessionDetailsCellViewModel! {
        didSet { populateFromViewModel() }
    }

    enum Event {
        case openPhoto, openTwitter, openWebsite, refresh
        case setIsFavorite(Bool)
    }
    
    static func createWith(_ dataSource: SectionedViewDataSourceType, tableView: UITableView, index: IndexPath, session: Session) -> SessionDetailsCell {
        return tableView.dequeueReusableCell(SessionDetailsCell.self).then { cell in
            cell.reuseBag = DisposeBag()
            cell.viewModel = SessionDetailsCellViewModel(session: session)
            cell.willAppear()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.withRenderingMode(.alwaysTemplate), for: .selected)
        descriptionTextView.delegate = self
    }

    private func willAppear() {
        Observable<Any>.system(
            initialState: viewModel,
            reduce: updateState,
            scheduler: MainScheduler.instance,
            feedback: bindUI)
        .subscribe()
        .disposed(by: reuseBag)

        //activate model
        viewModel.activate()
    }

    private func updateState(state: SessionDetailsCellViewModel, event: Event) -> SessionDetailsCellViewModel {
        switch event {
        case .openPhoto: showPhoto?()
        case .openTwitter: openTwitter()
        case .openWebsite:
            if let website = viewModel.session.speaker?.url, let websiteURL = URL(string: website) {
                openWebsite?(websiteURL)
            }
        case .refresh: populateFromViewModel()
        case .setIsFavorite(let isFavorite):
            viewModel.updateIsFavorite(isFavorite: isFavorite)
            btnToggleIsFavorite.animateSelect(scale: 0.8, completion: nil)

            _ = Notifications.toggleNotification(for: viewModel.session, on: isFavorite)
                .subscribe(onError: { print($0) })

        }
        return state
    }

    private var bindUI: ((Observable<SessionDetailsCellViewModel>) -> Observable<Event>) {
        return UI.bind(self) { this, state in
            let subscriptions = [
                // favorite button
                this.viewModel.isFavorite
                    .bind(to: this.btnToggleIsFavorite.rx.isSelected)
            ]

            let events = [
                // tap image
                this.userImage.rx.tapGesture()
                    .when(.recognized)
                    .map { _ in Event.openPhoto },

                // tap twitter button
                this.twitterLabel.rx.tapGesture()
                    .when(.recognized)
                    .map { _ in Event.openTwitter },

                // tap website button
                this.websiteLabel.rx.tapGesture()
                    .when(.recognized)
                    .map { _ in Event.openWebsite },

                // refresh cell data
                Observable.from(object: this.viewModel.session)
                    .map { _ in Event.refresh },

                //bind UI
                this.viewModel.isFavorite
                    .sample(this.btnToggleIsFavorite.rx.tap)
                    .map { isFavorite in Event.setIsFavorite(!isFavorite) }
            ]
            
            return UI.Bindings(subscriptions: subscriptions, events: events)
        }
    }

    func populateFromViewModel() {
        let session = viewModel.session

        nameLabel.text = session.speaker?.name

        let time = shortStyleDateFormatter.string(from: session.date)

        var textAttributes = [String: AnyObject]()
        textAttributes[NSFontAttributeName] = UIFont.systemFont(ofSize: 22)
        sessionTitleLabel.attributedText = NSAttributedString(
            string: "\(time) \(session.title)\n",
            attributes: textAttributes)

        trackTitleLabel.text = (session.track?.track ?? "") + "\n"

        if let twitter = session.speaker?.twitter, !twitter.isEmpty {
            twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
        } else {
            twitterLabel.text = nil
        }

        websiteLabel.text = session.speaker?.url
        //btnToggleIsFavorite.selected = isFavoriteSession //TODO: add binding

        //only way to force textview autosizing I found
        descriptionTextView.text = session.sessionDescription + "\n\n"

        if let photoUrl = session.speaker?.photoUrl, let url = URL(string: photoUrl) {
            let size = userImage.bounds.size
            userImage.kf.indicatorType = .activity
            userImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.1))], completionHandler: { [weak self] (image, error, cacheType, imageUrl) in
                guard let image = image else { return }

                self?.showPhoto = {
                    PhotoPopupView.showImage(image, inView: UIApplication.shared.windows.first!)
                }
                image.asyncToSize(.fillSize(size), cornerRadius: size.width/2, completion: { result in
                    self?.userImage.image = result
                })
            })
        }

        //theme
        let event = EventData.default(in: RealmProvider.event)
        sessionTitleLabel.textColor = event.mainColor
        trackTitleLabel.textColor = event.mainColor.lighter(amount: 0.1).desaturated()

        //check if in the past
        if Date().compare(.isLater(than: session.date)) {
            sessionTitleLabel.textColor = sessionTitleLabel.textColor?.desaturated(amount: 0.5).lighter()
            trackTitleLabel.textColor = sessionTitleLabel.textColor
        }
    }

    private var showPhoto: (()->Void)?
    var openWebsite: ((URL)->Void)?
    func openTwitter() {
        if let twitter = viewModel.session.speaker?.twitter {
            openWebsite?(twitterUrl(twitter))
        }
    }
}

extension SessionDetailsCell {
    func textView(_ textView: UITextView, shouldInteractWithURL URL: Foundation.URL, inRange characterRange: NSRange) -> Bool {
        openWebsite?(URL)
        return false
    }
}
