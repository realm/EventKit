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

//MARK: search
extension SpeakersViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    func setupSearchBar() {
        //search bar
        searchController.searchBar.delegate = self

        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
    }
    
    func toggleSearchBarVisibility(_ visible: Bool) {
        if visible {
            self.searchController.searchBar.alpha = 0
            self.view.addSubview(self.searchController.searchBar)
            self.view.layoutIfNeeded()
            self.searchController.searchBar.center = CGPoint(
                x: self.tableView.frame.midX,
                y: self.searchController.searchBar.frame.height/2)

            UIView.animate(withDuration: 0.5, delay: 0.15, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: [], animations: {
                self.view.constraints
                    .filter { $0.identifier == "tabletop" }
                    .forEach { $0.constant = self.searchController.searchBar.frame.height }
                self.view.layoutIfNeeded()
                self.searchController.searchBar.alpha = 1
            }, completion: nil)
        } else {
            self.searchController.searchBar.removeFromSuperview()
            UIView.animate(withDuration: 0.5, delay: 0.15, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: [], animations: {
                self.view.constraints
                    .filter { $0.identifier == "tabletop" }
                    .forEach { $0.constant = 0 }
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarBtnCancel.onNext(())
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //placeholder
    }

    internal func bindingsSearchBar() -> [Disposable] {
        // is search bar currently active
        let searchBarActive = Observable<Bool>.merge([btnSearch.rx.tap.replaceWith(true), searchBarBtnCancel.replaceWith(false)])
            .startWith(false)
            .share(replay: 1)

        return [
            //search bar color
            viewModel.eventData
                .map { return $0.mainColor }
                .subscribe(onNext: { [weak self] color in
                    self?.searchController.searchBar.barTintColor = color
                }),

            //bind search bar
            searchController.searchBar.rx.text.orEmpty
                .bind(to: viewModel.searchTerm),

            //present/dismiss search bar
            searchBarActive.subscribe(onNext: toggleSearchBarVisibility),

            //show/hide the bar
            Observable.combineLatest(searchBarActive, active.asObservable(), resultSelector: { (a, b) -> Bool in
                return a && b
            })
            .bind(to: searchController.searchBar.rx.visible),

            //show/hide nav buttons
            searchBarActive
                .subscribe(onNext: {[unowned self] hideButtons in
                    self.navigationItem.leftBarButtonItem = hideButtons ? nil : self.btnSearch
                }),

            //hide keyboard
            active.asObservable().filterOut(true)
                .subscribe(onNext: { [unowned self]_ in
                    self.view.endEditing(true)
                }),

            searchBarActive.bind(to: searchController.searchBar.rx.isFirstResponder),
            searchBarActive.filterOut(true).replaceWith("").bind(to: viewModel.searchTerm)
        ]
    }
}
