package io.realm.conference.ui.schedule

import android.databinding.DataBindingUtil
import android.support.v7.util.DiffUtil
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.ViewGroup
import io.realm.conference.R
import io.realm.conference.data.model.ScheduleItem
import io.realm.conference.databinding.ScheduleItemBinding
import io.realm.conference.ui.common.ItemClickListener

class ScheduleRecyclerViewAdapter(val clickListener: ItemClickListener<ScheduleItem>) :
        RecyclerView.Adapter<ScheduleRecyclerViewAdapter.ScheduleViewHolder>() {

    var scheduleItems : List<ScheduleItem> = arrayListOf()
        set(newList) {
            if (scheduleItems.isEmpty()) {
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
                                && newItem.title == oldItem.title
                                && newItem.visible == oldItem.visible
                                && newItem.beginTime == oldItem.beginTime
                                && newItem.sessionDescription == oldItem.sessionDescription
                    }

                })
                field = newList
                diff.dispatchUpdatesTo(this)
            }
        }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) : ScheduleViewHolder {
        val binding: ScheduleItemBinding = DataBindingUtil
                .inflate(LayoutInflater.from(parent.getContext()), R.layout.schedule_item,
                parent, false)
        binding.clickListener = clickListener
        return ScheduleViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ScheduleViewHolder, position: Int) {
        holder.onBind(scheduleItems[position])
    }

    override fun getItemCount() : Int {
        return scheduleItems.size
    }

    inner class ScheduleViewHolder(val binding : ScheduleItemBinding) :
                RecyclerView.ViewHolder(binding.root) {
        fun onBind(scheduleItem: ScheduleItem) {
            binding.item = scheduleItem
            binding.executePendingBindings()
        }
    }
}
