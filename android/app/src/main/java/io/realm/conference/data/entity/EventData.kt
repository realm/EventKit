package io.realm.conference.data.entity

import io.realm.RealmModel
import io.realm.RealmObject
import io.realm.annotations.Ignore
import io.realm.annotations.RealmClass
import io.realm.annotations.Required
import io.realm.conference.util.format
import java.util.*

@RealmClass
open class EventData : RealmModel {

    var title = ""
    var subtitle = ""
    var organizer = ""
    var timeZone = ""
    var _mainColor = ""

    var logoUrl: String? = ""

    fun displayTimeZone() : TimeZone {
        val eventTimezoneString = this.timeZone
        return TimeZone.getTimeZone(eventTimezoneString) ?: TimeZone.getDefault()
    }

}
