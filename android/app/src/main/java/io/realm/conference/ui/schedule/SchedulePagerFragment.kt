package io.realm.conference.ui.schedule

import android.app.Activity
import android.arch.lifecycle.ViewModelProviders
import android.content.Context
import android.os.Bundle
import android.support.design.widget.TabLayout
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentManager
import android.support.v4.app.FragmentStatePagerAdapter
import android.support.v4.view.ViewPager
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import io.realm.conference.R
import io.realm.conference.viewmodel.schedule.SessionsPagerViewModel


class SchedulePagerFragment : Fragment()  {

    lateinit var pagerViewModel: SessionsPagerViewModel

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if(context is Activity) {
            context.title = "Schedule"
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {

        super.onCreateView(inflater, container, savedInstanceState)

        pagerViewModel = ViewModelProviders.of(this).get(SessionsPagerViewModel::class.java)

        val view = inflater.inflate(R.layout.main_view_pager, container, false)
        val pager = view.findViewById<ViewPager>(R.id.pager)
        pager.adapter = MyAdapter(fragmentManager)

        val tabLayout = view.findViewById<TabLayout>(R.id.tabs)
        tabLayout.setupWithViewPager(pager, true)

        return view
    }

    inner class MyAdapter(fm: FragmentManager) : FragmentStatePagerAdapter(fm) {

        override fun getCount(): Int {
            return pagerViewModel.getDayCount()
        }

        override fun getItem(position: Int): Fragment {
            return ScheduleDayListFragment.newInstance(
                    pagerViewModel.getDateFor(position)
            )
        }

        override fun getPageTitle(position: Int): String {
            return pagerViewModel.getTitleFor(position)
        }
    }

    companion object {
        fun newInstance(): SchedulePagerFragment {
            return SchedulePagerFragment()
        }
    }

}
