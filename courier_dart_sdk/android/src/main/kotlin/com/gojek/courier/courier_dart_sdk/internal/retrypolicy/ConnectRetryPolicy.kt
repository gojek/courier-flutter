package com.gojek.courier.courier_dart_sdk.internal.retrypolicy

import com.gojek.mqtt.policies.connectretrytime.IConnectRetryTimePolicy
import java.util.Random
import kotlin.math.min

class ConnectRetryPolicy(
    private val baseTimeSecs: Int,
    private val maxTimeSecs: Int,
) : IConnectRetryTimePolicy {
    private var currentRetryTime: Int = baseTimeSecs
    private val random = Random()

    @Synchronized
    override fun getConnRetryTimeSecs(): Int {
        if (currentRetryTime >= maxTimeSecs) {
            return maxTimeSecs.withJitter()
        }
        currentRetryTime = min(maxTimeSecs, currentRetryTime * 2)
        return currentRetryTime.withJitter()
    }

    override fun getConnRetryTimeSecs(forceExp: Boolean) = 0

    override fun getCurrentRetryTime() = 0

    override fun getRetryCount() = 0

    @Synchronized
    override fun resetParams() {
        currentRetryTime = baseTimeSecs
    }

    private fun Int.withJitter(): Int = random.nextInt(this) + 1
}
