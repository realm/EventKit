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

import Then
import EventBlankKit

class SpeakerDetailsCell: UITableViewCell, ClassIdentifier {
    
    private var reuseBag = DisposeBag()
    private var viewModel: SpeakerDetailsCellViewModel! {
        didSet { populateFromViewModel() }
    }

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnWebsite: UIButton!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var btnIsFollowing: FollowTwitterButton!
    
    enum Event {
        case openPhoto, openTwitter, openWebsite
        case setIsFavorite(Bool)
    }

    // methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.withRenderingMode(.alwaysTemplate), for: .selected)
        bioTextView.delegate = self
    }
    
    static func createWith(_ dataSource: SectionedViewDataSourceType, tableView: UITableView, speaker: Speaker, twitterProvider: TwitterProvider) -> SpeakerDetailsCell {
        return tableView.dequeueReusableCell(SpeakerDetailsCell.self).then { cell in
            cell.reuseBag = DisposeBag()
            cell.viewModel = SpeakerDetailsCellViewModel(with: speaker)
            cell.willAppear()
        }
    }

    func willAppear() {
        let this = self

        Observable<Any>.system(
            initialState: viewModel,
            reduce: { state, event in
                switch event {
                case .openPhoto: this.showPhoto?()
                case .openTwitter: this.openTwitter()
                case .openWebsite:
                    if let website = this.viewModel.speaker.url, let websiteURL = URL(string: website) {
                        this.openWebsite?(websiteURL)
                    }
                case .setIsFavorite(let isFavorite):
                    this.viewModel.updateIsFavorite(isFavorite: isFavorite)
                    this.btnToggleIsFavorite.animateSelect(scale: 0.8, completion: nil)
                }
                return state
            },
            scheduler: MainScheduler.instance,
            scheduledFeedback: bindUI)
        .subscribe()
        .disposed(by: reuseBag)
    }

    private var bindUI: ((RxFeedback.ObservableSchedulerContext<SpeakerDetailsCellViewModel>) -> Observable<Event>) {
        return RxFeedback.bind(self) { this, state in
            let subscriptions = [
                // favorite button
                this.viewModel.isFavorite
                    .bind(to: this.btnToggleIsFavorite.rx.isSelected),
            ]

            let events = [
                // toggle is favorite
                this.viewModel.isFavorite
                    .sample(this.btnToggleIsFavorite.rx.tap)
                    .map { Event.setIsFavorite(!$0) },

                // tap image
                this.userImage.rx.tapGesture()
                    .when(.recognized)
                    .map { _ in Event.openPhoto },

                // tap twitter button
                this.btnTwitter.rx.tap
                    .map { _ in Event.openTwitter },

                // tap website button
                this.btnWebsite.rx.tap
                    .map { _ in Event.openWebsite }
            ]

            return RxFeedback.Bindings(subscriptions: subscriptions, events: events)
        }
    }

    private func populateFromViewModel() {
        let speaker = viewModel.speaker!

        //
        // setup UI
        //
        nameLabel.text = speaker.name
        
        if let twitterHandle = speaker.twitter, !twitterHandle.isEmpty {
            let twitterString = twitterHandle.hasPrefix("@") ? twitterHandle : "@"+twitterHandle
            btnTwitter.setTitle(twitterString, for: UIControlState())
        }
        
        btnWebsite.setTitle(speaker.url, for: UIControlState())
        bioTextView.text = speaker.bio

        if let photoUrl = speaker.photoUrl, let url = URL(string: photoUrl) {
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
    }

    private var showPhoto: (()->Void)?
    var openWebsite: ((URL)->Void)?
    private func openTwitter() {
        if let twitter = viewModel.speaker.twitter {
            openWebsite?(twitterUrl(twitter))
        }
    }
}

extension SpeakerDetailsCell {
    
    func textView(_ textView: UITextView, shouldInteractWithURL URL: Foundation.URL, inRange characterRange: NSRange) -> Bool {
        openWebsite?(URL)
        return false
    }
}
