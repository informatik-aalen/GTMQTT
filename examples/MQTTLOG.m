MQTTLOG    ;; MQTT-Logger
; Globale Variable tcpdev !!!!
; Subscribes to # and logs all messages in ^MQTT
;
;;;;;;;;;;;;;;;;;;;;;;;;;;

    d CONNECT^MQTT("127.0.0.1",1883),SUBSCRIBE^MQTT("#")
    f  d
    . s rc=$$READMSG^MQTT(.m)
    . i rc=3 d  q
    . . w m("topic")_" "_m("message"),!
    . . s ^MQTT=$G(^MQTT)+1,^MQTT(^MQTT,"t")=m("topic"),^("m")=m("message"),^("h")=$H
    . i rc=-1 u 0 w "TO ",$H,! d PING^MQTT q
    d DISCONNECT^MQTT
    w "Goodbye",!
    q
