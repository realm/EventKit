package io.realm.conference.ui.schedule

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.databinding.DataBindingUtil
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import io.realm.conference.R
import io.realm.conference.databinding.ActivitySessionDetailBinding
import io.realm.conference.viewmodel.schedule.SessionDetailViewModel
import kotlinx.android.synthetic.main.activity_session_detail.*


class SessionDetailActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setSupportActionBar(detail_toolbar)
        title = ""

        val factory = SessionDetailViewModel.Factory(intent.getStringExtra(ItemIdKey))
        val viewModel = ViewModelProviders.of(this, factory).get(SessionDetailViewModel::class.java)

        val session = viewModel.session
        val binding: ActivitySessionDetailBinding = DataBindingUtil.setContentView(this, R.layout.activity_session_detail)

        binding.session = session.value

        session.observe(this, Observer { sessionUpdates ->
            binding.session = sessionUpdates
        })
    }

    companion object {
        const val ItemIdKey = "ItemId"
    }

}