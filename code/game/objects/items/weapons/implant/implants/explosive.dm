/obj/item/implant/explosive
	name = "explosive implant"
	desc = "A military grade micro bio-explosive. Highly dangerous."
	var/elevel = "Localized Limb"
	var/phrase = "supercalifragilisticexpialidocious"
	icon_state = "implant_evil"
	implant_color = "r"
	is_legal = FALSE
	origin_tech = list(TECH_MATERIAL=2, TECH_COMBAT=3, TECH_BIO=4, TECH_COVERT=4)

/obj/item/implant/explosive/New()
	..()
	add_hearing()

/obj/item/implant/explosive/Destroy()
	remove_hearing()
	. = ..()

/obj/item/implant/explosive/get_data()
	var/data = {"
		<b>Implant Specifications:</b><BR>
		<b>Name:</b> Robust Corp RX-78 Intimidation Class Implant<BR>
		<b>Life:</b> Activates upon codephrase.<BR>
		<b>Important Notes:</b> Explodes<BR>
		<HR>
		<b>Implant Details:</b><BR>
		<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
		<b>Special Features:</b> Explodes<BR>
		<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
	return data

/obj/item/implant/explosive/hear_talk(mob/M, msg, verb, datum/language/speaking, speech_volume)
	hear(msg)

/obj/item/implant/explosive/hear(var/msg)
	var/list/replacechars = list("'" = "","\"" = "",">" = "","<" = "","(" = "",")" = "")
	msg = replace_characters(msg, replacechars)
	if(findtext(msg,phrase))
		activate()
		qdel(src)

/obj/item/implant/explosive/activate()
	if (malfunction == MALFUNCTION_PERMANENT)
		return

	var/need_gib = null
	if(istype(wearer, /mob/))
		var/mob/T = wearer
		message_admins("Explosive implant triggered in [T] ([T.key]). (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>) ")
		log_game("Explosive implant triggered in [T] ([T.key]).")
		need_gib = 1

		if(ishuman(wearer))
			if (elevel == "Localized Limb")
				if(part) //For some reason, small_boom() didn't work. So have this bit of working copypaste.
					wearer.visible_message("<span class='warning'>Something beeps inside [wearer][part ? "'s [part.name]" : ""]!</span>")
					playsound(loc, 'sound/items/countdown.ogg', 75, 1, -3)
					sleep(25)
					if (part.organ_tag in list(BP_CHEST, BP_HEAD, BP_GROIN))
						part.createwound(BRUISE, 60)	//mangle them instead
						explosion(get_turf(wearer), -1, -1, 2, 3)
						qdel(src)
					else
						explosion(get_turf(wearer), -1, -1, 2, 3)
						part.droplimb(0,DROPLIMB_BLUNT)
						qdel(src)
			if (elevel == "Destroy Body")
				explosion(get_turf(T), -1, 0, 1, 6)
				T.gib()
			if (elevel == "Full Explosion")
				explosion(get_turf(T), 0, 1, 3, 6)
				T.gib()

		else
			explosion(get_turf(wearer), 0, 1, 3, 6)

	if(need_gib)
		wearer.gib()

	var/turf/t = get_turf(wearer)

	if(t)
		t.hotspot_expose(3500,125)

/obj/item/implant/explosive/on_install(mob/living/source)
	elevel = alert("What sort of explosion would you prefer?", "Implant Intent", "Localized Limb", "Destroy Body", "Full Explosion")
	phrase = input("Choose activation phrase:") as text
	var/list/replacechars = list("'" = "","\"" = "",">" = "","<" = "","(" = "",")" = "")
	phrase = replace_characters(phrase, replacechars)
	usr.mind.store_memory("Explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.", 0, 0)
	to_chat(usr, "The implanted explosive implant in [source] can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.")

/obj/item/implant/explosive/proc/small_boom()
	if (ishuman(wearer) && part)
		wearer.visible_message("<span class='warning'>Something beeps inside [wearer][part ? "'s [part.name]" : ""]!</span>")
		playsound(loc, 'sound/items/countdown.ogg', 75, 1, -3)
		spawn(25)
			if (ishuman(wearer) && part)
				//No tearing off these parts since it's pretty much killing
				//and you can't replace groins
				if (part.organ_tag in list(BP_CHEST, BP_GROIN, BP_HEAD))
					part.createwound(BRUISE, 60)	//mangle them instead
				else
					part.droplimb(0,DROPLIMB_BLUNT)
			explosion(get_turf(wearer), -1, -1, 2, 3)
			qdel(src)

/obj/item/implant/explosive/malfunction(severity)
	if (malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY
	switch (severity)
		if (2)	//Weak EMP will make implant tear limbs off.
			if (prob(50))
				small_boom()
		if (1)	//strong EMP will melt implant either making it go off, or disarming it
			if (prob(70))
				if (prob(50))
					small_boom()
				else
					if (prob(50))
						activate()		//50% chance of bye bye
					else
						meltdown()		//50% chance of implant disarming
	spawn (20)
		malfunction = MALFUNCTION_NONE


/obj/item/implantcase/explosive
	name = "glass case - 'explosive'"
	desc = "A case containing an explosive implant."
	implant = new /obj/item/implant/explosive


/obj/item/implanter/explosive
	name = "implanter (E)"
	implant = /obj/item/implant/explosive
	spawn_tags = null
