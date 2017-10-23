package io.realm.conference.data.extensions

import android.arch.lifecycle.LiveData
import io.realm.RealmChangeListener
import io.realm.RealmModel
import io.realm.RealmResults

fun <T : RealmModel> T.asLiveData() = RealmModelLiveData<T>(this)

fun <T : RealmModel> RealmResults<T>.asLiveData() = RealmResultsLiveData<T>(this)

class RealmModelLiveData<T : RealmModel>(private val t: T) : LiveData<T>() {

    private val listener = RealmChangeListener<T> { t -> value = t }

    override fun onActive() {
        t.addChangeListener(listener)
    }

    override fun onInactive() {
        t.removeChangeListener(listener)
    }
}

class RealmResultsLiveData<T : RealmModel>(private val results: RealmResults<T>) :
      LiveData<RealmResults<T>>() {

    private val listener = RealmChangeListener<RealmResults<T>> {
        results -> value = results
    }

    override fun onActive() {
        results.addChangeListener(listener)
    }

    override fun onInactive() {
        results.removeChangeListener(listener)
    }
}
