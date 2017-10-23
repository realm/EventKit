package io.realm.conference.data.entity

import io.realm.RealmList
import io.realm.RealmModel
import io.realm.annotations.Index
import io.realm.annotations.PrimaryKey
import io.realm.annotations.RealmClass

@RealmClass
open class ContentPage : RealmModel {

    @PrimaryKey
    var uuid: String = ""

    @Index
    var tag: String = ""

    @Index
    var priority: Long = 0
    var mainColor: String? = null
    var lang: String? = null
    var title: String? = null
    var elements: RealmList<ContentElement>? = null

}
