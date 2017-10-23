package io.realm.conference.data.entity

import io.realm.annotations.RealmModule

@RealmModule(classes = arrayOf(
        ContentPage::class, ContentElement::class,  // CMS
        Location::class, EventData::class, Speaker::class, Session::class, Track::class // Conference
)) class ServerModule