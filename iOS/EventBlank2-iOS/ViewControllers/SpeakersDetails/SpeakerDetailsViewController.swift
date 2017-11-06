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
import RxDataSources
import RxFeedback

import EventBlankKit

public typealias AnySection = SectionModel<String, Any>

class SpeakerDetailsViewController: UIViewController, ClassIdentifier, Navigatable {
    
    @IBOutlet weak var tableView: UITableView!

    private let bag = DisposeBag()
    fileprivate var viewModel: SpeakerDetailsViewModel!
    private var twitterProvider: TwitterProvider!
    private lazy var dataSource = {
        return RxTableViewSectionedReloadDataSource<AnySection>(configureCell: self.configureCell)
    }()

    var navigator: Navigator!

    private enum Event { case test }

    static func createWith(_ storyboard: UIStoryboard,
                           viewModel: SpeakerDetailsViewModel,
                           twitterProvider: TwitterProvider = TwitterProvider()) -> SpeakerDetailsViewController {
        return storyboard.instantiateViewController(SpeakerDetailsViewController.self).then {vc in
            vc.viewModel = viewModel
            vc.twitterProvider = twitterProvider
            vc.title = viewModel.speaker.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureDataSource()

        Observable<Any>.system(
            initialState: viewModel,
            reduce: { state, event in
                return state
            },
            scheduler: MainScheduler.instance,
            scheduledFeedback: bindUI)
        .subscribe()
        .disposed(by: bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.activate()
    }

    func setupUI() {
        tableView.delegate = self
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    private func configureCell(dataSource: TableViewSectionedDataSource<AnySection>, tableView: UITableView, indexPath: IndexPath, element: Any) -> UITableViewCell {
        //the data source
        switch indexPath.section {
        case 0:
            let cell = SpeakerDetailsCell.createWith(dataSource, tableView: tableView, speaker: viewModel.speaker, twitterProvider: twitterProvider)
            cell.openWebsite = { [weak self] url in
                self?.navigator.show(segue: .webPage(url), sender: self, transition: .modal)
            }
            return cell
        case 1: return TweetCell.createWith(tableView, tweet: element as! Tweet)
        default: return UITableViewCell()
        }
    }

    func configureDataSource() {
        //section headers
        dataSource.titleForHeaderInSection = { _, section in
            switch section {
            case 0: return "Speaker Details"
            case 1: return "Latest Tweets"
            default: return ""
            }
        }

        //sectin footer
        dataSource.titleForFooterInSection = { [weak self] _, section in
            guard let this = self else { return nil }

            switch section {
            case 1:
                if let items = try? this.viewModel.tableItems.value(), items.count < 2 {
                    return "Log in to your Twitter account in your iPhone's Settings app to be able to see tweets right in this app"
                } else {
                    fallthrough
                }
            default: return nil
            }
        }
    }

    private var bindUI: ((RxFeedback.ObservableSchedulerContext<SpeakerDetailsViewModel>) -> Observable<Event>) {
        return RxFeedback.bind(self) { this, state in

            // twitter
            let tweets = Variable<[Tweet]?>(nil)
            if let targetTwitterUsername = this.viewModel.speaker.twitter {
                this.twitterProvider.currentAccount()
                    .unwrap()
                    .flatMapLatest { account in
                        return this.twitterProvider.timelineForUsername(account, username: targetTwitterUsername)
                    }
                    .bind(to: tweets)
                    .disposed(by: this.bag)
            }

            let subscriptions = [
                //bind table items
                Observable.combineLatest(this.viewModel.tableItems, tweets.asObservable(), resultSelector: { speakerDetails, tweets in
                    if let tweets = tweets {
                        return [AnySection(model: "details", items: [speakerDetails]),
                                AnySection(model: "tweets", items: tweets)]
                    } else {
                        return [AnySection(model: "details", items: [speakerDetails])]
                    }
                })
                .bind(to: this.tableView.rx.items(dataSource: this.dataSource))
            ]

            let events = [
                this.rx.deallocating.map { Event.test }
            ]

            return RxFeedback.Bindings(subscriptions: subscriptions, events: events)
        }
    }

    fileprivate lazy var twitterFooterView: UIView = {
        return UIView().then { v in
            v.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60)
            v.addSubview(UILabel().then { l in
                l.textColor = UIColor(hex: 0x333333)
                l.frame = v.bounds
                l.text = "Tap here to see more tweets from \(self.viewModel.speaker.name)"
                l.numberOfLines = 0
                l.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                l.textAlignment = .center
            })
            v.rx.tapGesture()
                .when(.recognized)
                .map {_ in self.viewModel.speaker.twitter }
                .unwrap()
                .map(twitterUrl)
                .bind(onNext: openUrl)
                .disposed(by: self.bag)
        }
    }()
}

extension SpeakerDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }

        return twitterFooterView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section == 1 else { return 20 }

        return 80.0
    }
}
