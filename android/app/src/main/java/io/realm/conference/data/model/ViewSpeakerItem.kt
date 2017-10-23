package io.realm.conference.data.model

import io.realm.conference.data.entity.Speaker

/**
 * Delegate all calls to the backing session entity, except what is overridden here.
 */
class ViewSpeakerItem(val speaker: Speaker) : SpeakerItem by speaker