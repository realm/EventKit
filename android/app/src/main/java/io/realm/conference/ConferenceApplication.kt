package io.realm.conference

import android.app.Application
import io.realm.Realm

class ConferenceApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        Realm.init(this)
    }
}
