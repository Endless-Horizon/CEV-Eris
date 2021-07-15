/obj/item/implant/carrion_spider/signal
	name = "electrocurrent spider"
	icon_state = "spiderling_identity"
	spider_price = 5
	var/datum/wires/connected

/obj/item/implant/carrion_spider/signal/activate()
	..()
	if(src.connected)
		connected.Pulse(src)
	else
		to_chat(owner_mob, SPAN_WARNING("[src] is not attached to a pulseable wire"))

		