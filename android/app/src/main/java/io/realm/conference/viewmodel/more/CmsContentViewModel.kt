package io.realm.conference.viewmodel.more

import android.arch.lifecycle.ViewModel
import io.realm.Realm
import io.realm.RealmResults
import io.realm.conference.data.entity.ContentElement
import io.realm.conference.data.extensions.contentPageDao

class CmsContentViewModel : ViewModel() {
    private val db = Realm.getDefaultInstance()
    private val contentPageDao = db.contentPageDao()

    lateinit var pageId: String

    fun pageTitle() : String {
        return contentPageDao.findById(pageId)?.title ?: ""
    }

    fun contentForPage() : RealmResults<ContentElement> {
        return contentPageDao.findAllContentForPageByPageId(pageId)
    }

    override fun onCleared() {
        db.close()
    }

}