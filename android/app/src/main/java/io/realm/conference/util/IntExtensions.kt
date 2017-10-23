@file:JvmName("IntegerUtils")

package io.realm.conference.util

fun Int.bindToRange(lowerBound: Int, upperBound: Int) : Int {
    return when {
        this < lowerBound -> lowerBound
        this > upperBound -> upperBound
        else -> this
    }
}
