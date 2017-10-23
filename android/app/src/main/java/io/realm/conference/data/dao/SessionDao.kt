package io.realm.conference.data.dao

import android.arch.lifecycle.LiveData
import io.realm.Realm
import io.realm.RealmQuery
import io.realm.RealmResults
import io.realm.conference.data.entity.Session
import io.realm.conference.data.entity.SessionFields
import io.realm.conference.data.extensions.asLiveData
import io.realm.conference.data.extensions.where
import io.realm.conference.util.ceil
import io.realm.conference.util.floor
import java.util.*

class SessionDao(val db: Realm) {

    fun findAllAsync() : LiveData<RealmResults<Session>> {
        return whereVisible().findAllSortedAsync(SessionFields.BEGIN_TIME).asLiveData()
    }

    fun findAll() : RealmResults<Session> {
        return whereVisible().findAllSorted(SessionFields.BEGIN_TIME)
    }

    fun findAllOnDateAsync(date: Date) : RealmResults<Session> {
        return whereVisible()
                .between(SessionFields.BEGIN_TIME, date.floor(), date.ceil())
                .findAllSortedAsync(SessionFields.BEGIN_TIME)
    }

    fun findById(id: String) : LiveData<Session> {
        return where().equalTo(SessionFields.UUID, id).findFirstAsync().asLiveData()
    }

    private fun where() = db.where<Session>()

    private fun whereVisible() : RealmQuery<Session> {
        return where().equalTo(SessionFields.VISIBLE, true)
    }

}