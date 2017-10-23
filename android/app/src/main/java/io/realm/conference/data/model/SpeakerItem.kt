package io.realm.conference.data.model

import android.text.Html

interface SpeakerItem {

    val uuid: String
    val name: String

    val visible: Boolean
    val bio: String?
    val url: String?
    val twitter: String?
    val photoUrl: String?

    fun firstInitial() : String {
        return name.first().toString()
    }

    fun twitterLink() = Html.fromHtml("<a href='http://twitter.com/${twitter?.replace("@","")}'>$twitter</a>")

    fun urlLink() = Html.fromHtml("<a href='$url'>$url</a>")

}