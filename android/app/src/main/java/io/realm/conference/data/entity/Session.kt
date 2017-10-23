package io.realm.conference.data.entity

import io.realm.RealmModel
import io.realm.annotations.PrimaryKey
import io.realm.annotations.RealmClass
import io.realm.conference.data.model.ScheduleItem
import io.realm.conference.util.format
import java.util.*

@RealmClass
open class Session : RealmModel, ScheduleItem {

    @PrimaryKey
    override var uuid = ""
    override var title = ""
    override var sessionDescription = ""

    override var beginTime: Date? = null
    override var lengthInMinutes: Long = 0
    override var visible: Boolean = false

    var track: Track? = null
    var location: Location? = null
    var speaker: Speaker? = null

    override val startTimeInEventTimeZone: String
        get() = super.startTimeInEventTimeZone

    fun startTimeStringInTz(timeZone: TimeZone?) : String {
        return beginTime?.format("h:mm a", timeZone ?: TimeZone.getDefault()) ?: ""
    }

}
