package io.realm.conference.viewmodel.splash

import android.arch.lifecycle.MutableLiveData
import android.arch.lifecycle.ViewModel
import android.util.Log
import io.realm.*
import io.realm.conference.BuildConfig
import io.realm.conference.data.entity.ServerModule
import io.realm.conference.data.extensions.eventDataDao
import io.realm.conference.data.extensions.sessionDao
import io.realm.conference.data.extensions.speakerDao
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread


class SplashViewModel : ViewModel() {

    enum class State { WAITING_USER, ATTEMPTING_LOGIN, AUTHENTICATED  }

    private var realm: Realm? = null
    private val serverUrl = { "http://${host}:${port}" }
    private val realmUrl = { "realm://${host}:${port}/${database}" }

    val host =  BuildConfig.ROS_HOST
    val port = "9080"
    val database =  BuildConfig.EVENT_DB_PATH
    val username = BuildConfig.EVENT_DB_RO_USER
    val password = BuildConfig.EVENT_DB_RO_PASSWORD

    var state = MutableLiveData<State>()
    var error = MutableLiveData<String>()

    fun login() {

        state.postValue(State.ATTEMPTING_LOGIN)

        val syncCredentials = SyncCredentials.usernamePassword(username, password, false)

        SyncUser.loginAsync(syncCredentials, serverUrl(), object : SyncUser.Callback<SyncUser> {

            override fun onSuccess(user: SyncUser) {
                postLogin(user)
            }

            override fun onError(e: ObjectServerError) {

                val handleNoConnectionError = {
                    if(SyncUser.currentUser() != null) {
                        postLogin(SyncUser.currentUser())
                    } else {
                        error.postValue("Error: Could not connect, check host...")
                    }
                }

                when(e.errorCode) {
                    ErrorCode.INVALID_CREDENTIALS -> error.postValue("Error: Invalid Credentials...")
                    else -> handleNoConnectionError()
                }
                state.postValue(State.WAITING_USER)

            }
        })
    }

    override fun onCleared() {
        realm?.close()
    }

    private fun postLogin(user: SyncUser) {
        setRealmDefaultConfig(user)
        postAuthenticatedOnceDataLoaded()
    }

    private val TAG = "SplashViewModel"

    private fun postAuthenticatedOnceDataLoaded() {

        doAsync {
            val realm = Realm.getDefaultInstance()

            while(realm.sessionDao().findAll().isEmpty()) {
                Thread.sleep(1000)
            }
            Log.i(TAG, "Schedules loaded...")

            while(realm.speakerDao().findAll().isEmpty()) {
                Thread.sleep(1000)
            }
            Log.i(TAG, "Speakers loaded...")

            while(realm.eventDataDao().findAll().isEmpty()) {
                Thread.sleep(1000)
            }
            Log.i(TAG, "EventData loaded...")

            realm.close()

            uiThread {
                state.postValue(State.AUTHENTICATED)
            }
        }

    }

    /**
     * Sets both the server realm config and the local user realm config.
     */
    private fun setRealmDefaultConfig(user: SyncUser) {
        Log.d("Tag", "Connecting to Sync Server at : ["  + realmUrl().replace("~", user.identity) + "]");
        Realm.removeDefaultConfiguration()
        Realm.setDefaultConfiguration(
                SyncConfiguration.Builder(user, realmUrl())
                        .readOnly()
                        .modules(ServerModule())
                        .waitForInitialRemoteData()
                        .build())
    }

}
