/*
 * Copyright (c) 2016-2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import UIKit
import SafariServices
import AcknowList

import RxCocoa
import RealmContent

import EventBlankKit

protocol Navigatable {
    var navigator: Navigator! { get set }
}

class Navigator {
    static var `default`: Navigator = { return Navigator() }()
    lazy private var defaultStoryboard = UIStoryboard(name: "Main", bundle: nil)

    // MARK: - segues list
    enum Scene {
        enum Transition {
            case root(in: UIWindow)
            case navigation, modal
        }

        // all app scenes
        case tabs
        case sessions(Schedule.Day)
        case sessionDetails(Session)
        case speakerDetails(Speaker, twitter: TwitterProvider)
        case webPage(URL)
        case acknowledgements
        case content(ContentPage)
    }

    // MARK: - get a single VC
    func get(segue: Scene, storyboard: UIStoryboard) -> UIViewController {
        switch segue {

        case .tabs:
            return storyboard.instantiateViewController(withIdentifier: "AppTabs") as! UITabBarController

        case .sessions(let day):
            let vm = SessionsViewModel(day: day)
            return SessionsViewController.createWith(storyboard, viewModel: vm)

        case .sessionDetails(let session):
            let vm = SessionDetailsViewModel(session: session)
            return SessionDetailsViewController.createWith(storyboard, viewModel: vm)

        case .speakerDetails(let speaker, _):
            let vm = SpeakerDetailsViewModel(speaker: speaker)//, twitterProvider: twitter)
            return SpeakerDetailsViewController.createWith(storyboard, viewModel: vm)

        case .webPage(let url):
            let safari = SFSafariViewController(url: url)
            safari.hidesBottomBarWhenPushed = true
            return safari

        case .acknowledgements:
            return AcknowListViewController()

        case .content(let page):
            return ContentViewController(page: page)
        }
    }

    // MARK: - invoke a single segue
    func show(segue: Scene, sender: UIViewController?, transition: Scene.Transition = .navigation) {
        let storyboard = sender?.storyboard ?? defaultStoryboard
        let target = get(segue: segue, storyboard: storyboard)

        show(target: target, sender: sender, transition: transition)
    }

    private func show(target: UIViewController, sender: UIViewController?, transition: Scene.Transition) {
        injectNavigator(in: target)

        switch transition {
        case .root(in: let window):
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = target
            }, completion: nil)
            return;
        default: break
        }

        guard let sender = sender else {
            fatalError("You need to pass in a sender for .navigation or .modal transitions")
        }

        if let nav = sender as? UINavigationController {
            //push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }

        switch transition {
        case .navigation:
            if let nav = sender.navigationController {
                //add controller to navigation stack
                nav.pushViewController(target, animated: true)
            }
        case .modal:
            //present modally
            sender.present(target, animated: true, completion: nil)
        default: break
        }
    }

    private func injectNavigator(in target: UIViewController) {
        // view controller
        if var target = target as? Navigatable {
            target.navigator = self
            return
        }

        // tabs
        if let target = target as? UITabBarController, let children = target.viewControllers {
            for vc in children {
                injectNavigator(in: vc)
            }
        }

        // navigation controller
        if let target = target as? UINavigationController, let root = target.viewControllers.first {
            injectNavigator(in: root)
        }
    }
}
