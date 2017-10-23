package io.realm.conference.viewmodel.schedule

import android.arch.lifecycle.LiveData
import android.arch.lifecycle.Transformations
import android.arch.lifecycle.ViewModel
import android.arch.lifecycle.ViewModelProvider
import io.realm.Realm
import io.realm.conference.data.entity.Session
import io.realm.conference.data.extensions.eventDataDao
import io.realm.conference.data.extensions.sessionDao
import io.realm.conference.data.model.ScheduleItem
import io.realm.conference.data.model.ViewScheduleItem
import java.util.*


class SessionDetailViewModel(val sessionId: String) : ViewModel() {

    private val db = Realm.getDefaultInstance()
    private val sessionDao = db.sessionDao()
    private val eventDao = db.eventDataDao()

    val session: LiveData<ScheduleItem>
    val event = eventDao.getEventData()

    init {
        val sessionEntityLiveData = sessionDao.findById(sessionId)

        session = Transformations.map(sessionEntityLiveData) { session ->
            ViewScheduleItem(session, event)
        }

    }

    override fun onCleared() {
        db.close()
    }

    class Factory(private val sessionId: String) : ViewModelProvider.NewInstanceFactory() {

        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return SessionDetailViewModel(sessionId) as T
        }
    }

}