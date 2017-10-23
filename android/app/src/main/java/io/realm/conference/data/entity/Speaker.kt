package io.realm.conference.data.entity

import io.realm.RealmModel
import io.realm.annotations.PrimaryKey
import io.realm.annotations.RealmClass
import io.realm.conference.data.model.SpeakerItem

@RealmClass
open class Speaker : RealmModel, SpeakerItem {

    @PrimaryKey
    override var uuid = ""
    override var name = ""

    override var visible: Boolean = false
    override var bio: String? = null
    override var url: String? = null
    override var twitter: String? = null
    override var photoUrl: String? = null

}
