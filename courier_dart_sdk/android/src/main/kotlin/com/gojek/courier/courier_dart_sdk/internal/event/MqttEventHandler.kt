package com.gojek.courier.courier_dart_sdk.internal.event

import android.util.Log
import com.gojek.mqtt.event.EventHandler
import com.gojek.mqtt.event.MqttEvent

class MqttEventHandler(val eventConsumer: (Map<String, Any>) -> Unit) : EventHandler {
    override fun onEvent(mqttEvent: MqttEvent) {
        Log.d("Courier", "MqttEvent: $mqttEvent")
        val connectionInfo = getConnectionInfo(mqttEvent)
        when (mqttEvent) {
            is MqttEvent.MqttConnectAttemptEvent -> {
                handleEvent("Mqtt Connect Attempt", connectionInfo = connectionInfo)
            }
            is MqttEvent.MqttConnectSuccessEvent -> {
                handleEvent("Mqtt Connect Success", connectionInfo = connectionInfo)
            }
            is MqttEvent.MqttConnectFailureEvent -> {
                handleEvent("Mqtt Connect Failure", mapOf("reason" to mqttEvent.exception.reasonCode), connectionInfo)
            }
            is MqttEvent.MqttConnectionLostEvent -> {
                handleEvent("Mqtt Connection Lost", mapOf("reason" to mqttEvent.exception.reasonCode), connectionInfo)
            }
            is MqttEvent.MqttDisconnectEvent -> {
                handleEvent("Mqtt Disconnect", connectionInfo = connectionInfo)
            }
            is MqttEvent.MqttSubscribeAttemptEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Subscribe Attempt", mapOf("topic" to it.key), connectionInfo)
                }
            }
            is MqttEvent.MqttSubscribeSuccessEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Subscribe Success", mapOf("topic" to it.key), connectionInfo)
                }
            }
            is MqttEvent.MqttSubscribeFailureEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Subscribe Failure", mapOf("topic" to it.key, "reason" to mqttEvent.exception.reasonCode), connectionInfo)
                }
            }
            is MqttEvent.MqttUnsubscribeAttemptEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Unsubscribe Attempt", mapOf("topic" to it), connectionInfo)
                }
            }
            is MqttEvent.MqttUnsubscribeSuccessEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Unsubscribe Success", mapOf("topic" to it), connectionInfo)
                }
            }
            is MqttEvent.MqttUnsubscribeFailureEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Unsubscribe Failure", mapOf("topic" to it, "reason" to mqttEvent.exception.reasonCode), connectionInfo)
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
                handleEvent("Mqtt Ping Initiated", connectionInfo = connectionInfo)
            }
            is MqttEvent.MqttPingSuccessEvent -> {
                handleEvent("Mqtt Ping Success", connectionInfo = connectionInfo)
            }
            is MqttEvent.MqttPingFailureEvent -> {
                handleEvent("Mqtt Ping Failure", mapOf("reason" to mqttEvent.exception.reasonCode), connectionInfo)
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
                    "isCleanSession" to it.username,
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