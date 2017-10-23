package io.realm.conference.viewmodel.speaker

import android.arch.lifecycle.LiveData
import android.arch.lifecycle.Transformations
import android.arch.lifecycle.ViewModel
import android.arch.lifecycle.ViewModelProvider
import io.realm.Realm
import io.realm.conference.data.extensions.speakerDao
import io.realm.conference.data.model.ViewSpeakerItem

class SpeakerDetailViewModel(val id: String) : ViewModel() {

    private val realmDb = Realm.getDefaultInstance()
    private val speakerDao = realmDb.speakerDao()

    val speaker : LiveData<ViewSpeakerItem>

    init {
        val speakerData = speakerDao.findByIdAsync(id)
        speaker = Transformations.map(speakerData) { updatedSpeaker ->
            ViewSpeakerItem(updatedSpeaker)
        }
    }

    override fun onCleared() {
        realmDb.close()
    }

    class Factory(private val id: String) : ViewModelProvider.NewInstanceFactory() {

        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return SpeakerDetailViewModel(id) as T
        }
    }

}



