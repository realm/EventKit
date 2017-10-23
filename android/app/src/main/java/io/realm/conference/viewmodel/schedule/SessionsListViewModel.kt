package io.realm.conference.viewmodel.schedule

import android.arch.lifecycle.LiveData
import android.arch.lifecycle.Transformations
import android.arch.lifecycle.ViewModel
import android.arch.lifecycle.ViewModelProvider
import io.realm.Realm
import io.realm.conference.data.extensions.*
import io.realm.conference.data.model.ViewScheduleItem
import io.realm.conference.data.model.ScheduleItem
import java.util.*

class SessionsListViewModel(conferenceDay: Long) : ViewModel() {

    private val realmDb = Realm.getDefaultInstance()
    private val sessionDao = realmDb.sessionDao()
    private val eventDao = realmDb.eventDataDao()

    private val event = eventDao.getEventData()

    val sessionItems : LiveData<List<ScheduleItem>>

    init {
        val date = Date(conferenceDay)

        val currentDaySessions = sessionDao.findAllOnDateAsync(date).asLiveData()

        sessionItems = Transformations.map(currentDaySessions) { updatedSessions ->
           updatedSessions
                    .map { ViewScheduleItem(it, event) }
                    .toList()
        }
    }

    override fun onCleared() {
        realmDb.close()
    }

    class Factory(private val conferenceDay: Long) : ViewModelProvider.NewInstanceFactory() {

        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return SessionsListViewModel(conferenceDay) as T
        }
    }



}