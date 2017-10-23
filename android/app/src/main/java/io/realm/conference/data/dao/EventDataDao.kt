package io.realm.conference.data.dao

import android.arch.lifecycle.LiveData
import io.realm.Realm
import io.realm.RealmResults
import io.realm.conference.data.entity.EventData
import io.realm.conference.data.extensions.asLiveData
import io.realm.conference.data.extensions.where

class EventDataDao(val db: Realm) {

    fun getEventData() : EventData? {
        return where().findFirst()
    }

    fun getEventDataAsync() : LiveData<EventData> {
        return where().findFirstAsync().asLiveData()
    }

    fun findAll() : RealmResults<EventData> {
        return where().findAll()
    }

    private fun where() = db.where<EventData>()

}