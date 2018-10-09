MQTT    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MQTT-Library for GT.M
;; Developed by Winfried Bantel, Stuttgart, Germany
;; Publishd under MIT-License
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    q
    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; All procedures read / write global variable tcpdev
;; not a persistent variable ^tcpdev !!!!
;; ToDo:
;;  - Length of message > 127
;;  - QOS 1, 2
;;  - Last Will
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUBSCRIBE(topic)
    u tcpdev w $$mkmsg(8,2,$C(0,10),$$utf8encode(topic)_$C(0))
    u 0 q

PUBLISH(topic,message)
    u tcpdev w $$mkmsg(3,0,$$utf8encode(topic),message)
    u 0 q

DISCONNECT  ;
    u tcpdev w $$mkmsg(14,0,"","")
    u 0 q

CONNECT(host,port,user,pass)
    n (host,port,user,pass,tcpdev)
    Set tcpdev="client$"_$j,timeout=1
    o tcpdev:(connect=host_":"_port_":TCP":attach="client"):timeout:"SOCKET"
    s timeout=60
    s flag=2+$S($G(user)'="":128,1:0)+$S($G(pass)'="":64,1:0)
    s vh=$$utf8encode("MQTT")_$C(4)_$C(flag)_$C(timeout\256)_$C(timeout#256)
    s pl=$$utf8encode("gt.m_"_$J_"_"_$H)
    i $G(user)'="" s pl=pl_$$utf8encode(user)
    i $G(pass)'="" s pl=pl_$$utf8encode(pass)
    Use tcpdev w $$mkmsg(1,0,vh,pl)
    u 0 q

PING    ;
    u tcpdev w $$mkmsg(12,0,"","")
    u 0 q

READMSG(m)
    n (tcpdev,m) k m
    ; u 0 w "Read... "
    u tcpdev r byte1#1:10 s msg=$A(byte1)\16 i $A(byte1)<0 u 0 q -1
    r length#1:1 s length=$A(length) i length<0 q -1
    i length>0 u tcpdev r in#length:2
    ; u 0 w msg,!
    i msg=3 d  q 3
    . s topiclength=$A(in)*256+$A(in,2),m("topic")=$$utf8decode(in)
    . s m("message")=$E(in,topiclength+3,length)
    q 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Interne Unterprogramme - klein geschrieben
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mkmsg(nr,hf,vh,pl) ; Msg-Nr, head-Flag, variable header and payload
    n (nr,hf,vh,pl)
    s m=vh_pl
    q $C(nr*16+hf)_$C($L(m))_m

utf8encode(txt)
    q $C($L(txt)\256)_$C($L(txt)#256)_txt

utf8decode(txt)
    q $E(txt,3,$A(txt)*256+$A(txt,2)+2)

debug(txt)
    n (txt)
    u 0
    w "----",!
    for i=1:1:$L(txt) w i," ",$S($A(txt,i)>=32:$E(txt,i),1:" ")," ",$A(txt,i),!
    w "----",!
    q

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Hier: Einsprung für Call-in in C
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



LOG(topic,message,resp) ;;
    s ^MQTT=$G(^MQTT)+1,^MQTT(^MQTT,"t")=topic,^("m")=message,^("h")=$h
    ;s t=message f i=1:1:$L(t) w i," ",$E(t,i)," ",$A(t,i),!
    ;
    s m("Geht/das")="Ja!"
    s m("Geht/das/nicht")="Nein!"
    s m("topic")=topic
    s m("message")=message
    s m("time")=$h
    s m("mqtt")=^MQTT
    s resp=$$convert(.m)
    q 0
    ;
convert(m)
    n (m)
    s (ind,resp)="" f  s ind=$O(m(ind)) q:ind=""  d
    . s resp=resp_$C($L(ind))_ind_$C(0)
    . s resp=resp_$C($L(m(ind)))_m(ind)_$C(0)
    q resp
