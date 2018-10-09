MQTTUPPERCASE    ;; MQTT-Uppercase
; Globale Variable tcpdev !!!!
; Ping is need not to get a timeout-disconnect
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    d CONNECT^MQTT("127.0.0.1",1883),SUBSCRIBE^MQTT("lowercase")
    f  d
    . s rc=$$READMSG^MQTT(.m) w rc,!
    . i rc=3 d  q
    . . w m("topic")_" '"_m("message")_"'"
    . . f i=1:1:$L(m("message")) i $E(m("message"),i)?1L s $E(m("message"),i)=$C($A(m("message"),i)-32)
    . . w " ==> '"_m("message")_"'",!
    . . d PUBLISH^MQTT("uppercase",m("message"))
    . i rc=-1 d PING^MQTT q
    d DISCONNECT^MQTT
    w "Goodbye",!
    q
