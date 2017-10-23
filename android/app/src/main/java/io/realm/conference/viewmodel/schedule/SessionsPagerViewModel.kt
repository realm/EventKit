package io.realm.conference.viewmodel.schedule

import android.arch.lifecycle.ViewModel
import io.realm.Realm
import io.realm.RealmResults
import io.realm.conference.data.entity.Session
import io.realm.conference.data.extensions.eventDataDao
import io.realm.conference.data.extensions.sessionDao
import io.realm.conference.util.format
import io.realm.conference.util.truncateTime
import java.util.*

class SessionsPagerViewModel : ViewModel() {

    private val realmDb = Realm.getDefaultInstance()
    private val sessionDao = realmDb.sessionDao()
    private val eventDao = realmDb.eventDataDao()

    private val event = eventDao.getEventData()
    private val allSessions = sessionDao.findAll()
    private var uniqueScheduleDates = determineUniqueScheduleDays(allSessions)

    private var cachedCurrentDaySessions : RealmResults<Session>? = null

    var conferenceDay = 0  // day of conference.  For example 3 day conferences has days 0..2
    set(value) {
        field = value
        currentDaySessions(refresh=true) // refresh current day sessions
    }

    private fun determineUniqueScheduleDays(allSessions: RealmResults<Session>) : List<Date?> {
        val groupedSessions = allSessions.groupBy { it.beginTime?.truncateTime() }
        val keys = groupedSessions.keys.sortedBy { it }
        val asList = keys.toList()
        return asList
    }

    fun getTitleFor(position: Int) : String {
        val sessionStartTime = uniqueScheduleDates[position]
        return sessionStartTime?.format("EEE",
                event?.displayTimeZone() ?: TimeZone.getDefault()) ?: "Day ${position + 1}"
    }

    fun getDayCount() : Int {
        return uniqueScheduleDates.size
    }

    fun getDateFor(position: Int) : Long {
        return uniqueScheduleDates[position]?.time!!
    }

    fun currentDaySessions(refresh: Boolean = false) : RealmResults<Session> {
        if(cachedCurrentDaySessions == null || refresh) {
            cachedCurrentDaySessions = sessionDao.findAllOnDateAsync(uniqueScheduleDates[conferenceDay]!!)
        }
        return cachedCurrentDaySessions!!
    }

    override fun onCleared() {
        realmDb.close()
    }
}
