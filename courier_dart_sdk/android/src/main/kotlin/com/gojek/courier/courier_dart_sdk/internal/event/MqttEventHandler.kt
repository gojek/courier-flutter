package com.gojek.courier.courier_dart_sdk.internal.event

import android.util.Log
import com.gojek.mqtt.event.EventHandler
import com.gojek.mqtt.event.MqttEvent
import com.gojek.mqtt.network.ActiveNetInfo

class MqttEventHandler(val eventConsumer: (Map<String, Any>) -> Unit) : EventHandler {
    override fun onEvent(mqttEvent: MqttEvent) {
        Log.d("Courier", "MqttEvent: $mqttEvent")
        val connectionInfo = getConnectionInfo(mqttEvent)
        when (mqttEvent) {
            is MqttEvent.MqttConnectAttemptEvent -> {
                handleEvent("Mqtt Connect Attempt", mapOf("optimalKeepAlive" to mqttEvent.isOptimalKeepAlive), connectionInfo)
            }
            is MqttEvent.MqttConnectDiscardedEvent -> {
                handleEvent("Mqtt Connect Discarded", mapOf("reason" to mqttEvent.reason), connectionInfo)
            }
            is MqttEvent.MqttConnectSuccessEvent -> {
                handleEvent("Mqtt Connect Success", mapOf("timeTaken" to mqttEvent.timeTakenMillis), connectionInfo)
            }
            is MqttEvent.MqttConnectFailureEvent -> {
                handleEvent("Mqtt Connect Failure", mapOf("reason" to mqttEvent.exception.reasonCode, "timeTaken" to mqttEvent.timeTakenMillis), connectionInfo)
            }
            is MqttEvent.MqttConnectionLostEvent -> {
                handleEvent("Mqtt Connection Lost", mapOf("reason" to mqttEvent.exception.reasonCode, "timeTaken" to mqttEvent.sessionTimeMillis, "nextRetrySecs" to mqttEvent.nextRetryTimeSecs,), connectionInfo)
            }
            is MqttEvent.SocketConnectAttemptEvent -> {
                handleEvent("Socket Connect Attempt", mapOf("timeout" to mqttEvent.timeout), connectionInfo)
            }
            is MqttEvent.SocketConnectSuccessEvent -> {
                handleEvent("Socket Connect Success", mapOf("timeout" to mqttEvent.timeout, "timeTaken" to mqttEvent.timeTakenMillis), connectionInfo)
            }
            is MqttEvent.SocketConnectFailureEvent -> {
                handleEvent("Socket Connect Failure", mapOf("timeout" to mqttEvent.timeout, "timeTaken" to mqttEvent.timeTakenMillis, "reason" to mqttEvent.exception.reasonCode), connectionInfo)
            }
            is MqttEvent.SSLSocketAttemptEvent -> {
                handleEvent("SSL Socket Attempt", mapOf("timeout" to mqttEvent.timeout), connectionInfo)
            }
            is MqttEvent.SSLSocketSuccessEvent -> {
                handleEvent("SSL Socket Success", mapOf("timeout" to mqttEvent.timeout, "timeTaken" to mqttEvent.timeTakenMillis), connectionInfo)
            }
            is MqttEvent.SSLSocketFailureEvent -> {
                handleEvent("SSL Socket Failure", mapOf("timeout" to mqttEvent.timeout, "timeTaken" to mqttEvent.timeTakenMillis, "reason" to mqttEvent.exception.reasonCode), connectionInfo)
            }
            is MqttEvent.SSLHandshakeSuccessEvent -> {
                handleEvent("SSL Socket Handshake Success", mapOf("timeout" to mqttEvent.timeout, "timeTaken" to mqttEvent.timeTakenMillis), connectionInfo)
            }
            is MqttEvent.ConnectPacketSendEvent -> {
                handleEvent("Connect Packet Send", connectionInfo)
            }
            is MqttEvent.MqttSubscribeAttemptEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Subscribe Attempt", mapOf("topic" to it.key, "qos" to it.value.value), connectionInfo)
                }
            }
            is MqttEvent.MqttSubscribeSuccessEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Subscribe Success", mapOf("topic" to it.key, "qos" to it.value.value, "timeTaken" to mqttEvent.timeTakenMillis), connectionInfo)
                }
            }
            is MqttEvent.MqttSubscribeFailureEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Subscribe Failure", mapOf("topic" to it.key, "qos" to it.value.value, "timeTaken" to mqttEvent.timeTakenMillis, "reason" to mqttEvent.exception.reasonCode), connectionInfo)
                }
            }
            is MqttEvent.MqttUnsubscribeAttemptEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Unsubscribe Attempt", mapOf("topic" to it), connectionInfo)
                }
            }
            is MqttEvent.MqttUnsubscribeSuccessEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Unsubscribe Success", mapOf("topic" to it, "timeTaken" to mqttEvent.timeTakenMillis), connectionInfo)
                }
            }
            is MqttEvent.MqttUnsubscribeFailureEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Unsubscribe Failure", mapOf("topic" to it, "timeTaken" to mqttEvent.timeTakenMillis, "reason" to mqttEvent.exception.reasonCode), connectionInfo)
                }
            }
            is MqttEvent.MqttMessageReceiveEvent -> {
                handleEvent("Mqtt Message Receive", mapOf("topic" to mqttEvent.topic, "sizeBytes" to mqttEvent.sizeBytes), connectionInfo)
            }
            is MqttEvent.MqttMessageReceiveErrorEvent -> {
                handleEvent("Mqtt Message Receive Failure", mapOf(
                        "topic" to mqttEvent.topic,
                        "reason" to mqttEvent.exception.reasonCode,
                        "sizeBytes" to mqttEvent.sizeBytes), connectionInfo)
            }
            is MqttEvent.MqttMessageSendEvent -> {
                handleEvent("Mqtt Message Send Attempt", mapOf(
                        "topic" to mqttEvent.topic,
                        "qos" to mqttEvent.qos,
                        "sizeBytes" to mqttEvent.sizeBytes), connectionInfo)
            }
            is MqttEvent.MqttMessageSendSuccessEvent -> {
                handleEvent("Mqtt Message Send Success", mapOf(
                        "topic" to mqttEvent.topic,
                        "qos" to mqttEvent.qos,
                        "sizeBytes" to mqttEvent.sizeBytes), connectionInfo)
            }
            is MqttEvent.MqttMessageSendFailureEvent -> {
                handleEvent("Mqtt Message Send Failure", mapOf(
                        "topic" to mqttEvent.topic,
                        "reason" to mqttEvent.exception.reasonCode,
                        "qos" to mqttEvent.qos,
                        "sizeBytes" to mqttEvent.sizeBytes), connectionInfo)
            }
            is MqttEvent.MqttPingInitiatedEvent -> {
                handleEvent("Mqtt Ping Initiated",  connectionInfo)
            }
            is MqttEvent.MqttPingScheduledEvent -> {
                handleEvent("Mqtt Ping Scheduled", mapOf("nextPingTime" to mqttEvent.nextPingTimeSecs), connectionInfo)
            }
            is MqttEvent.MqttPingCancelledEvent -> {
                handleEvent("Mqtt Ping Cancelled", connectionInfo)
            }
            is MqttEvent.MqttPingSuccessEvent -> {
                handleEvent("Mqtt Ping Success", mapOf("timeTaken" to mqttEvent.timeTakenMillis), connectionInfo )
            }
            is MqttEvent.MqttPingFailureEvent -> {
                handleEvent("Mqtt Ping Failure", mapOf( "timeTaken" to mqttEvent.timeTakenMillis, "reason" to mqttEvent.exception.reasonCode), connectionInfo)
            }
            is MqttEvent.MqttPingExceptionEvent -> {
                handleEvent("Mqtt Ping Exception", mapOf("reason" to mqttEvent.exception.reasonCode), connectionInfo)
            }
            is MqttEvent.BackgroundAlarmPingLimitReached -> {
                handleEvent("Mqtt Background Alarm Ping Limit Reached", connectionInfo)
            }
            is MqttEvent.OptimalKeepAliveFoundEvent -> {
                handleEvent("Mqtt Optimal Keep Alive Found", mapOf("timeMinutes" to mqttEvent.timeMinutes, "probeCount" to mqttEvent.probeCount, "covergenceTime" to mqttEvent.convergenceTime), connectionInfo)
            }
            is MqttEvent.MqttReconnectEvent -> {
                handleEvent("Mqtt Reconnect", connectionInfo)
            }
            is MqttEvent.MqttDisconnectEvent -> {
                handleEvent("Mqtt Disconnect", connectionInfo)
            }
            is MqttEvent.MqttDisconnectStartEvent -> {
                handleEvent("Mqtt Disconnect Start", connectionInfo)
            }
            is MqttEvent.MqttDisconnectCompleteEvent -> {
                handleEvent("Mqtt Disconnect Complete", connectionInfo)
            }
            is MqttEvent.OfflineMessageDiscardedEvent -> {
                handleEvent("Mqtt Offline Message Discarded", connectionInfo)
            }
            is MqttEvent.OfflineMessageDiscardedEvent -> {
                handleEvent("Mqtt Offline Message Discarded", connectionInfo)
            }
            is MqttEvent.InboundInactivityEvent -> {
                handleEvent("Mqtt Inbound Inactivity", connectionInfo)
            }
            is MqttEvent.HandlerThreadNotAliveEvent -> {
                handleEvent("Handler Thread Not Alive", mapOf("isInterrupted" to mqttEvent.isInterrupted, "state" to mqttEvent.state.name),  connectionInfo)
            }
            else -> {
                // do nothing
            }
        }
    }

    private fun getConnectionInfo(event: MqttEvent): Map<String, Any> {
        return event.connectionInfo?.let {
            mapOf(
                    "host" to it.host,
                    "port" to it.port,
                    "keepAlive" to it.keepaliveSeconds,
                    "clientId" to it.clientId,
                    "username" to it.username,
                    "connectTimeout" to it.connectTimeout,
                    "scheme" to it.scheme
            )
        } ?: run { emptyMap() }
    }


    private fun handleEvent(name: String, properties: Map<String, Any> = emptyMap(), connectionInfo: Map<String, Any> = emptyMap()) {
        val map = mapOf("name" to name, "properties" to properties, "connectionInfo" to connectionInfo)
        eventConsumer(map)
    }
}