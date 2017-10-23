package io.realm.conference.data.model

import java.util.*

interface ScheduleItem {

    val uuid: String
    val title: String
    val sessionDescription: String

    val beginTime: Date?
    val lengthInMinutes: Long
    val visible: Boolean


    val speakerPhotoUrl: String
        get() { return "" }

    val locationName: String
        get() { return "" }

    val trackName: String
        get() { return "" }

    val startTimeInEventTimeZone : String
        get() { return "" }

    val startDayInEventTimeZone: String
        get() { return "" }
}
