/obj/item/paper/manifest
	spawn_blacklisted = TRUE
	var/order_cost = 0
	var/order_id = 0
	var/errors = 0

/obj/item/paper/manifest/New(atom/A, id, cost)
	..()
	order_id = id
	order_cost = cost

	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_NAME
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_CONTENTS
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_ITEM

/obj/item/paper/manifest/proc/is_approved()
	return stamped && stamped.len && !is_denied()

/obj/item/paper/manifest/proc/is_denied()
	return stamped && (/obj/item/stamp/denied in stamped)

/datum/supply_order
	var/id
	var/orderer
	var/orderer_rank
	var/orderer_ckey
	var/reason
	var/datum/supply_pack/object

/datum/supply_order/New(datum/supply_pack/object, orderer, orderer_rank, orderer_ckey, reason)
	id = SSsupply.ordernum++
	src.object = object
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.orderer_ckey = orderer_ckey
	src.reason = reason

/datum/supply_order/proc/generateRequisition(turf/T)
	var/obj/item/paper/reqform = new(T)

	reqform.name = "requisition form - #[id] ([object.name])"
	reqform.info += "<h3>[station_name()] Supply Requisition Form</h3><hr>"
	reqform.info += "Order #[id]<br>"
	reqform.info += "Item: [object.name]<br>"
	reqform.info += "Access Restrictions: [get_access_desc(object.access)]<br>"
	reqform.info += "Requested by: [orderer]<br>"
	reqform.info += "Rank: [orderer_rank]<br>"
	reqform.info += "Contents:<br>"
	reqform.info += object.true_manifest
	if(reason)
		reqform.info += "Reason: [reason]<br>"
	reqform.info += "<hr>"
	reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

	reqform.update_icon()
	return reqform

/datum/supply_order/proc/generateManifest(obj/structure/closet/crate/C)
	var/obj/item/paper/manifest/P = new(C, id, object.cost)

	P.name = "shipping manifest - #[id] ([object.name])"
	P.info += "<h2>Shipping Manifest</h2>"
	P.info += "<hr/>"
	P.info += "Order #[id]<br/>"
	P.info += "Destination: [station_name()]<br/>"
	P.info += "Item: [object.name]<br/>"
	P.info += "Contents: <br/>"
	P.info += "<ul>"
	for(var/atom/movable/AM in C.contents - P)
		if((P.errors & MANIFEST_ERROR_CONTENTS))
			if(prob(50))
				P.info += "<li>[AM.name]</li>"
			else
				continue
		P.info += "<li>[AM.name]</li>"
	P.info += "</ul>"
	P.info += "<h4>Stamp below to confirm receipt of goods:</h4>"

	P.update_icon()
	P.loc = C
	//C.manifest = P
	//C.update_icon()

	return P

/datum/supply_order/proc/generate(turf/T)
	var/obj/structure/closet/crate/C = object.generate(T)
	var/obj/item/paper/manifest/M = generateManifest(C)

	if(M.errors & MANIFEST_ERROR_ITEM)
		if(istype(C, /obj/structure/closet/crate/secure) || istype(C, /obj/structure/closet/crate/large))
			M.errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lost = max(round(C.contents.len / 10), 1)
			while(--lost >= 0)
				qdel(pick(C.contents))
	return C
