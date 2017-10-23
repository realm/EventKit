package io.realm.conference.data.entity

import io.realm.RealmModel
import io.realm.annotations.RealmClass

@RealmClass
open class ContentElement : RealmModel {
    var type: String = ""
    var content: String = ""
    var url: String? = null
}
