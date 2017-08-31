//
//  Tutorial.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 8/28/17.
//  Copyright © 2017 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit
import KRWalkThrough

class Tutorial {
    @objc func hideCurrentTutorial() {
        guard let item = TutorialManager.shared.currentItem else { return }
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [], animations: {
            item.view.alpha = 0.0
        }, completion: {_ in
            TutorialManager.shared.hideTutorial()
        })
    }

    static func shouldShow(id: String) -> Bool {
        if let _ = UserDefaults.standard.string(forKey: id) {
            return false
        }
        UserDefaults.standard.set(id, forKey: id)
        UserDefaults.standard.synchronize()
        return true
    }

    private static func addCenteredLabel(text: String, to view2: UIView) {

        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.text = text
        label2.textColor = .white
        label2.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        label2.numberOfLines = 0

        let bg = UIView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.backgroundColor = UIColor(white: 0.0, alpha: 0.45)
        bg.layer.cornerRadius = 10
        bg.layer.masksToBounds = true

        bg.addSubview(label2)
        view2.addSubview(bg)

        bg.leadingAnchor.constraint(equalTo: label2.leadingAnchor, constant: -20).isActive = true
        bg.trailingAnchor.constraint(equalTo: label2.trailingAnchor, constant: +20).isActive = true
        bg.topAnchor.constraint(equalTo: label2.topAnchor, constant: -20).isActive = true
        bg.bottomAnchor.constraint(equalTo: label2.bottomAnchor, constant: +20).isActive = true

        view2.addConstraints([
            NSLayoutConstraint(item: bg, attribute: .width, relatedBy: .equal, toItem: view2, attribute: .width, multiplier: 0.8, constant: 0.0),
            NSLayoutConstraint(item: bg, attribute: .centerX, relatedBy: .equal, toItem: view2, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bg, attribute: .centerY, relatedBy: .equal, toItem: view2, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            ])
    }

    static func showScheduleTutorial(target: UIView, id: String = #file) {
        guard shouldShow(id: id) else { return }

        let view2 = TutorialView(frame: UIScreen.main.bounds)
        view2.makeAvailable(view: target, radiusInset: 20.0)

        addCenteredLabel(text: "To build your own personalized schedule toggle the ♥️ button on all your preferred sessions and then tap the favorites filter button on the top right.\n\n"
            + "If you don't want to miss any of your favorite sessions, allow the app to notify you when the system dialogue pops up.", to: view2)

        view2.addGestureRecognizer(UITapGestureRecognizer(target: tutorial, action: #selector(hideCurrentTutorial)))
        view2.alpha = 0.0

        TutorialManager.shared.register(item: TutorialItem(view: view2, identifier: id))
        TutorialManager.shared.showTutorial(withIdentifier: id)

        UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseIn], animations: {
            view2.alpha = 1.0
        })
    }

    static func showSpeakersTutorial(target: UIView, id: String = #file) {
        guard shouldShow(id: id) else { return }

        let view2 = TutorialView(frame: UIScreen.main.bounds)
        view2.makeAvailable(view: target, radiusInset: 20.0)

        addCenteredLabel(text: "Mark speakers as favorite to automatically add their sessions to your personalized schedule.\n\n"
            + "Authorize the app to access your Twitter account to see the speaker's tweet feed.", to: view2)

        view2.addGestureRecognizer(UITapGestureRecognizer(target: tutorial, action: #selector(hideCurrentTutorial)))
        view2.alpha = 0.0

        TutorialManager.shared.register(item: TutorialItem(view: view2, identifier: id))
        TutorialManager.shared.showTutorial(withIdentifier: id)

        UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseIn], animations: {
            view2.alpha = 1.0
        })
    }
}

private let tutorial = Tutorial()
