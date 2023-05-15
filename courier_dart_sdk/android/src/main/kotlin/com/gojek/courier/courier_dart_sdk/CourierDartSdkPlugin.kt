package com.gojek.courier.courier_dart_sdk

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.gojek.alarm.pingsender.AlarmPingSenderConfig
import com.gojek.alarm.pingsender.AlarmPingSenderFactory
import com.gojek.chuckmqtt.external.MqttChuckConfig
import com.gojek.chuckmqtt.external.MqttChuckInterceptor
import com.gojek.courier.Message
import com.gojek.courier.courier_dart_sdk.internal.MqttClientDelegate
import com.gojek.courier.courier_dart_sdk.internal.event.MqttEventHandler
import com.gojek.courier.courier_dart_sdk.internal.extensions.toQoS
import com.gojek.courier.courier_dart_sdk.internal.retrypolicy.ConnectRetryPolicy
import com.gojek.mqtt.auth.Authenticator
import com.gojek.mqtt.client.config.ExperimentConfigs
import com.gojek.mqtt.client.config.v3.MqttV3Configuration
import com.gojek.mqtt.client.listener.MessageListener
import com.gojek.mqtt.client.model.MqttMessage
import com.gojek.mqtt.exception.handler.v3.AuthFailureHandler
import com.gojek.mqtt.model.KeepAlive
import com.gojek.mqtt.model.MqttConnectOptions
import com.gojek.mqtt.model.ServerUri
import com.gojek.mqtt.policies.connecttimeout.ConnectTimeoutConfig
import com.gojek.mqtt.policies.connecttimeout.ConnectTimeoutPolicy
import com.gojek.timer.pingsender.TimerPingSenderFactory

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.TimeUnit

/** CourierDartSdkPlugin */
class CourierDartSdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var context: Context
  private lateinit var mqttConfiguration: MqttV3Configuration
  private lateinit var mqttClientDelegate: MqttClientDelegate
  private lateinit var methodChannel: MethodChannel
  private val handler = Handler(Looper.getMainLooper())
  private var readTimeoutSeconds: Int = 0
  private var disconnectDelaySeconds: Int = 0
  private val mainThreadHandler = Handler(Looper.getMainLooper())

  private val disconnectRunnable = Runnable {
    mqttClientDelegate.disconnect(false)
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "courier")
    methodChannel.setMethodCallHandler(this)

    this.context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "initialise") {
      initialise(call.arguments() as Map<String, Any>?)
      result.success("initialised")
    } else if (call.method == "connect") {
      connect(call.arguments() as Map<String, Any>?)
      result.success("connected")
    } else if (call.method == "disconnect") {
      disconnect(call.arguments() as Map<String, Any>?)
      result.success("disconnected")
    } else if (call.method == "subscribe") {
      subscribe(call.arguments() as Map<String, Any>?)
      result.success("subscribed")
    } else if (call.method == "unsubscribe") {
      unsubscribe(call.arguments() as Map<String, Any>?)
      result.success("unsubscribed")
    } else if (call.method == "send") {
      send(call.arguments() as Map<String, Any>?)
      result.success("sent")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
  }

  private fun initialise(arguments: Map<String, Any>?) {
    if (arguments.isNullOrEmpty()) {
      throw IllegalArgumentException("Arguments must be present while initialising the sdk")
    }
    val activityCheckIntervalSeconds = arguments["activityCheckIntervalSeconds"]!! as Int
    val inactivityTimeoutSeconds = arguments["inactivityTimeoutSeconds"]!! as Int
    val pingSender = if (arguments["timerPingSenderEnabled"]!! as Boolean) {
      TimerPingSenderFactory.create()
    } else {
      AlarmPingSenderFactory.createMqttPingSender(context, AlarmPingSenderConfig())
    }
    val connectRetryPolicyConfig = arguments["connectRetryPolicyConfig"]!! as Map<String, Any>
    val connectTimeoutPolicyConfig = arguments["connectTimeoutConfig"]!! as Map<String, Any>

    val enableMqttChuck = if (arguments["enableMQTTChuck"] is Boolean) {
        arguments["enableMQTTChuck"]!! as Boolean
    } else {
        false
    }

    readTimeoutSeconds = arguments["readTimeoutSeconds"]!! as Int
    disconnectDelaySeconds = arguments["disconnectDelaySeconds"]!! as Int

    mqttConfiguration = MqttV3Configuration(
        connectTimeoutPolicy = ConnectTimeoutPolicy(ConnectTimeoutConfig(
            sslUpperBoundConnTimeOut = connectTimeoutPolicyConfig["socketTimeout"] as Int,
            sslHandshakeTimeOut = connectTimeoutPolicyConfig["handshakeTimeout"] as Int,
        )),
        connectRetryTimePolicy = ConnectRetryPolicy(
            baseTimeSecs = connectRetryPolicyConfig["baseRetryTimeSeconds"] as Int,
            maxTimeSecs = connectRetryPolicyConfig["maxRetryTimeSeconds"] as Int,
        ),
        authenticator = object : Authenticator {
          override fun authenticate(connectOptions: MqttConnectOptions, forceRefresh: Boolean): MqttConnectOptions {
            return connectOptions
          }
        },
        experimentConfigs = ExperimentConfigs(
            activityCheckIntervalSeconds = activityCheckIntervalSeconds,
            inactivityTimeoutSeconds = inactivityTimeoutSeconds,
        ),
        pingSender = pingSender,
        mqttInterceptorList = if (enableMqttChuck) listOf(MqttChuckInterceptor(context, MqttChuckConfig())) else emptyList(),
        eventHandler = MqttEventHandler(::handleEvent),
        authFailureHandler = object : AuthFailureHandler {
          override fun handleAuthFailure() {
            handleAuthFailureInternal()
          }
        }
    )
    mqttClientDelegate = MqttClientDelegate(context, mqttConfiguration)
    mqttClientDelegate.receive(object : MessageListener {
      override fun onMessageReceived(mqttMessage: MqttMessage) {
        handleMqttMessageReceive(mqttMessage)
      }
    })
  }

  private fun connect(arguments: Map<String, Any>?) {
    if (arguments.isNullOrEmpty()) {
      throw IllegalArgumentException("Arguments must be present while connecting")
    }
    mainThreadHandler.removeCallbacks(disconnectRunnable)
    val mqttConnectOptions = MqttConnectOptions(
        clientId = arguments["clientId"]!! as String,
        username = arguments["username"]!! as String,
        password = arguments["password"]!! as String,
        serverUris = listOf(ServerUri(arguments["host"]!! as String, arguments["port"] as Int, "tcp")),
        keepAlive = KeepAlive(arguments["keepAliveSeconds"] as Int),
        isCleanSession = arguments["cleanSession"]!! as Boolean,
        readTimeoutSecs = readTimeoutSeconds
    )
    mqttClientDelegate.connect(mqttConnectOptions)
  }

  private fun disconnect(arguments: Map<String, Any>?) {
    if (arguments.isNullOrEmpty()) {
      throw IllegalArgumentException("Arguments must be present while disconnecting")
    }
    val clearState = arguments["clearState"]!! as Boolean
    if (disconnectDelaySeconds > 0 && clearState.not()) {
      mainThreadHandler.postDelayed(
        disconnectRunnable,
        TimeUnit.SECONDS.toMillis(disconnectDelaySeconds.toLong())
      )
    } else {
      mqttClientDelegate.disconnect(clearState)
    }
  }

  private fun subscribe(arguments: Map<String, Any>?) {
    if (arguments.isNullOrEmpty()) {
      throw IllegalArgumentException("Arguments must be present while subscribing")
    }
    val qos = arguments["qos"]!! as Int
    val topic = arguments["topic"]!! as String
    mqttClientDelegate.subscribe(topic, qos.toQoS())
  }

  private fun unsubscribe(arguments: Map<String, Any>?) {
    if (arguments.isNullOrEmpty()) {
      throw IllegalArgumentException("Arguments must be present while unsubscribing")
    }
    val topic = arguments["topic"]!! as String
    mqttClientDelegate.unsubscribe(topic)
  }

  private fun send(arguments: Map<String, Any>?) {
    if (arguments.isNullOrEmpty()) {
      throw IllegalArgumentException("Arguments must be present while sending a message")
    }
    val message = arguments["message"]!! as ByteArray
    val qos = arguments["qos"]!! as Int
    val topic = arguments["topic"]!! as String
    mqttClientDelegate.send(message, qos.toQoS(), topic)
  }

  private fun handleAuthFailureInternal() {
    handler.post {
      methodChannel.invokeMethod("onAuthFailure", null, object : MethodChannel.Result {
        override fun success(result: Any?) {
          Log.d("Courier", "onAuthFailure invocation success: $result")
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.d("Courier", "onAuthFailure invocation error: $errorMessage")
        }

        override fun notImplemented() {
          Log.d("Courier", "onAuthFailure invocation notImplemented")
        }

      })
    }
  }

  private fun handleMqttMessageReceive(mqttMessage: MqttMessage) {
    val arguments = mutableMapOf<String, Any>()
    arguments["message"] = (mqttMessage.message as Message.Bytes).value
    arguments["topic"] = mqttMessage.topic

    handler.post {
      methodChannel.invokeMethod("onMessageReceive", arguments, object : MethodChannel.Result {
        override fun success(result: Any?) {
          Log.d("Courier", "onMessageReceive invocation success: $result")
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
          Log.d("Courier", "onMessageReceive invocation error: $errorMessage")
        }

        override fun notImplemented() {
          Log.d("Courier", "onMessageReceive invocation notImplemented")
        }
      })
    }
  }

  private fun handleEvent(eventMap: Map<String, Any>) {
    if (eventMap.isNotEmpty()) {
      handler.post {
        methodChannel.invokeMethod("handleEvent", eventMap, object : MethodChannel.Result {
          override fun success(result: Any?) {
            Log.d("Courier", "handleEvent invocation success: $result")
          }

          override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            Log.d("Courier", "handleEvent invocation error: $errorMessage")
          }

          override fun notImplemented() {
            Log.d("Courier", "handleEvent invocation notImplemented")
          }
        })
      }
    }
  }
}
