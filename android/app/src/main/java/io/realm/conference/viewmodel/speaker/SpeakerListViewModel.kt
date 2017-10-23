package io.realm.conference.viewmodel.speaker

import android.arch.lifecycle.LiveData
import android.arch.lifecycle.Transformations
import android.arch.lifecycle.ViewModel
import io.realm.Realm
import io.realm.conference.data.extensions.speakerDao
import io.realm.conference.data.model.SpeakerItem
import io.realm.conference.data.model.ViewSpeakerItem

class SpeakerListViewModel : ViewModel() {

    private val realmDb = Realm.getDefaultInstance()
    private val speakerDao = realmDb.speakerDao()

    val speakers : LiveData<List<SpeakerItem>>

    init {
        val speakerData = speakerDao.findAllAsync()

        speakers = Transformations.map(speakerData) { updatedSpeakers ->
            updatedSpeakers.map { ViewSpeakerItem(it) }
            .toList()
        }
    }

    override fun onCleared() {
        realmDb.close()
    }
}

