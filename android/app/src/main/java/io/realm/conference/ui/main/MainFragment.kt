package io.realm.conference.ui.main

import android.app.Activity
import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Context
import android.databinding.DataBindingUtil
import android.os.Bundle
import android.support.v4.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import io.realm.conference.R
import io.realm.conference.databinding.MainContentBinding
import io.realm.conference.viewmodel.main.MainViewModel

class MainFragment : Fragment() {

    override fun onCreateView(inflater: LayoutInflater?,
                              container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {

        super.onCreateView(inflater, container, savedInstanceState)

        val viewModel = ViewModelProviders.of(this).get(MainViewModel::class.java)

        val binding = DataBindingUtil.inflate<MainContentBinding>(
                inflater,
                R.layout.main_content,
                container,
                false)

        val eventData = viewModel.eventLiveData
        binding.item = eventData.value  // initial set

        eventData.observe(this, Observer{ updatedEventData ->
            binding.item = updatedEventData
        })

        return binding.root
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)

        if(context is Activity) {
            context.title = "Main"
        }
    }

    companion object {
        fun newInstance() = MainFragment()
    }

}