package io.realm.conference.ui.more

import android.arch.lifecycle.ViewModelProviders
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.support.v7.widget.LinearLayoutManager
import io.realm.conference.R
import io.realm.conference.viewmodel.more.CmsContentViewModel
import kotlinx.android.synthetic.main.activity_content_page.*
import kotlinx.android.synthetic.main.content_page.*

class ContentPageActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_content_page)
        setSupportActionBar(toolbar)

        val vm = ViewModelProviders.of(this).get(CmsContentViewModel::class.java)

        val contentPageId = intent.getStringExtra(ItemIdKey)
        if(contentPageId != null) {
            vm.pageId = contentPageId
        }
        title = vm.pageTitle()
        val pageContentItems = vm.contentForPage()

        info_page_content.layoutManager = LinearLayoutManager(this)
        info_page_content.adapter = CmsRecyclerViewAdapter(pageContentItems)
    }

    companion object {
        const val ItemIdKey = "ItemId"
    }

}
