package com.gojek.courier.courier_dart_sdk.internal.extensions

import com.gojek.courier.QoS

fun Int.toQoS(): QoS {
    return when {
        this < 1 -> {
            QoS.ZERO
        }
        this == 1 -> {
            QoS.ONE
        }
        else -> {
            QoS.TWO
        }
    }
}