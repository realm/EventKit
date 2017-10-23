package io.realm.conference.ui.speaker

import android.app.Activity
import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.content.Context
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v7.widget.DividerItemDecoration
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import io.realm.conference.R
import io.realm.conference.data.model.SpeakerItem
import io.realm.conference.ui.common.GroupHeaderDecoration
import io.realm.conference.ui.common.ItemClickListener
import io.realm.conference.util.bindToRange
import io.realm.conference.viewmodel.speaker.SpeakerListViewModel
import org.jetbrains.anko.startActivity

class SpeakerListFragment : Fragment() {

    override fun onAttach(context: Context) {
        super.onAttach(context)

        if(context is Activity) {
            context.title = "Speakers"
        }
    }

    override fun onCreateView(inflater: LayoutInflater,
                              container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {

        super.onCreateView(inflater, container, savedInstanceState)

        val viewModel = ViewModelProviders.of(this).get(SpeakerListViewModel::class.java)

        val view = inflater.inflate(R.layout.list_content_common,
                                     container, false) as? RecyclerView

        // Set the adapter
        if (view != null) {
            view.setHasFixedSize(true)

            val adapter = SpeakerRecyclerViewAdapter(object : ItemClickListener<SpeakerItem> {
                override fun onItemClicked(item: SpeakerItem) {
                    context.startActivity<SpeakerDetailActivity>(SpeakerDetailActivity.ItemIdKey to item.uuid)
                }
            })
            view.adapter = adapter

            view.addItemDecoration(
                    DividerItemDecoration(context, DividerItemDecoration.VERTICAL))
            view.addItemDecoration(
                    GroupHeaderDecoration(sectionCallback = getSectionCallback(viewModel)))

            viewModel.speakers.observe(this, Observer {
                if(it != null) {
                    adapter.speakerItems = it
                }
            })
        }
        return view
    }

    private fun getSectionCallback(vm: SpeakerListViewModel) : GroupHeaderDecoration.SectionCallback {
        return object : GroupHeaderDecoration.SectionCallback {
            override fun isSection(position: Int): Boolean {
                return position <= 0 ||
                        vm.speakers.value?.get(position)?.firstInitial() !=
                                vm.speakers.value?.get(position - 1)?.firstInitial()
            }

            override fun getSectionHeader(position: Int): CharSequence {
                val speakers = vm.speakers.value ?: return ""
                val pos = position.bindToRange(lowerBound = 0, upperBound = speakers.size - 1)
                return speakers[pos].firstInitial()
            }
        }
    }


    companion object {
        fun newInstance() = SpeakerListFragment()
    }
}







