package io.realm.conference.viewmodel.more

import android.arch.lifecycle.ViewModel
import io.realm.Realm
import io.realm.RealmResults
import io.realm.conference.data.entity.ContentPage
import io.realm.conference.data.extensions.contentPageDao

class MoreViewModel : ViewModel() {

    private val db = Realm.getDefaultInstance()
    private val contentPageDao = db.contentPageDao()

    fun contentPages() : RealmResults<ContentPage> {
        return contentPageDao.findInfoPagesAsync()
    }

    override fun onCleared() {
        db.close()
    }

}