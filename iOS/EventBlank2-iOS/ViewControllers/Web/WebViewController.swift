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
import WebKit
import Reachability

import RxSwift
import RxCocoa
import RxFeedback
import Then
import Async

class WebViewController: UIViewController, ClassIdentifier {

    private let bag = DisposeBag()
    private let webView = WKWebView()
    private let loadingIndicator = UIView()

    private enum State {
        case inactive, loading, ready
    }

    private enum Event {
        case loadPage
    }

    private var url: URL!

    // MARK: create
    
    static func createWith(_ storyboard: UIStoryboard, url: URL) -> WebViewController {
        return storyboard.instantiateViewController(WebViewController.self).then { vc in
            vc.url = url
        }
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        webView.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingIndicator.removeFromSuperview()
    }
    
    // MARK: setup UI
    
    func setupUI() {
        webView.frame.size.height -= ((UIApplication.shared.windows.first!).rootViewController! as! UITabBarController).tabBar.frame.size.height
        webView.backgroundColor = UIColor.red
        view.addSubview(webView)

        //setup loading indicator
        loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.15)
        navigationController?.navigationBar.addSubview(loadingIndicator)

        webView.load(URLRequest(url: url))
        title = url.host
    }

    // MARK: bind UI
    private func bindUI() {
        let this = self
        let progress = this.webView.rx.observe(Double.self, "estimatedProgress").shareReplay(1)

        [   //show/hide progress
            progress
                .unwrap()
                .map {$0 > 0.99}
                .bind(to: this.loadingIndicator.rx.isHidden),

            //update progress bar
            progress
                .bind(onNext: this.displayProgress)

        ].forEach { $0.disposed(by: bag) }
    }

    // MARK: private

    func displayProgress(_ progress: Double?) {
        guard let progress = progress else { return }

        self.title = webView.title ?? webView.url?.absoluteString
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            self.loadingIndicator.frame = CGRect(
                x: 0, y: 0,
                width: self.navigationController!.navigationBar.bounds.size.width * CGFloat(self.webView.estimatedProgress),
                height: self.navigationController!.navigationBar.bounds.size.height)
            
            }, completion: { _ in
                if progress > 0.95 {
                    DispatchQueue.main.async {
                        //hide the loading indicator
                        UIView.animate(withDuration: 0.2, animations: {
                            self.loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.15)
                        }, completion: {_ in
                            self.loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.15)
                        })
                    }
                }
        })
    }
    
    //TODO: add reachability to the view controller
    
    func __loadInitialURL() {
//        //not connected message
//        let reach = Reachability(hostName: initialURL!.host)
//        if !reach.isReachable() {
//            //show the message
//            view.addSubview(MessageView(text: "It certainly looks like you are not connected to the Internet right now..."))
//            
//            //show a reload button
//            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "loadInitialURL")
//            
//            return
//        }

        ContainerMessageView.removeViewFrom(view)
        navigationItem.rightBarButtonItem = nil
    }
}
