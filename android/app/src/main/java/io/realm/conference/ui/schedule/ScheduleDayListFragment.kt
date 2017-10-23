package io.realm.conference.ui.schedule

import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v7.widget.DividerItemDecoration
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import io.realm.conference.R
import io.realm.conference.data.model.ScheduleItem
import io.realm.conference.ui.common.GroupHeaderDecoration
import io.realm.conference.ui.common.ItemClickListener
import io.realm.conference.viewmodel.schedule.SessionsListViewModel
import org.jetbrains.anko.startActivity


class ScheduleDayListFragment : Fragment()  {


    override fun onCreateView(inflater: LayoutInflater,
                              container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {

        super.onCreateView(inflater, container, savedInstanceState)

        val factory = SessionsListViewModel.Factory(arguments.getLong(ARG_SESSION_DATE))
        val viewModel = ViewModelProviders.of(this, factory).get(SessionsListViewModel::class.java)

        val view = inflater.inflate(R.layout.list_content_common,
                                     container, false) as? RecyclerView

        if(view != null) {
            view.setHasFixedSize(true)

            val adapter = ScheduleRecyclerViewAdapter(object : ItemClickListener<ScheduleItem> {
                override fun onItemClicked(item: ScheduleItem) {
                    context.startActivity<SessionDetailActivity>(SessionDetailActivity.ItemIdKey to item.uuid)
                }
            })

            view.adapter = adapter
            view.addItemDecoration(
                    DividerItemDecoration(context, DividerItemDecoration.VERTICAL))
            view.addItemDecoration(
                    GroupHeaderDecoration(sectionCallback = getSectionCallback(viewModel)))

            viewModel.sessionItems.observe(this, Observer {
                if(it != null) {
                    adapter.scheduleItems = it
                }
            })
        }

        return view
    }

    fun getSectionCallback(vm: SessionsListViewModel):GroupHeaderDecoration.SectionCallback {

        return object : GroupHeaderDecoration.SectionCallback {
            override fun isSection(position: Int): Boolean {
                return position <= 0 ||
                        vm.sessionItems.value?.get(position)?.startTimeInEventTimeZone !=
                            vm.sessionItems.value?.get(position - 1)?.startTimeInEventTimeZone
            }

            override fun getSectionHeader(position: Int): CharSequence {
                return vm.sessionItems.value?.get(position)?.startTimeInEventTimeZone ?: ""
            }
        }
    }


    companion object {

        private val ARG_SESSION_DATE = "conferenceDate"

        fun newInstance(date: Long): ScheduleDayListFragment {
            val fragment = ScheduleDayListFragment()
            val args = Bundle()
            args.putLong(ARG_SESSION_DATE, date)
            fragment.arguments = args
            return fragment
        }
    }

}