MQTTPUB    ;; MQTT-publish $H
; No need for ping because sent once per second (timeout is 60 seconds)
; Globale Variable tcpdev !!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    d CONNECT^MQTT("127.0.0.1",1883)
    f i=1:1 u 0 w i,! d PUBLISH^MQTT("dollarh",i_" "_$h) h 1
