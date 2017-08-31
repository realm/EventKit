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

import Foundation
import Social
import Accounts

import RxSwift
import SwiftyJSON
import Reachability

private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}

class TwitterProvider {
    struct Errors {
        static let domain = "TwitterProvider"
        static let authorizationFailed = 1
        static let malformedResponse = 2
    }
    
    fileprivate let backgroundWorkScheduler: ImmediateSchedulerType
    
    fileprivate struct Endpoint {
        static let friendship = URL(string: "https://api.twitter.com/1.1/friendships/show.json")!
        static let timeline = URL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")!
    }
    
    init() {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = QualityOfService.userInitiated
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    }
    
    func currentAccount() -> Observable<ACAccount?> {
        return Observable.create { observer in
            
            let accountStore = ACAccountStore()
            let accountType  = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
            
            accountStore.requestAccessToAccounts(with: accountType, options: nil, completion: {success, error in
                if success {
                    observer.onNext(accountStore.accounts(with: accountType).first as? ACAccount)
                } else {
                    observer.onNext(nil)
                }
            })
            return Disposables.create()
        }
        .observeOn(MainScheduler.instance)
        .retryOnConnect(default: nil)
    }
    
    func isFollowingUser(_ account: ACAccount, username: String) -> Observable<FollowingOnTwitter> {
        //prepare social network request
        let parameters: [String: String] = [
            "target_screen_name": username,
            "source_screen_name": account.username
        ]
        
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.GET,
            url: Endpoint.friendship,
            parameters: parameters
        )!
        
        request.account = account
        
        //send of url request
        let urlRequest = request.preparedURLRequest()!
        
        //observe response
        return URLSession.shared
            .rx.response(request: urlRequest)
            .retry(3)
            .observeOn(backgroundWorkScheduler)
            .map { httpResponse, data -> FollowingOnTwitter in
                if httpResponse.statusCode == 403 {
                    return .na
                }
                
                let json = JSON(data: data)
                
                let following = json["relationship"]["source"]["following"]
                guard following.exists() else {
                    return .notFollowing(username)
                }
                
                return .following(username)
            }
            .observeOn(MainScheduler.instance)
            .retryOnConnect(default: .na)
    }
    
    func timelineForUsername(_ account: ACAccount, username: String) -> Observable<[Tweet]?> {
        
        let parameters: [String: String] = [
            "screen_name" : username,
            "include_rts" : "0",
            "trim_user" : "0",
            "count" : "20"
        ]
        
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.GET,
            url: Endpoint.timeline,
            parameters: parameters
        )!
        
        request.account = account
        
        //send of url request
        let urlRequest = request.preparedURLRequest()!

        //observe response
        return URLSession.shared
            .rx.response(request: urlRequest)
            .retry(3)
            .observeOn(backgroundWorkScheduler)
            .map { httpResponse, data -> [Tweet] in
                let result = JSON(data: data)
                let tweets = result.map { _, object in
                    return Tweet(jsonObject: object)
                }
                .filter {$0 != nil}
                .map{ $0! }
                
                return tweets
            }
            .observeOn(MainScheduler.instance)
            .retryOnConnect(default: nil)
    }
}
