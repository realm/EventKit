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
import RxSwift

import UserNotifications

import EventBlankKit
import Kingfisher

struct SessionNotificationContent {
    let uuid: String
    let date: Date
    let title: String
    let description: String
    let photoUrl: String?

    static func create(from session: Session) -> SessionNotificationContent {
        // prepare
        let reminderDate = session.date.adjust(.minute, offset: -15)
        var fullDescription = "\(session.title) (\(session.speaker?.name ?? ""))"
        if let location = session.location?.location {
            fullDescription += "\nin \(location)"
        }
        fullDescription += session.sessionDescription

        // create
        return SessionNotificationContent(
            uuid: session.uuid,
            date: reminderDate,
            title: session.title,
            description: session.sessionDescription,
            photoUrl: session.speaker?.photoUrl)
    }
}

class Notifications {

    private static func createNotification(for session: SessionNotificationContent) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = session.title
        content.body = session.description
        content.userInfo = ["uuid": session.uuid]

        if let photoUrl = session.photoUrl {
            let url = URL(fileURLWithPath: ImageCache.default.cachePath(forKey: photoUrl))

            do {
                let photo = try UNNotificationAttachment(identifier: photoUrl, url: url, options: [:])
                content.attachments = [photo]
            }
            catch { /* the photo is not cached yet, simply don't use it */ }
        }
        content.sound = UNNotificationSound.default()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: session.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(identifier: session.uuid, content: content, trigger: trigger)
    }

    static func scheduleNotification(for session: SessionNotificationContent) -> Observable<UNNotificationRequest> {
        let request = createNotification(for: session)

        return Observable<UNNotificationRequest>.create { observer in
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                observer.onCompleted()
            })
            return Disposables.create {}
        }
    }

    enum NotificationErrors: Error {
        case notFound, accessDenied
    }

    private static func pendingNotification(for session: SessionNotificationContent) -> Observable<UNNotificationRequest?> {
        let notificationCenter = UNUserNotificationCenter.current()
        let uuid = session.uuid

        return Observable<UNNotificationRequest?>.create { observer in
            notificationCenter.getPendingNotificationRequests { (requests) in
                let result = requests.filter { request in
                    return request.identifier == uuid
                }
                observer.onNext( result.isEmpty ? nil : result.first! )
                observer.onCompleted()
            }
            return Disposables.create { }
        }
    }

    static func toggleNotification(for session: Session, on: Bool) -> Observable<UNNotificationRequest> {
        let sessionContent = SessionNotificationContent.create(from: session)

        let pending = local
            .flatMap {
                return pendingNotification(for: sessionContent)
                    .share(replay: 1)
            }

        if on {
            return pending
                .filter { $0 == nil }
                .flatMap { _ in
                    return scheduleNotification(for: sessionContent)
                }
        } else {
            return pending
                .filter { $0 != nil }
                .map { $0! }
                .do(onNext: { request in
                    UNUserNotificationCenter.current()
                        .removePendingNotificationRequests(withIdentifiers: [request.identifier])
                })
        }
    }

    private static var bag = DisposeBag()

    static var local: Observable<Void> {
        let notificationCenter = UNUserNotificationCenter.current()

        return Observable<Void>.create { observer in

            notificationCenter.getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized && settings.alertSetting == .enabled {
                    observer.onNext(())
                    observer.onCompleted()
                } else if settings.authorizationStatus == .notDetermined {
                    askForPermission()
                        .subscribe(onError: {_ in
                            observer.onCompleted()
                        }, onCompleted: {
                            observer.onNext(())
                            observer.onCompleted()
                        })
                        .disposed(by: bag)
                } else {
                    observer.onCompleted()
                }
            }

            return Disposables.create { }
        }
    }

    static func askForPermission() -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                    guard granted else {
                        observer.onCompleted()
                        return
                    }
                    observer.onError(NotificationErrors.accessDenied)
                }
            return Disposables.create { }
        }
    }
}
