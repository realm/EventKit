package io.realm.conference.viewmodel.main

import android.arch.lifecycle.ViewModel
import io.realm.Realm
import io.realm.conference.data.extensions.eventDataDao

class MainViewModel : ViewModel() {

    private val db = Realm.getDefaultInstance()
    private val eventDataDao = db.eventDataDao()

    val eventLiveData = eventDataDao.getEventDataAsync()

    override fun onCleared() {
        db.close()
    }
}