/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = TRUE
	opacity = 0
	density = FALSE
	layer = SIGN_LAYER
	w_class = ITEM_SIZE_NORMAL

/obj/structure/sign/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			qdel(src)
			return
		if(3)
			qdel(src)
			return
		else
	return

/obj/structure/sign/attackby(obj/item/tool as obj, mob/user as mob)	//deconstruction
	if(istype(tool, /obj/item/tool/screwdriver) && !istype(src, /obj/structure/sign/double))
		to_chat(user, "You unfasten the sign with your [tool].")
		var/obj/item/sign/S = new(src.loc)
		S.name = name
		S.desc = desc
		S.icon_state = icon_state
		//var/icon/I = icon('icons/obj/decals.dmi', icon_state)
		//S.icon = I.Scale(24, 24)
		S.sign_state = icon_state
		qdel(src)
	else ..()

/obj/item/sign
	name = "sign"
	desc = ""
	icon = 'icons/obj/decals.dmi'
	w_class = ITEM_SIZE_NORMAL		//big
	var/sign_state = ""

/obj/item/sign/attackby(obj/item/tool as obj, mob/user as mob)	//construction
	if(istype(tool, /obj/item/tool/screwdriver) && isturf(user.loc))
		var/direction = input("In which direction?", "Select direction.") in list("North", "East", "South", "West", "Cancel")
		if(direction == "Cancel") return
		var/obj/structure/sign/S = new(user.loc)
		switch(direction)
			if("North")
				S.pixel_y = 32
			if("East")
				S.pixel_x = 32
			if("South")
				S.pixel_y = -32
			if("West")
				S.pixel_x = -32
			else return
		S.name = name
		S.desc = desc
		S.icon_state = sign_state
		to_chat(user, "You fasten \the [S] with your [tool].")
		qdel(src)
	else ..()

/obj/structure/sign/double/map
	name = "station map"
	desc = "A framed picture of the station."

/obj/structure/sign/double/map/left
	icon_state = "map-left"

/obj/structure/sign/double/map/right
	icon_state = "map-right"

/obj/structure/sign/securearea
	name = "\improper SECURE AREA"
	desc = "A warning sign which reads 'SECURE AREA'."
	icon_state = "securearea"

/obj/structure/sign/biohazard
	name = "\improper BIOHAZARD"
	desc = "A warning sign which reads 'BIOHAZARD'."
	icon_state = "bio"

/obj/structure/sign/electricshock
	name = "\improper HIGH VOLTAGE"
	desc = "A warning sign which reads 'HIGH VOLTAGE'."
	icon_state = "shock"

/obj/structure/sign/examroom
	name = "\improper EXAM"
	desc = "A guidance sign which reads 'EXAM ROOM'."
	icon_state = "examroom"

/obj/structure/sign/vacuum
	name = "\improper HARD VACUUM AHEAD"
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'."
	icon_state = "space"

/obj/structure/sign/deathsposal
	name = "\improper DISPOSAL LEADS TO SPACE"
	desc = "A warning sign which reads 'DISPOSAL LEADS TO SPACE'."
	icon_state = "deathsposal"

/obj/structure/sign/pods
	name = "\improper ESCAPE PODS"
	desc = "A warning sign which reads 'ESCAPE PODS'."
	icon_state = "pods"

/obj/structure/sign/fire
	name = "\improper DANGER: FIRE"
	desc = "A warning sign which reads 'DANGER: FIRE'."
	icon_state = "fire"

/obj/structure/sign/nosmoking_1
	name = "\improper NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking"

/obj/structure/sign/nosmoking_2
	name = "\improper NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking2"

/obj/structure/sign/redcross
	name = "medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "redcross"

/obj/structure/sign/greencross
	name = "medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here."
	icon_state = "greencross"

/obj/structure/sign/goldenplaque
	name = "The Most Robust Men Award for Robustness"
	desc = "To be Robust is not an action or a way of life, but a mental state. Only those with the force of Will strong enough to act during a crisis, saving friend from foe, are truly Robust. Stay Robust my friends."
	icon_state = "goldenplaque"

/obj/structure/sign/kiddieplaque
	name = "\improper AI developers plaque"
	desc = "Next to the extremely long list of names and job titles, there is a drawing of a little child. The child appears to be retarded. Beneath the image, someone has scratched the word \"PACKETS\""
	icon_state = "kiddieplaque"

/obj/structure/sign/atmosplaque
	name = "\improper FEA atmospherics division plaque"
	desc = "This plaque commemorates the fall of the Atmos FEA division. For all the charred, dizzy, and brittle men who have died in its hands."
	icon_state = "atmosplaque"

/obj/structure/sign/double/maltesefalcon	//The sign is 64x32, so it needs two tiles. ;3
	name = "The Maltese Falcon"
	desc = "The Maltese Falcon, Space Bar and Grill."

/obj/structure/sign/double/maltesefalcon/left
	icon_state = "maltesefalcon-left"

/obj/structure/sign/double/maltesefalcon/right
	icon_state = "maltesefalcon-right"

/obj/structure/sign/science			//These 3 have multiple types, just var-edit the icon_state to whatever one you want on the map
	name = "\improper SCIENCE!"
	desc = "A warning sign which reads 'SCIENCE!'."
	icon_state = "science1"

/obj/structure/sign/chemistry
	name = "\improper CHEMISTRY"
	desc = "A warning sign which reads 'CHEMISTRY'."
	icon_state = "chemistry1"

/obj/structure/sign/botany
	name = "\improper HYDROPONICS"
	desc = "A warning sign which reads 'HYDROPONICS'."
	icon_state = "hydro1"

/obj/structure/sign/directions
	name = "direction sign"
	desc = "A direction sign, claiming to know the way."
	icon_state = "direction"

/obj/structure/sign/directions/science
	name = "\improper Science department"
	desc = "A direction sign, pointing out which way the Science department is."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	name = "\improper Engineering department"
	desc = "A direction sign, pointing out which way the Engineering department is."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	name = "\improper Security department"
	desc = "A direction sign, pointing out which way the Security department is."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	name = "\improper Medical Bay"
	desc = "A direction sign, pointing out which way the Medical Bay is."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	name = "\improper Escape Arm"
	desc = "A direction sign, pointing out which way the escape shuttle dock is."
	icon_state = "direction_evac"

//Eris signs

/obj/structure/sign/atmos_co2
	name = "CO2 warning sign"
	desc = "WARNING! CO2 flow tube. Ensure the flow is disengaged before working."
	icon_state = "atmos_co2"

/obj/structure/sign/atmos_n2o
	name = "N2O warning sign"
	desc = "WARNING! N2O flow tube. Ensure the flow is disengaged before working."
	icon_state = "atmos_n2o"

/obj/structure/sign/atmos_plasma
	name = "Plasma warning sign"
	desc = "WARNING! Plasma flow tube. Ensure the flow is disengaged before working."
	icon_state = "atmos_plasma"

/obj/structure/sign/atmos_n2
	name = "N2 warning sign"
	desc = "WARNING! N2 flow tube. Ensure the flow is disengaged before working."
	icon_state = "atmos_n2"

/obj/structure/sign/atmos_o2
	name = "O2 warning sign"
	desc = "WARNING! O2 flow tube. Ensure the flow is disengaged before working."
	icon_state = "atmos_o2"

/obj/structure/sign/atmos_air
	name = "Air warning sign"
	desc = "WARNING! Air flow tube. Ensure the flow is disengaged before working."
	icon_state = "atmos_air"

/obj/structure/sign/atmos_waste
	name = "Atmos waste warning sign"
	desc = "WARNING! Waste flow tube. Ensure the flow is disengaged before working."
	icon_state = "atmos_waste"

/obj/structure/sign/deck1
	desc = "A silver sign which reads 'DECK I'."
	name = "DECK I"
	icon_state = "deck1"

/obj/structure/sign/deck2
	desc = "A silver sign which reads 'DECK II'."
	name = "DECK II"
	icon_state = "deck2"

/obj/structure/sign/deck3
	desc = "A silver sign which reads 'DECK III'."
	name = "DECK III"
	icon_state = "deck3"

/obj/structure/sign/deck4
	desc = "A silver sign which reads 'DECK IV'."
	name = "DECK IV"
	icon_state = "deck4"

/obj/structure/sign/sec1
	desc = "A silver sign which reads 'SECTION I'."
	name = "SECTION I"
	icon_state = "sec1"

/obj/structure/sign/sec2
	desc = "A silver sign which reads 'SECTION II'."
	name = "SECTION II"
	icon_state = "sec2"

/obj/structure/sign/sec3
	desc = "A silver sign which reads 'SECTION III'."
	name = "SECTION III"
	icon_state = "sec3"

/obj/structure/sign/sec4
	desc = "A silver sign which reads 'SECTION IV'."
	name = "SECTION IV"
	icon_state = "sec4"

/obj/structure/sign/nanotrasen
	name = "\improper NanoTrasen"
	desc = "An old metal sign which reads 'NanoTrasen'."
	icon_state = "NT"

/obj/structure/sign/signnew/biohazard
	name = "BIOLOGICAL HAZARD"
	desc = "Warning: Biological and-or toxic hazards present in this area!"
	icon_state = "biohazard"

/obj/structure/sign/signnew/corrosives
	name = "CORROSIVE SUBSTANCES"
	desc = "Warning: Corrosive substances prezent in this area!"
	icon_state = "corrosives"

/obj/structure/sign/signnew/explosives
	name = "EXPLOSIVE SUBSTANCES"
	desc = "Warning: Explosive substances present in this area!"
	icon_state = "explosives"

/obj/structure/sign/signnew/flammables
	name = "FLAMMABLE SUBSTANCES"
	desc = "Warning: Flammable substances present in this area!"
	icon_state = "flammable"

/obj/structure/sign/signnew/laserhazard
	name = "LASER HAZARD"
	desc = "Warning: High powered laser emitters operating in this area!"
	icon_state = "laser"

/obj/structure/sign/signnew/danger
	name = "DANGEROUS AREA"
	desc = "Warning: Generally hazardous area! Exercise caution."
	icon_state = "danger"

/obj/structure/sign/signnew/magnetics
	name = "MAGNETIC FIELD HAZARD"
	desc = "Warning: Extremely powerful magnetic fields present in this area!"
	icon_state = "magnetics"

/obj/structure/sign/signnew/opticals
	name = "OPTICAL HAZARD"
	desc = "Warning: Optical hazards present in this area!"
	icon_state = "optical"

/obj/structure/sign/signnew/radiation
	name = "RADIATION HAZARD"
	desc = "Warning: Significant levels of radiation present in this area!"
	icon_state = "radiation"

/obj/structure/sign/signnew/secure
	name = "SECURE AREA"
	desc = "Warning: Secure Area! Do not enter without authorization!"
	icon_state = "secure"

/obj/structure/sign/signnew/electrical
	name = "ELECTRICAL HAZARD"
	desc = "Warning: Electrical hazards! Wear protective equipment."
	icon_state = "electrical"

/obj/structure/sign/signnew/cryogenics
	name = "CRYOGENIC TEMPERATURES"
	desc = "Warning: Extremely low temperatures in this area."
	icon_state = "cryogenics"

/obj/structure/sign/signnew/canisters
	name = "PRESSURIZED CANISTERS"
	desc = "Warning: Highly pressurized canister storage."
	icon_state = "canisters"

/obj/structure/sign/signnew/oxidants
	name = "OXIDIZING AGENTS"
	desc = "Warning: Oxidizing agents in this area, do not start fires!"
	icon_state = "oxidants"

/obj/structure/sign/signnew/memetic
	name = "MEMETIC HAZARD"
	desc = "Warning: Memetic hazard, wear meson goggles!"
	icon_state = "memetic"

//Eris departments

/obj/structure/sign/department
	name = "department sign"
	desc = "Sign of some important ship compartment."

/obj/structure/sign/department/medbay
	name = "MEDBAY"
	icon_state = "medbay"

/obj/structure/sign/department/virology
	name = "VIROLOGY"
	icon_state = "virology"

/obj/structure/sign/department/chem
	name = "CHEMISTRY"
	icon_state = "chem"

/obj/structure/sign/department/gene
	name = "GENETICS"
	icon_state = "gene"

/obj/structure/sign/department/morgue
	name = "MORGUE"
	icon_state = "morgue"

/obj/structure/sign/department/operational
	name = "OPERATIONAL"
	icon_state = "operational"

/obj/structure/sign/department/sci
	name = "SCIENCE"
	icon_state = "sci"

/obj/structure/sign/department/xenolab
	name = "XENOLAB"
	icon_state = "xenolab"

/obj/structure/sign/department/anomaly
	name = "ANOMALYLAB"
	icon_state = "anomaly"

/obj/structure/sign/department/dock
	name = "DOKUCHAYEV DOCK"
	icon_state = "dock"

/obj/structure/sign/department/rnd
	name = "RND"
	icon_state = "rnd"

/obj/structure/sign/department/robo
	name = "ROBOTICS"
	icon_state = "robo"

/obj/structure/sign/department/toxins
	name = "TOXINS"
	icon_state = "toxins"

/obj/structure/sign/department/toxin_res
	name = "TOXINLAB"
	icon_state = "toxin_res"

/obj/structure/sign/department/eva
	name = "E.V.A."
	icon_state = "eva"

/obj/structure/sign/department/ass
	name = "TOOL STORAGE"
	icon_state = "ass"

/obj/structure/sign/department/bar
	name = "BAR"
	icon_state = "bar"

/obj/structure/sign/department/biblio
	name = "LIBRARY"
	icon_state = "biblio"

/obj/structure/sign/department/chapel
	name = "CHAPEL"
	icon_state = "chapel"

/obj/structure/sign/department/bridge
	name = "BRIDGE"
	icon_state = "bridge"

/obj/structure/sign/department/telecoms
	name = "TELECOMS"
	icon_state = "telecoms"

/obj/structure/sign/department/conference_room
	name = "CONFERENCE"
	icon_state = "conference_room"

/obj/structure/sign/department/ai
	name = "AI"
	icon_state = "ai"

/obj/structure/sign/department/cargo
	name = "CARGO"
	icon_state = "cargo"

/obj/structure/sign/department/mail
	name = "MAIL"
	icon_state = "mail"

/obj/structure/sign/department/miner_dock
	name = "HULK DOCK"
	icon_state = "miner_dock"

/obj/structure/sign/department/cargo_dock
	name = "CARGO A5 DOCK"
	icon_state = "cargo_dock"

/obj/structure/sign/department/eng
	name = "ENGINEERING"
	icon_state = "eng"

/obj/structure/sign/department/engine
	name = "ENGINE"
	icon_state = "engine"

/obj/structure/sign/department/gravi
	name = "GRAVGEN"
	icon_state = "gravi"

/obj/structure/sign/department/atmos
	name = "ATMOSPHERICS"
	icon_state = "atmos"

/obj/structure/sign/department/shield
	name = "SHIELDGEN"
	icon_state = "shield"

/obj/structure/sign/department/drones
	name = "DRONES"
	icon_state = "drones"

/obj/structure/sign/department/scanner
	name = "LONG RANGE SCANNER"
	icon_state = "scanner"

/obj/structure/sign/department/interrogation
	name = "INTERROGATION"
	icon_state = "interrogation"

/obj/structure/sign/department/commander
	name = "IHS COMMANDER"
	icon_state = "commander"

/obj/structure/sign/department/armory
	name = "IHS ARMORY"
	icon_state = "armory"

/obj/structure/sign/department/prison
	name = "PRISON"
	icon_state = "prison"

//Eris factions

/obj/structure/sign/faction
	name = "faction sign"
	desc = "Faction sign of some sort."

/obj/structure/sign/faction/ironhammer
	name = "Ironhammer Security"
	desc = "This sign depicts the symbol of Ironhammer Security, the largest security provider within the Hansa Trade Union."
	icon_state = "ironhammer"

/obj/structure/sign/faction/one_star
	name = "One Star"
	desc = "One Star's all-seeing eye, a banner of a now fallen empire. They once controlled this sector from their capital Earth. Now it's all just dust, forgotten derelicts, and automated ships."
	icon_state = "one_star"

/obj/structure/sign/faction/one_star_old
	name = "One Star"
	desc = "One Star's all-seeing eye, a banner of a now fallen empire. They once controlled this sector from their capital Earth. Now it's all just dust, forgotten derelicts, and automated ships."
	icon_state = "one_star_old"

/obj/structure/sign/faction/frozenstar
	name = "Frozen Star"
	desc = "The most popular weapon manufacturer in the Hansa Trade Union."
	icon_state = "frozenstar"

/obj/structure/sign/faction/moebius
	name = "Moebius Laboratories"
	desc = "Shady pharmaceutical and prosthetic manufacturer. Few outsiders know what happens behind the doors of their labs, and whoever knows does not live a long life."
	icon_state = "moebius"

/obj/structure/sign/faction/neotheology
	name = "NeoTheology"
	desc = "the Tau Cross - symbol of NeoTheology."
	icon_state = "neotheology"

/obj/structure/sign/faction/neotheology_old
	name = "NeoTheology"
	desc = "the Tau Cross - symbol of NeoTheology."
	icon_state = "neotheology-old"

/obj/structure/sign/faction/neotheology_cross
	name = "NeoTheology Tau cross"
	desc = "Religious symbol of NeoTheology - the Tau cross. It looks like a decoration, not a real cruciform."
	icon_state = "wall_cross_steel"

/obj/structure/sign/faction/neotheology_cross/gold
	icon_state = "wall_cross_gold"

/obj/structure/sign/faction/astersguild
	name = "Asters Guild"
	desc = "Asters Guild - monopolists of far space transportation."
	icon_state = "astersguild"

/obj/structure/sign/faction/technomancers
	name = "Technomancer League"
	desc = "Technomancer League - anarchistic community ruled by powerful clans."
	icon_state = "technomancers"

/obj/structure/sign/faction/excelsior
	name = "EXCELSIOR"
	desc = "EXCELSIOR is a union of communist mining communities with no respect to any private property."
	icon_state = "excelsior"

/obj/structure/sign/faction/excelsior_old
	name = "EXCELSIOR"
	desc = "EXCELSIOR is a union of communist mining communities with no respect to any private property."
	icon_state = "excelsior-old"

/obj/structure/sign/derelict1
	name = "Old sign"
	desc = "Technical information of some sort, shame its too worn-out to read."
	icon_state = "something-old1"

/obj/structure/sign/derelict2
	name = "Old sign"
	desc = "Looks like a planet crashing by some station above it. Its kinda scary."
	icon_state = "something-old2"

/obj/structure/sign/derelict3
	name = "Old sign"
	desc = "A propaganda poster asking crew to look out for suspicious activity. You can't be too cautious nowadays as well."
	icon_state = "something-old3"
