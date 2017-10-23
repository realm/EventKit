package io.realm.conference.ui.common

import android.databinding.DataBindingUtil
import android.databinding.ViewDataBinding
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.ViewGroup
import io.realm.OrderedRealmCollection
import io.realm.RealmModel
import io.realm.RealmRecyclerViewAdapter
import io.realm.conference.BR

/**
 * [RecyclerView.Adapter] that can display a [DummyItem] and makes a call to the
 * specified [ListFragmentItemClickHandler].
 */
class ContentRecyclerViewAdapter<T : RealmModel>(
        private val contentPages: OrderedRealmCollection<T>,
        private val clickListener: ItemClickListener<T>,
        private val contentPageListItemResId: Int)
    : RealmRecyclerViewAdapter<T, ContentRecyclerViewAdapter<T>.ItemViewHolder>(contentPages, true, true) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)

        val itemBinding = DataBindingUtil.inflate<ViewDataBinding>(
                layoutInflater,
                contentPageListItemResId,
                parent,
                false)

        itemBinding.setVariable(BR.click_listener, clickListener)

        return ItemViewHolder(itemBinding)
    }

    override fun onBindViewHolder(itemViewHolder: ItemViewHolder, position: Int) {
        itemViewHolder.bind(contentPages[position])
    }

    inner class ItemViewHolder(private val itemBinding: ViewDataBinding) :
            RecyclerView.ViewHolder(itemBinding.root) {

        fun bind(viewModel: RealmModel) {
            itemBinding.setVariable(BR.item, viewModel)
            itemBinding.executePendingBindings()
        }
    }


}
