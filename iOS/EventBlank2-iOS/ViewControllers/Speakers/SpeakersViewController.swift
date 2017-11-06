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

class SpeakersViewController: UIViewController, Navigatable {
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var btnSearch: UIBarButtonItem!
    var btnFavorites = FavoritesBarButtonItem.instance()

    private let bag = DisposeBag()
    internal let viewModel = SpeakersViewModel()
    private let dataSource = RxTableViewSectionedAnimatedDataSource<SpeakerSection>(configureCell: SpeakerCell.createWith)

    var navigator: Navigator!

    // search bar
    let searchController = UISearchController(searchResultsController:  nil)
    let searchBarBtnCancel = PublishSubject<Void>()
    internal let active = Variable<Bool>(false)

    private enum Event {
        case toggleOnlyFavorites(Bool)
        case showSpeakerDetails(Speaker)
        case themeRefresh
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
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
        active.value = true

        if let target = navigationController?.navigationBar.topItem?.rightBarButtonItem?.customView {
            Tutorial.showSpeakersTutorial(target: target)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        active.value = false
    }

    func setupUI() {
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        btnFavorites.button.tintColor = UIColor.white
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

    // bind
    private func updateModel(model: SpeakersViewModel, event: Event) -> SpeakersViewModel {
        switch event {
        case .toggleOnlyFavorites(let onlyFavorites):
            model.updateOnlyFavorites(to: onlyFavorites)
        case .showSpeakerDetails(let speaker):
            showSpeakerDetails(speaker: speaker)
        case .themeRefresh:
            btnFavorites.updateBackgroundColor()
        }
        return model
    }

    private var bindUI: ((RxFeedback.ObservableSchedulerContext<SpeakersViewModel>) -> Observable<SpeakersViewController.Event>) {
        return RxFeedback.bind(self) { this, state in
            let subscriptions = [
                // speakers -> table
                this.viewModel.speakers
                    .bind(to: this.tableView.rx.items(dataSource: this.dataSource)),

                // favorites button
                this.viewModel.onlyFavorites.asObservable()
                    .bind(to: this.btnFavorites.rx.isSelected),

                // no items message
                this.viewModel.speakers
                    .map { sections in sections.count == 0 }
                    .distinctUntilChanged()
                    .startWith(false)
                    .subscribe(onNext: { show in
                        ContainerMessageView.toggle(this.view, visible: show, text: "¯\\_(ツ)_/¯\n\nNo speakers found for that filter")
                    })
            ] + this.bindingsSearchBar()

            let events = [
                // toggle only favorites
                this.viewModel.onlyFavorites.asObservable()
                    .sample(this.btnFavorites.button.rx.tap)
                    .map { Event.toggleOnlyFavorites(!$0) },

                // model selected
                this.tableView.rx.modelSelected(Speaker.self).map { Event.showSpeakerDetails($0) },

                // theme refresh
                Observable.from(object: EventData.default(in: RealmProvider.event), emitInitialValue: false, properties: ["_mainColor"])
                    .map { _ in Event.themeRefresh }
            ]

            return RxFeedback.Bindings(subscriptions: subscriptions, events: events)
        }
    }

    private func showSpeakerDetails(speaker: Speaker) {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
        navigator.show(segue: .speakerDetails(speaker, twitter: TwitterProvider()), sender: self)
    }
}

extension SpeakersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView().then { $0.backgroundColor = .clear }
    }
}
