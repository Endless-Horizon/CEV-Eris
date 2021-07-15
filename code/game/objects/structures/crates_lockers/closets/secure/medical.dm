/obj/structure/closet/secure_closet/medicine
	name = "medicine closet"
	desc = "Filled with medical junk."
	icon_state = "med"
	req_access = list(access_medical_equip)

/obj/structure/closet/secure_closet/medicine/populate_contents()
	new /obj/item/storage/box/autoinjectors(src)
	new /obj/item/storage/box/syringes(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/bottle/inaprovaline(src)
	new /obj/item/reagent_containers/glass/bottle/inaprovaline(src)
	new /obj/item/reagent_containers/glass/bottle/antitoxin(src)
	new /obj/item/reagent_containers/glass/bottle/antitoxin(src)

/obj/structure/closet/secure_closet/anesthetics
	name = "anesthetics closet"
	desc = "Used to knock people out."
	icon_state = "med"
	req_access = list(access_moebius)

/obj/structure/closet/secure_closet/anesthetics/populate_contents()
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/tool/wrench(src)

/obj/structure/closet/secure_closet/personal/doctor
	name = "moebius doctor's locker"
	req_access = list(access_cmo)
	access_occupy = list(access_medical_equip)
	icon_state = "med"

/obj/structure/closet/secure_closet/personal/doctor/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medical(src)
	else
		new /obj/item/storage/backpack/satchel/medical(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/suit/storage/toggle/labcoat(src)
	new /obj/item/clothing/gloves/latex/nitrile(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/device/radio/headset/headset_med(src)
	new /obj/item/taperoll/medical(src)
	new /obj/item/clothing/shoes/reinforced/medical(src)
	new /obj/item/clothing/head/soft/medical(src)
	new /obj/item/storage/belt/medical/emt(src)
	new /obj/item/storage/belt/medical/emt(src)
	new /obj/item/storage/belt/medical/(src)
	new /obj/item/storage/belt/medical/(src)
	new /obj/item/clothing/suit/storage/surgical_apron(src)

/obj/structure/closet/secure_closet/personal/paramedic
	name = "moebius paramedic's locker"
	req_access = list(access_cmo)
	access_occupy = list(access_paramedic)
	icon_state = "med"

/obj/structure/closet/secure_closet/personal/paramedic/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medical(src)
	else
		new /obj/item/storage/backpack/satchel/medical(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/under/rank/paramedic(src)
	new /obj/item/device/flash(src)
	new /obj/item/clothing/gloves/latex/nitrile(src)
	new /obj/item/device/lighting/toggleable/flashlight(src)
	new /obj/item/device/radio(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/clothing/shoes/reinforced/medical(src)
	new /obj/item/clothing/head/soft/medical(src)
	new /obj/item/extinguisher/mini(src)
	new /obj/item/clothing/shoes/reinforced(src)
	new /obj/item/device/radio/headset/headset_med(src)
	new /obj/item/taperoll/medical(src)
	new /obj/item/storage/belt/medical/emt(src)
	new /obj/item/clothing/suit/storage/hazardvest/black(src)
	new /obj/item/storage/pouch/medical_supply(src)

/obj/structure/closet/secure_closet/reinforced/CMO
	name = "moebius biolab officer's locker"
	req_access = list(access_cmo)
	icon_state = "cmo"

/obj/structure/closet/secure_closet/reinforced/CMO/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medical(src)
	else
		new /obj/item/storage/backpack/satchel(src)
	new /obj/item/clothing/suit/bio_suit(src)
	new /obj/item/clothing/head/bio_hood(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/clothing/shoes/reinforced/medical(src)
	new /obj/item/clothing/gloves/latex/nitrile(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/under/rank/moebius_biolab_officer(src)
	new /obj/item/clothing/suit/storage/toggle/labcoat/cmo(src)
	new /obj/item/clothing/gloves/latex(src)
	new /obj/item/clothing/shoes/color/brown	(src)
	new /obj/item/device/radio/headset/heads/cmo(src)
	new /obj/item/device/flash(src)
	new /obj/item/reagent_containers/hypospray(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/pouch/medical_supply(src)

/obj/structure/closet/secure_closet/animal
	name = "animal control closet"
	req_access = list(access_surgery)
	icon_state = "sec"

/obj/structure/closet/secure_closet/animal/populate_contents()
	new /obj/item/device/assembly/signaler(src)
	new /obj/item/device/radio/electropack(src)
	new /obj/item/device/radio/electropack(src)
	new /obj/item/device/radio/electropack(src)

/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "med"
	icon_door = "chemical"
	req_access = list(access_chemistry)

/obj/structure/closet/secure_closet/chemical/populate_contents()
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/pouch/tubular/vial(src)
