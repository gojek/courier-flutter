This is a forked version of MQTT Client Framework located from https:  

Reason behind the fork:
1. Current issue when the broker returns ConnackError with status 5 (Auth/Password Invalid), the session will close the socket transport before notifying the delegate passing the status. As we require this status to get the latest password token from our Connection Service API and reconnect to broker, we need to handle this by forking the MQTTClient library.
