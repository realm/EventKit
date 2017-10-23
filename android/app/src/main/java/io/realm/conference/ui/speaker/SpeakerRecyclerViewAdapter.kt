package io.realm.conference.ui.speaker

import android.databinding.DataBindingUtil
import android.support.v7.util.DiffUtil
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.ViewGroup
import io.realm.conference.R
import io.realm.conference.data.model.SpeakerItem
import io.realm.conference.databinding.SpeakerItemBinding
import io.realm.conference.ui.common.ItemClickListener

class SpeakerRecyclerViewAdapter(val clickListener: ItemClickListener<SpeakerItem>) :
RecyclerView.Adapter<SpeakerRecyclerViewAdapter.SpeakerViewHolder>() {

    var speakerItems : List<SpeakerItem> = arrayListOf()
        set(newList) {
            if (speakerItems.isEmpty()) {
                field = newList
                notifyItemRangeInserted(0, newList.count())

            } else {

                val diff = DiffUtil.calculateDiff(object: DiffUtil.Callback() {

                    override fun getOldListSize() = field.count()
                    override fun getNewListSize() = newList.count()

                    override fun areItemsTheSame(oldItemPosition: Int, newItemPosition: Int) : Boolean {
                        return field[oldItemPosition].uuid == newList[newItemPosition].uuid
                    }

                    override fun areContentsTheSame(oldItemPosition: Int, newItemPosition: Int) : Boolean {
                        val newItem = newList[newItemPosition]
                        val oldItem = field[oldItemPosition]
                        return newItem.uuid == oldItem.uuid
                                && newItem.name == oldItem.name
                                && newItem.visible == oldItem.visible
                                && newItem.twitter == oldItem.twitter
                                && newItem.photoUrl == oldItem.photoUrl
                    }

                })
                field = newList
                diff.dispatchUpdatesTo(this)
            }
        }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) : SpeakerViewHolder {
        val binding: SpeakerItemBinding = DataBindingUtil
                .inflate(LayoutInflater.from(parent.getContext()), R.layout.speaker_item,
                        parent, false)
        binding.clickListener = clickListener
        return SpeakerViewHolder(binding)
    }

    override fun onBindViewHolder(holder: SpeakerViewHolder, position: Int) {
        holder.onBind(speakerItems[position])
    }

    override fun getItemCount() : Int {
        return speakerItems.size
    }

    inner class SpeakerViewHolder(val binding : SpeakerItemBinding) :
            RecyclerView.ViewHolder(binding.root) {
        fun onBind(speakerItem: SpeakerItem) {
            binding.item = speakerItem
            binding.executePendingBindings()
        }
    }
}
