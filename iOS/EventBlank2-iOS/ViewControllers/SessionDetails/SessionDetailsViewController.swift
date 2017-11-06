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

import EventBlankKit

class SessionDetailsViewController: UIViewController, ClassIdentifier, Navigatable {

    @IBOutlet weak var tableView: UITableView!

    private let bag = DisposeBag()
    private var viewModel: SessionDetailsViewModel!
    private lazy var dataSource = {
        return RxTableViewSectionedReloadDataSource<SessionSection>(configureCell: self.configureCell)
    }()

    var navigator: Navigator!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureDataSource()
        bindUI()
    }
    
    static func createWith(_ storyboard: UIStoryboard, viewModel: SessionDetailsViewModel) -> SessionDetailsViewController {
        return storyboard.instantiateViewController(SessionDetailsViewController.self).then { vc in
            vc.viewModel = viewModel
            vc.title = viewModel.session.title
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.activate()
    }
    
    private func setupUI() {
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    private func configureCell(dataSource: TableViewSectionedDataSource<SessionSection>, tableView: UITableView, indexPath: IndexPath, element: Session) -> UITableViewCell {
        let cell = SessionDetailsCell.createWith(dataSource, tableView: tableView, index: indexPath, session: element)
        cell.openWebsite = { [weak self] url in
            self?.navigator.show(segue: .webPage(url), sender: self, transition: .modal)
        }
        return cell
    }

    private func configureDataSource() {
        dataSource.titleForHeaderInSection = {_, section in nil}
        dataSource.titleForFooterInSection = {_, section in nil}
    }

    private func bindUI() {
        //bind the table view
        viewModel.tableItems
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
}
