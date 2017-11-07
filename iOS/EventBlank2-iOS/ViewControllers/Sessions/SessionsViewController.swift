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
import RxDataSources

import XLPagerTabStrip
import EventBlankKit

class SessionsViewController: UIViewController, ClassIdentifier, UIScrollViewDelegate, Navigatable {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let bag = DisposeBag()
    fileprivate var viewModel: SessionsViewModel!
    var navigator: Navigator!

    fileprivate let dataSource = RxTableViewSectionedAnimatedDataSource<SessionSection>(configureCell: SessionCell.createWith)

    fileprivate enum Event {
        case showSessionDetails(Session)
        case themeRefresh
    }

    static func createWith(_ storyboard: UIStoryboard, viewModel: SessionsViewModel) -> SessionsViewController {
        return storyboard.instantiateViewController(SessionsViewController.self).then { vc in
            vc.viewModel = viewModel
            vc.title = viewModel.day.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configureDataSource()

        Observable<Any>.system(
            initialState: viewModel,
            reduce: updateModel,
            scheduler: MainScheduler.instance,
            scheduledFeedback: bindUI)
        .subscribe()
        .disposed(by: bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.activate()
    }

    private func setupUI() {
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }

    fileprivate func configureDataSource() {
        dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
            dataSource.sectionModels[sectionIndex].identity
        }
        dataSource.animationConfiguration = AnimationConfiguration(
            insertAnimation: .fade,
            reloadAnimation: .fade,
            deleteAnimation: .fade)
    }

    fileprivate func updateModel(model: SessionsViewModel, event: Event) -> SessionsViewModel {
        switch event {
        case .showSessionDetails(let session):
            showSessionDetails(session: session)
        case .themeRefresh:
            tableView.reloadData()
        }
        return model
    }

    private var bindUI: ((RxFeedback.ObservableSchedulerContext<SessionsViewModel>) -> Observable<SessionsViewController.Event>) {
        return RxFeedback.bind(self) { this, state in
            let subscriptions = [
                // sessions -> empty message
                state.flatMap { $0.sessions }
                    .map { sections in sections.count == 0 }
                    .distinctUntilChanged()
                    .subscribe(onNext: {show in
                        ContainerMessageView.toggle(this.view, visible: show, text: "¯\\_(ツ)_/¯\n\nNo sessions for that day and filter")
                    }),

                // sessions -> table
                state.flatMap { $0.sessions }
                    .bind(to: this.tableView.rx.items(dataSource: this.dataSource)),

                // set table delegate
                this.tableView.rx.setDelegate(this)
            ]

            let events = [
                // show session details
                this.tableView.rx.modelSelected(Session.self).map { Event.showSessionDetails($0) },

                // theme refresh
                Observable.from(object: EventData.default(in: RealmProvider.event), emitInitialValue: false, properties: ["_mainColor"])
                    .map { _ in Event.themeRefresh }
            ]

            return RxFeedback.Bindings(subscriptions: subscriptions, events: events)
        }
    }

    private func showSessionDetails(session: Session) {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
        navigator.show(segue: .sessionDetails(session), sender: self)
    }
}

// MARK: - UITableView delegate methods
extension SessionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionCount = dataSource.sectionModels.count
        return section != sectionCount-1 ? 0 : 44
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionCount = dataSource.sectionModels.count
        return section != sectionCount-1 ? nil : UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 180))
    }
}

// MARK: - IndicatorInfoProvider
extension SessionsViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: title ?? "no title")
    }
}
