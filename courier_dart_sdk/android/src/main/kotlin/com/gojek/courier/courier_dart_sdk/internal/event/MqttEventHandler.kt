package com.gojek.courier.courier_dart_sdk.internal.event

import android.util.Log
import com.gojek.mqtt.event.EventHandler
import com.gojek.mqtt.event.MqttEvent

class MqttEventHandler(val eventConsumer: (Map<String, Any>) -> Unit) : EventHandler {
    override fun onEvent(mqttEvent: MqttEvent) {
        Log.d("Courier", "MqttEvent: $mqttEvent")
        when (mqttEvent) {
            is MqttEvent.MqttConnectAttemptEvent -> {
                handleEvent("Mqtt Connect Attempt")
            }
            is MqttEvent.MqttConnectSuccessEvent -> {
                handleEvent("Mqtt Connect Success")
            }
            is MqttEvent.MqttConnectFailureEvent -> {
                handleEvent("Mqtt Connect Failure", mapOf("reason" to mqttEvent.exception.reasonCode))
            }
            is MqttEvent.MqttConnectionLostEvent -> {
                handleEvent("Mqtt Connection Lost", mapOf("reason" to mqttEvent.exception.reasonCode))
            }
            is MqttEvent.MqttDisconnectEvent -> {
                handleEvent("Mqtt Disconnect")
            }
            is MqttEvent.MqttSubscribeAttemptEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Subscribe Attempt", mapOf("topic" to it.key))
                }
            }
            is MqttEvent.MqttSubscribeSuccessEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Subscribe Success", mapOf("topic" to it.key))
                }
            }
            is MqttEvent.MqttSubscribeFailureEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Subscribe Failure", mapOf("topic" to it.key, "reason" to mqttEvent.exception.reasonCode))
                }
            }
            is MqttEvent.MqttUnsubscribeAttemptEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Unsubscribe Attempt", mapOf("topic" to it))
                }
            }
            is MqttEvent.MqttUnsubscribeSuccessEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Unsubscribe Success", mapOf("topic" to it))
                }
            }
            is MqttEvent.MqttUnsubscribeFailureEvent -> {
                mqttEvent.topics.forEach {
                    handleEvent("Mqtt Unsubscribe Failure", mapOf("topic" to it, "reason" to mqttEvent.exception.reasonCode))
                }
            }
            is MqttEvent.MqttMessageReceiveEvent -> {
                handleEvent("Mqtt Message Receive", mapOf("topic" to mqttEvent.topic))
            }
            is MqttEvent.MqttMessageReceiveErrorEvent -> {
                handleEvent("Mqtt Message Receive Failure", mapOf("topic" to mqttEvent.topic,
                    "reason" to mqttEvent.exception.reasonCode))
            }
            is MqttEvent.MqttMessageSendEvent -> {
                handleEvent("Mqtt Message Send Attempt", mapOf("topic" to mqttEvent.topic))
            }
            is MqttEvent.MqttMessageSendSuccessEvent -> {
                handleEvent("Mqtt Message Send Success", mapOf("topic" to mqttEvent.topic))
            }
            is MqttEvent.MqttMessageSendFailureEvent -> {
                handleEvent("Mqtt Message Send Failure", mapOf(
                    "topic" to mqttEvent.topic,
                    "reason" to mqttEvent.exception.reasonCode
                ))
            }
            is MqttEvent.MqttPingInitiatedEvent -> {
                handleEvent("Mqtt Ping Initiated")
            }
            is MqttEvent.MqttPingSuccessEvent -> {
                handleEvent("Mqtt Ping Success")
            }
            is MqttEvent.MqttPingFailureEvent -> {
                handleEvent("Mqtt Ping Failure", mapOf("reason" to mqttEvent.exception.reasonCode))
            }
            else -> {
                // do nothing
            }
        }
    }

    private fun handleEvent(name: String, properties: Map<String, Any> = emptyMap()) {
        val map = mapOf("name" to name, "properties" to properties)
        eventConsumer(map)
    }
}