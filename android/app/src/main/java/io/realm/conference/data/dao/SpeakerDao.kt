package io.realm.conference.data.dao

import android.arch.lifecycle.LiveData
import io.realm.Realm
import io.realm.RealmQuery
import io.realm.RealmResults
import io.realm.conference.data.entity.Speaker
import io.realm.conference.data.entity.SpeakerFields
import io.realm.conference.data.extensions.asLiveData
import io.realm.conference.data.extensions.where

class SpeakerDao(val db: Realm) {

    fun findByIdAsync(id: String) : LiveData<Speaker> {
        return where().equalTo(SpeakerFields.UUID, id).findFirstAsync().asLiveData()
    }

    fun findAllAsync() : LiveData<RealmResults<Speaker>> {
        return whereVisible().findAllSortedAsync(SpeakerFields.NAME).asLiveData()
    }
    
    fun findAll() : RealmResults<Speaker> {
        return whereVisible().findAllSorted(SpeakerFields.NAME)
    }

    private fun where() = db.where<Speaker>()

    private fun whereVisible() : RealmQuery<Speaker> {
        return where().equalTo(SpeakerFields.VISIBLE, true)
    }


}