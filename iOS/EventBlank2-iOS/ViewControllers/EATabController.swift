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

import RealmSwift
import RealmContent
import SwiftMessages
import DynamicColor

import EventBlankKit

class EATabController: UITabBarController {
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindUI()
    }

    func bindUI() {
        let dataSource = ContentListDataSource(style: .plain)
        dataSource.loadContent(from: RealmProvider.event.realm)

        let annResults = dataSource.asResults().filter("tag = %@", "announcement")
        let announcements = Observable<Results<ContentPage>>.collection(from: annResults)
            .shareReplay(1)

        // show messages
        announcements
            .subscribe(onNext: { [weak self] announcements in
                guard let this = self,
                    let ann = announcements.first else { return }

                this.observe(message: ann)
            })
            .disposed(by: bag)

        // hide messages
        announcements
            .filter { $0.count == 0 }
            .subscribe(onNext: { _ in
                SwiftMessages.hideAll()
            })
            .disposed(by: bag)
    }

    private var messageBag = DisposeBag()
    private static let defaultsKey = "EATabController.defaultsKey"

    private func observe(message: ContentPage) {
        messageBag = DisposeBag()

        Observable.collection(from: message.elements)
            .filter { $0.count > 0 && !$0.first!.content.isEmpty }
            .map { $0.first! }
            .filter {
                guard let lastMessage = UserDefaults.standard.string(forKey: EATabController.defaultsKey) else {
                    return true
                }
                return lastMessage != $0.content
            }
            .subscribe(onNext: { [weak self] announcement in
                self?.show(text: announcement.content, url: URL(string: announcement.url ?? ""))
            })
            .disposed(by: messageBag)
    }

    private func show(text: String, url: URL?) {
        SwiftMessages.hide()

        let color = EventData.default(in: RealmProvider.event).mainColor

        let info = MessageView.viewFromNib(layout: .MessageView)
        info.configureTheme(.info)
        info.backgroundColor = color.lighter(amount: 0.25).desaturated()
        info.button?.isHidden = false
        info.button?.backgroundColor = color.lighter(amount: 0.4).desaturated()
        info.tapHandler = { _ in
            guard let url = url else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        info.configureContent(title: "Info", body: text,
                              iconImage: nil, iconText: nil,
                              buttonImage: nil, buttonTitle: "Hide",
                              buttonTapHandler: { _ in
                                UserDefaults.standard.set(text, forKey: EATabController.defaultsKey)
                                UserDefaults.standard.synchronize()
                                SwiftMessages.hide()
        })

        var infoConfig = SwiftMessages.defaultConfig
        infoConfig.presentationStyle = .bottom
        infoConfig.duration = .forever

        SwiftMessages.show(config: infoConfig, view: info)
    }
}
