package io.realm.conference.data.dao

import io.realm.Case
import io.realm.Realm
import io.realm.RealmResults
import io.realm.conference.data.entity.ContentElement
import io.realm.conference.data.entity.ContentElementFields
import io.realm.conference.data.entity.ContentPage
import io.realm.conference.data.entity.ContentPageFields
import io.realm.conference.data.extensions.where

class ContentPageDao(val db: Realm) {

    fun findInfoPagesAsync() : RealmResults<ContentPage> {

        return db.where<ContentPage>()
                .equalTo(ContentPageFields.TAG, "more", Case.INSENSITIVE)
                .isNotEmpty(ContentPageFields.ELEMENTS.`$`)
                .findAllAsync()
    }

    fun findById(id: String) : ContentPage? {
        return db.where<ContentPage>().equalTo(ContentPageFields.TITLE, id).findFirst()
    }

    fun findAllContentForPageByPageId(pageId: String) : RealmResults<ContentElement> {

        val contentPage = db.where<ContentPage>().equalTo(ContentPageFields.TITLE, pageId).findFirst()
        return contentPage?.elements!!.where()
                .`in`(ContentElementFields.TYPE, arrayOf("h1","h2","h3","h4","p","img"))
                .findAll()

    }

}