package io.realm.conference.ui.more

import android.app.Activity
import android.arch.lifecycle.ViewModelProviders
import android.content.Context
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v7.widget.DividerItemDecoration
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import io.realm.conference.R
import io.realm.conference.data.entity.ContentPage
import io.realm.conference.ui.common.ContentRecyclerViewAdapter
import io.realm.conference.ui.common.ItemClickListener
import io.realm.conference.viewmodel.more.MoreViewModel
import org.jetbrains.anko.startActivity

class MoreFragment : Fragment()  {

    private lateinit var viewModel: MoreViewModel

    override fun onCreateView(inflater: LayoutInflater?,
                              container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {

        super.onCreateView(inflater, container, savedInstanceState)

        viewModel = ViewModelProviders.of(this).get(MoreViewModel::class.java)

        val view = inflater?.inflate(R.layout.info_content, container, false)
        val recyclerView = view?.findViewById<RecyclerView>(R.id.cms_content_pages)

        if(recyclerView != null) {
            recyclerView.layoutManager = LinearLayoutManager(context)
            recyclerView.addItemDecoration(DividerItemDecoration(context, DividerItemDecoration.VERTICAL))

            val itemClickListener = object : ItemClickListener<ContentPage> {
                override fun onItemClicked(item: ContentPage) {
                    context.startActivity<ContentPageActivity>(ContentPageActivity.ItemIdKey to (item.title ?: ""))
                }
            }

            recyclerView.adapter = ContentRecyclerViewAdapter(
                    viewModel.contentPages(),
                    itemClickListener,
                    R.layout.content_info_item)
        }

        return view
    }

    override fun onAttach(context: Context?) {
        super.onAttach(context)

        if(context is Activity) {
            context.title = "More"
        }
    }

    companion object {

        fun newInstance(): MoreFragment {
            return MoreFragment()
        }
    }

}