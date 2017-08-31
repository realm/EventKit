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
import RelativeFormatter
import Kingfisher
import RxSwift
import RxGesture
import Then

class TweetCell: UITableViewCell, ClassIdentifier {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var attachmentImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    private var attachmentHeight: NSLayoutConstraint!
    private var reuseBag = DisposeBag()

    //MARK: lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        message.delegate = self
        
        attachmentHeight = attachmentImage.constraints.filter {
            $0.firstAttribute == NSLayoutAttribute.height && $0.relation == NSLayoutRelation.equal
        }.first!
    }
    
    static func createWith(_ tv: UITableView, tweet: Tweet) -> TweetCell {
        return tv.dequeueReusableCell(TweetCell.self).then {cell in
            cell.populateFromTweet(tweet)
        }
    }

    fileprivate func populateFromTweet(_ tweet: Tweet) {

        message.text = tweet.text
        message.selectedRange = NSRange(location: 0, length: 0)

        timeLabel.text = tweet.created.relativeFormatted()

        //attachment image
        if let attachmentUrl = tweet.imageUrl {
            attachmentImage.kf.setImage(with: attachmentUrl, placeholder: nil, options: nil, completionHandler: {[weak self] (fullImage, error, cacheType, imageURL) -> () in
                if let this = self {
                    fullImage?.asyncToSize(.fill(this.attachmentImage.bounds.width, 150), cornerRadius: 5.0, completion: {result in
                        this.attachmentImage.image = result
                        this.attachmentImage.rx.tapGesture().when(.recognized)
                            .subscribe(onNext: {_ in
                            PhotoPopupView.showImage(fullImage!,
                                inView: UIApplication.shared.windows.first!)
                            })
                            .disposed(by: this.reuseBag)
                    })
                }
            })
            attachmentHeight.constant = 148.0
        }
        
        //attached url
        if let url = tweet.url {
            rx.taps.subscribe(onNext: {_ in
                openUrl(url)
            })
            .disposed(by: reuseBag)
        }
        
        //user info
        nameLabel.text = tweet.user?.name

        if let avatarUrl = tweet.user?.avatarUrl {
            userImage.kf.setImage(with: avatarUrl, placeholder: nil, options: nil, completionHandler: {[weak self] (image, error, cacheType, imageURL) -> () in
                if let this = self, let image = image {
                    image.rx.resizedImage(.fillSize(this.userImage.bounds.size), cornerRadius: 4)
                        .observeOn(MainScheduler.instance)
                        .bind(to: this.userImage.rx.image)
                        .disposed(by: this.reuseBag)
                }
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reuseBag = DisposeBag()
        attachmentImage?.image = nil
        attachmentHeight.constant = 1.0
        userImage.image = nil
    }

    func textView(_ textView: UITextView, shouldInteractWithURL URL: Foundation.URL, inRange characterRange: NSRange) -> Bool {
        openUrl(URL)
        return false
    }
}
