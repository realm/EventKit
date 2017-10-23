@file:JvmName("RealmUtils")
@file:Suppress("unused")

package io.realm.conference.data.extensions

import io.realm.Realm
import io.realm.RealmModel
import io.realm.RealmQuery
import io.realm.conference.data.dao.ContentPageDao
import io.realm.conference.data.dao.EventDataDao
import io.realm.conference.data.dao.SessionDao
import io.realm.conference.data.dao.SpeakerDao
import java.util.concurrent.atomic.AtomicReference

fun <T> Realm.callInTransaction(action: Realm.() -> T): T {
    val ref = AtomicReference<T>()
    executeTransaction {
        ref.set(action(it))
    }
    return ref.get()
}

inline fun <reified T : RealmModel> Realm.createObject(): T {
    return this.createObject(T::class.java)
}

inline fun <reified T : RealmModel> Realm.createObject(primaryKeyValue: Any?): T {
    return this.createObject(T::class.java, primaryKeyValue)
}

inline fun <reified T : RealmModel> Realm.delete(): Unit {
    return this.delete(T::class.java)
}

inline fun <reified T : RealmModel> Realm.where(): RealmQuery<T> {
    return this.where(T::class.java)
}

fun Realm.eventDataDao() = EventDataDao(this)
fun Realm.sessionDao() = SessionDao(this)
fun Realm.speakerDao() = SpeakerDao(this)
fun Realm.contentPageDao() = ContentPageDao(this)


