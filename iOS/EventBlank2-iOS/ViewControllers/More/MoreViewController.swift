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
import Then
import RxDataSources
import RealmContent

import EventBlankKit

class MoreViewController: UIViewController, ClassIdentifier, Navigatable {

    @IBOutlet weak var tableView: UITableView!

    private let bag = DisposeBag()
    private let viewModel = MoreViewModel()
    private let dataSource = RxTableViewSectionedReloadDataSource<AnySection>(configureCell: MoreViewController.configureCell)

    private let footer = RealmView()
    var navigator: Navigator!

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.activate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.tableFooterView = footer
        tableView.tableFooterView!.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapLogo)))
    }

    @objc private func didTapLogo() {
        UIApplication.shared.open(URL(string: "https://realm.io")!, options: [:], completionHandler: nil)
    }

    private func bindUI() {
        //bind table
        viewModel.tableItems
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        //table view delegate
        tableView.rx.modelSelected(Any.self)
            .subscribe(onNext: {[weak self] object in
                guard let this = self else { return }

                if let model = object as? ContentPage {
                    this.navigator.show(segue: .content(model), sender: self)
                }
            })
            .disposed(by: bag)

        _ = tableView.rx.setDelegate(self)
    }


    private static func configureCell(dataSource: TableViewSectionedDataSource<AnySection>, tableView: UITableView, indexPath: IndexPath, element: Any) -> UITableViewCell {
        //the data source
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.section == 0 ? "MenuCell" : "ExtraMenuCell")!

        cell.imageView?.image = nil
        cell.textLabel?.isEnabled = true
        cell.accessoryType = .disclosureIndicator

        if let element = element as? ContentPage, indexPath.section == 0 {
            cell.textLabel?.text = element.title

        } else if let element = element as? String, indexPath.section == 1 {
            cell.textLabel?.text = element
        }
        return cell
    }
}

extension MoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
