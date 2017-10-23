package io.realm.conference.ui.more

import android.os.Build
import android.support.v7.widget.RecyclerView
import android.text.Html
import android.text.Html.fromHtml
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.bumptech.glide.Glide
import io.realm.OrderedRealmCollection
import io.realm.RealmRecyclerViewAdapter
import io.realm.conference.R
import io.realm.conference.data.entity.ContentElement
import kotlinx.android.synthetic.main.cms_content_item.view.*
import org.jetbrains.anko.browse

class CmsRecyclerViewAdapter(mValues: OrderedRealmCollection<ContentElement>) :
            RealmRecyclerViewAdapter<ContentElement, CmsRecyclerViewAdapter.ViewHolder>
            (mValues, true, true) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {

        val layoutInflater = LayoutInflater.from(parent.context)

        val view = layoutInflater.inflate(R.layout.cms_content_item, parent, false)

        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = data?.get(position)
        if(item != null) {
            holder.bind(item)
        }
    }

    inner class ViewHolder(val view: View) :
            RecyclerView.ViewHolder(view) {

        private val contentText = view.content_element_text
        private val contentImage = view.content_element_image

        fun bind(contentElement: ContentElement) {
            clearClickListeners()
            when(contentElement.type) {
                "img" -> renderImg(contentElement)
                "h1","h2","h3","h4","p" ->  renderText(contentElement)
                else -> Log.w("CmsElement", "Bad content type ${contentElement.type}")
            }
        }

        private fun renderText(contentElement: ContentElement) {
            switchToTextView()
            val text = "<${contentElement.type}>${contentElement.content}</${contentElement.type}>"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                contentText.text = fromHtml(text, Html.FROM_HTML_MODE_COMPACT)
            } else {
                contentText.text = fromHtml(text)
            }
            addLinkIfApplicable(contentElement, contentText)

        }

        private fun renderImg(contentElement: ContentElement) {
            switchToImageView()
            Glide.with(view.context).load(contentElement.content).into(contentImage)
            addLinkIfApplicable(contentElement, contentImage)
        }

        private fun addLinkIfApplicable(contentElement: ContentElement, v: View) {
            val linkUrl = contentElement.url
            if(linkUrl != null) {
                v.setOnClickListener { v.context.browse(linkUrl, true) }
            }
        }

        private fun clearClickListeners() {
            contentImage.setOnClickListener(null)
            contentText.setOnClickListener(null)
        }

        private fun switchToTextView() {
            contentImage.visibility = View.GONE
            contentText.visibility = View.VISIBLE
        }

        private fun switchToImageView() {
            contentText.visibility = View.GONE
            contentImage.visibility = View.VISIBLE
        }
    }
}