@file:JvmName("DateUtils")

package io.realm.conference.util

import java.text.SimpleDateFormat
import java.util.*

/**
 * Functionally equivalent to floor, but semantically this version implies
 * that the date is having it's time truncated vs floor, implies that the
 * date is being floored to the beginning instant of the day.
 */
fun Date.truncateTime() = floor()

fun Date.floor() : Date {
    val cal = Calendar.getInstance()
    cal.time = this
    cal.set(Calendar.HOUR_OF_DAY, 0)
    cal.set(Calendar.MINUTE, 0)
    cal.set(Calendar.SECOND, 0)
    cal.set(Calendar.MILLISECOND, 0)
    return cal.time
}

/**
 * Go to the last second of the day.
 */
fun Date.ceil() : Date {
    val cal = Calendar.getInstance()
    cal.time = this.floor()
    cal.set(Calendar.DATE, cal.get(Calendar.DATE) + 1) // put to tomorrow
    cal.set(Calendar.SECOND, cal.get(Calendar.SECOND) - 1) // move one second before tomorrow.

    return cal.time
}

/**
 * Format a date with the given Pattern.
 */
fun Date.format(format: String) : String {
    return this.format(format, TimeZone.getDefault())
}

/**
 * Format a date with the given Pattern interpreted with the given timezone.
 */
fun Date.format(format: String, timeZone: TimeZone?) : String {
    val sdf = SimpleDateFormat(format, Locale.getDefault())
    if(timeZone != null) {
        sdf.timeZone = timeZone
    }
    return sdf.format(this)
}