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

class RealmView: UIView {

    private let logoView: UIImageView = {
        let image = UIImage(named: "realm-logo")!
        let lv = UIImageView(image: image)
        lv.contentMode = UIViewContentMode.scaleAspectFit
        lv.frame.size = image.size
        lv.layer.shadowRadius = 10.0
        lv.layer.shadowColor = UIColor.gray.cgColor
        lv.layer.shadowOpacity = 0.3
        lv.layer.shadowOffset = CGSize.zero
        return lv
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .orange
        label.textColor = .gray
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "This app is an open source project\n by Realm Inc and is powered by\n the Realm Mobile Platform 🚀"
        return label
    }()

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 150))
        backgroundColor = .clear
        clipsToBounds = true
        addSubview(logoView)
        addSubview(label)
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        logoView.frame.origin.y = 40
        logoView.frame.size = CGSize(width: frame.width * 0.33, height: 60)
        logoView.center.x = center.x * 0.95

        label.frame = CGRect(x: 0, y: logoView.frame.size.height + 40,
                             width: frame.size.width * 0.67, height: 50)
        label.center.x = center.x
    }
}
