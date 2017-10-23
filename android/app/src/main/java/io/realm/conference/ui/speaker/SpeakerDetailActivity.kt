package io.realm.conference.ui.speaker

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.databinding.DataBindingUtil
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import io.realm.conference.R
import io.realm.conference.data.model.SpeakerItem
import io.realm.conference.databinding.ActivitySpeakerDetailBinding
import io.realm.conference.ui.common.ItemClickListener
import io.realm.conference.viewmodel.speaker.SpeakerDetailViewModel
import kotlinx.android.synthetic.main.activity_speaker_detail.*


class SpeakerDetailActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val factory = SpeakerDetailViewModel.Factory(intent.getStringExtra(ItemIdKey))
        val viewModel = ViewModelProviders.of(this, factory).get(SpeakerDetailViewModel::class.java)

        val speaker = viewModel.speaker

        val binding: ActivitySpeakerDetailBinding = DataBindingUtil.setContentView(this, R.layout.activity_speaker_detail)

        setSupportActionBar(detail_toolbar)
        title = speaker.value?.name ?: ""

        speaker.observe(this, Observer {
            if(it != null) {
                binding.speaker = it
                title = it.name
            }
        })

    }

    companion object {
        const val ItemIdKey = "ItemId"
    }

}
