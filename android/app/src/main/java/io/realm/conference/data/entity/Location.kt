package io.realm.conference.data.entity

import io.realm.RealmModel
import io.realm.annotations.RealmClass

@RealmClass
open class Location : RealmModel {
    var location = ""
    var locationDescription = ""
}
