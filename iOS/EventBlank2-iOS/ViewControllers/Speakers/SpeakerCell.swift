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
import RealmSwift

import RxSwift
import RxCocoa
import RxFeedback
import Then
import Kingfisher

import EventBlankKit

class SpeakerCell: UITableViewCell, ClassIdentifier {

    // outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var btnToggleIsFavorite: UIButton!

    private var reuseBag = DisposeBag()
    private var viewModel: SpeakerCellViewModel! {
        didSet { populateFromViewModel() }
    }

    enum Event {
        case setIsFavorite(Bool)
    }

    static func createWith(_ dataSource: SectionedViewDataSourceType, tableView: UITableView, index: IndexPath, speaker: Speaker) -> SpeakerCell {
        return tableView.dequeueReusableCell(SpeakerCell.self).then { cell in
            cell.reuseBag = DisposeBag()
            cell.viewModel = SpeakerCellViewModel(with: speaker)
            cell.willAppear()
        }
    }

    //methods
    override func awakeFromNib() {
        super.awakeFromNib()
        btnToggleIsFavorite.setImage(nil, for: .normal)
        btnToggleIsFavorite.setImage(UIImage(named: "like-full")?.withRenderingMode(.alwaysTemplate), for: .selected)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reuseBag = DisposeBag()
        userImage.image = nil
        twitterLabel.text = nil
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

    private func updateState(state: SpeakerCellViewModel, event: Event) -> SpeakerCellViewModel {
        switch event {
        case .setIsFavorite(let isFavorite):
            viewModel.updateIsFavorite(isFavorite: isFavorite)
            btnToggleIsFavorite.animateSelect(scale: 0.8, completion: nil)
        }
        return state
    }

    private var bindUI: ((RxFeedback.ObservableSchedulerContext<SpeakerCellViewModel>) -> Observable<Event>) {
        return RxFeedback.bind(self) { this, state in
            let subscriptions = [
                // is session favorite
                this.viewModel.isFavorite
                    .bind(to: this.btnToggleIsFavorite.rx.isSelected)
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

    private func populateFromViewModel() {
        let speaker = viewModel.speaker!

        //setupUI
        if let photoUrl = speaker.photoUrl, let url = URL(string: photoUrl) {
            let size = userImage.bounds.size
            userImage.kf.indicatorType = .activity
            userImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.1))], completionHandler: { [weak self] (image, error, cacheType, imageUrl) in
                guard let image = image else { return }
                image.asyncToSize(.fillSize(size), cornerRadius: size.width/2, completion: { result in
                    self?.userImage.image = result
                })
            })
        }

        nameLabel.text = speaker.name
        
        if let twitter = speaker.twitter, !twitter.isEmpty {
            twitterLabel.text = twitter.hasPrefix("@") ? twitter : "@"+twitter
        }
    }
}
