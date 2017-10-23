package io.realm.conference.ui.common

import android.os.Bundle
import android.support.design.widget.NavigationView
import android.support.v4.app.Fragment
import android.support.v4.view.GravityCompat
import android.support.v7.app.ActionBarDrawerToggle
import android.support.v7.app.AppCompatActivity
import android.view.MenuItem
import io.realm.conference.R
import io.realm.conference.ui.main.MainFragment
import io.realm.conference.ui.more.MoreFragment
import io.realm.conference.ui.schedule.SchedulePagerFragment
import io.realm.conference.ui.speaker.SpeakerListFragment
import kotlinx.android.synthetic.main.activity_main.*

class ConferenceActivity : AppCompatActivity(),
        NavigationView.OnNavigationItemSelectedListener {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        setSupportActionBar(toolbar)
        val toggle = ActionBarDrawerToggle(
                this, drawer_layout, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close)
        drawer_layout.addDrawerListener(toggle)
        toggle.syncState()

        nav_view.setNavigationItemSelectedListener(this)

        if(savedInstanceState == null) {
            show(MainFragment.newInstance())
        }
    }

    override fun onBackPressed() {
        if (drawer_layout.isDrawerOpen(GravityCompat.START)) {
            drawer_layout.closeDrawer(GravityCompat.START)
        } else {
            super.onBackPressed()
        }
    }

    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            R.id.nav_main -> show(MainFragment.newInstance())
            R.id.nav_schedule -> show(SchedulePagerFragment.newInstance())
            R.id.nav_speakers -> show(SpeakerListFragment.newInstance())
            R.id.nav_info -> show(MoreFragment.newInstance())
        }
        return true
    }

    private fun show(fragment: Fragment) {

        val fragmentManager = supportFragmentManager

        fragmentManager
                .beginTransaction()
                .replace(R.id.content_frame, fragment)
                .commit()

        drawer_layout.closeDrawer(GravityCompat.START)
    }
}






