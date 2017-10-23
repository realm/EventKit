package io.realm.conference.data.model

import io.realm.conference.data.entity.EventData
import io.realm.conference.data.entity.Session
import io.realm.conference.util.format

/**
 * Delegate all calls to the backing session entity, except what is overridden here.
 */
class ViewScheduleItem(val session: Session, val event: EventData?) : ScheduleItem by session {

    override val speakerPhotoUrl: String
        get() = session.speaker?.photoUrl ?: ""

    override val locationName: String
        get() = session.location?.location ?: ""

    override val trackName: String
        get() = session.track?.track ?: ""

    override val startTimeInEventTimeZone: String
        get() = beginTime?.format("h:mm a", event?.displayTimeZone()) ?: ""

    override val startDayInEventTimeZone: String
        get() = beginTime?.format("EEE, MMM dd", event?.displayTimeZone()) ?: ""
}

