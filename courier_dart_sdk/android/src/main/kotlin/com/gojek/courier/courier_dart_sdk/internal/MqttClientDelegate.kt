package com.gojek.courier.courier_dart_sdk.internal

import android.content.Context
import com.gojek.courier.Message
import com.gojek.courier.QoS
import com.gojek.mqtt.client.config.v3.MqttV3Configuration
import com.gojek.mqtt.client.factory.MqttClientFactory
import com.gojek.mqtt.client.listener.MessageListener
import com.gojek.mqtt.model.MqttConnectOptions

internal class MqttClientDelegate(
    context: Context,
    mqttConfiguration: MqttV3Configuration
) {
    private val mqttClient = MqttClientFactory.create(
        context, mqttConfiguration
    )

    fun connect(mqttConnectOptions: MqttConnectOptions) {
        mqttClient.connect(mqttConnectOptions)
    }

    fun disconnect(clearState: Boolean) {
        mqttClient.disconnect(clearState)
    }

    fun send(message: ByteArray, qos: QoS, topic: String) {
        mqttClient.send(Message.Bytes(message), topic, qos)
    }

    fun receive(listener: MessageListener) {
        mqttClient.addGlobalMessageListener(listener)
    }

    fun subscribe(topic: String, qos: QoS) {
        mqttClient.subscribe(topic to qos)
    }

    fun unsubscribe(topic: String) {
        mqttClient.unsubscribe(topic)
    }
}