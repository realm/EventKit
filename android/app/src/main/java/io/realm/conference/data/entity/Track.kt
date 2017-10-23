package io.realm.conference.data.entity

import io.realm.RealmObject
import io.realm.annotations.RealmClass

@RealmClass
open class Track : RealmObject() {
    var track: String = ""
    var trackDescription = ""
}
