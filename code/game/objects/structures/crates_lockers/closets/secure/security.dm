/obj/structure/closet/secure_closet/reinforced/captains
	name = "captain's locker"
	req_access = list(access_captain)
	icon_state = "cap"

/obj/structure/closet/secure_closet/reinforced/captains/populate_contents()
	new /obj/item/storage/backpack/captain(src)
	new /obj/item/storage/backpack/satchel/captain(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/suit/storage/captain(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/armor/helmet(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/device/radio/headset/heads/captain(src)
	new /obj/item/clothing/gloves/captain(src)
	new /obj/item/storage/belt/sheath(src)
	new /obj/item/tool/sword/saber(src)
	new /obj/item/gun/projectile/avasarala(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/melee/telebaton(src)
	new /obj/item/storage/pouch/pistol_holster(src)

/obj/structure/closet/secure_closet/reinforced/hop
	name = "First Officer's locker"
	req_access = list(access_hop)
	icon_state = "hop"

/obj/structure/closet/secure_closet/reinforced/hop/populate_contents()
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/under/rank/first_officer(src)
	new /obj/item/clothing/head/caphat/hop(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/armor/helmet(src)
	new /obj/item/device/radio/headset/heads/hop(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/storage/box/ids( src )
	new /obj/item/storage/belt/sheath(src)
	new /obj/item/tool/sword/saber(src)
	new /obj/item/gun/projectile/avasarala(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/device/flash(src)
	new /obj/item/storage/pouch/pistol_holster(src)

/obj/structure/closet/secure_closet/reinforced/preacher
	name = "Preacher's locker"

/obj/structure/closet/secure_closet/reinforced/hos
	name = "Ironhammer Commander locker"
	req_access = list(access_hos)
	icon_state = "hos"

/obj/structure/closet/secure_closet/reinforced/hos/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/ironhammer(src)
	else
		new /obj/item/storage/backpack/sport/ironhammer(src)
	new /obj/item/storage/backpack/satchel/ironhammer(src)
	new /obj/item/clothing/head/beret/sec/navy/hos(src)
	new /obj/item/clothing/head/HoS(src)
	new /obj/item/clothing/mask/gas/ihs(src)
	new /obj/item/clothing/suit/armor/greatcoat/ironhammer(src)
	new /obj/item/clothing/under/rank/ih_commander(src)
	new /obj/item/device/radio/headset/heads/hos(src)
	new /obj/item/clothing/glasses/sunglasses/sechud/tactical(src)
	new /obj/item/storage/belt/tactical/ironhammer(src)
	new /obj/item/clothing/gloves/stungloves(src)
	new /obj/item/cell/medium/high(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/ammo_magazine/magnum/rubber(src)
	new /obj/item/cell/small/high(src)
	new /obj/item/cell/small/high(src)
	new /obj/item/gun/energy/gun/martin(src)
	new /obj/item/clothing/accessory/holster/waist(src)
	new /obj/item/melee/telebaton(src)
	new /obj/item/clothing/accessory/badge/hos(src)
	new /obj/item/storage/pouch/pistol_holster(src)
	new /obj/item/storage/pouch/baton_holster(src)

/obj/structure/closet/secure_closet/warden
	name = "Gunnery Sergeant's locker"
	req_access = list(access_armory)
	icon_state = "warden"

/obj/structure/closet/secure_closet/warden/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/ironhammer(src)
	else
		new /obj/item/storage/backpack/sport/ironhammer(src)
	new /obj/item/storage/backpack/satchel/ironhammer(src)
	new /obj/item/clothing/under/rank/warden(src)
	new /obj/item/clothing/head/beret/sec/navy/warden(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/clothing/glasses/sunglasses/sechud/tactical(src)
	new /obj/item/storage/belt/tactical/ironhammer(src)
	new /obj/item/clothing/mask/gas/ihs(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/ammo_magazine/pistol/rubber(src)
	new /obj/item/ammo_magazine/pistol/rubber(src)
	new	/obj/item/gun/projectile/paco(src)
	new /obj/item/ammo_magazine/ihclrifle/rubber(src)
	new /obj/item/ammo_magazine/ihclrifle/rubber(src)
	new /obj/item/gun/projectile/automatic/sol(src)
	new /obj/item/storage/box/holobadge(src)
	new /obj/item/clothing/accessory/badge/warden(src)
	new /obj/item/storage/pouch/pistol_holster(src)
	new /obj/item/storage/pouch/baton_holster(src)
	new /obj/item/clothing/suit/armor/vest/ironhammer(src)

/obj/structure/closet/secure_closet/personal/security
	name = "Ironhammer Operative locker"
	req_access = list(access_hos)
	access_occupy = list(access_brig)
	icon_state = "sec"

/obj/structure/closet/secure_closet/personal/security/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/ironhammer(src)
	else
		new /obj/item/storage/backpack/sport/ironhammer(src)
	new /obj/item/storage/backpack/satchel/ironhammer(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/storage/belt/tactical/ironhammer(src)
	new /obj/item/clothing/mask/gas/ihs(src)
	new /obj/item/clothing/glasses/sunglasses/sechud/tactical(src)
	new /obj/item/ammo_magazine/ihclrifle/rubber(src)
	new /obj/item/ammo_magazine/ihclrifle/rubber(src)
	new /obj/item/gun/projectile/automatic/sol(src)
	new /obj/item/ammo_magazine/pistol/rubber(src)
	new /obj/item/ammo_magazine/pistol/rubber(src)
	new	/obj/item/gun/projectile/paco(src)
	new /obj/item/storage/pouch/pistol_holster(src)
	new /obj/item/storage/pouch/baton_holster(src)
	new /obj/item/storage/ration_pack/ihr(src)

/obj/structure/closet/secure_closet/medspec
	name = "Ironhammer Medical Specialist locker"
	req_access = list(access_medspec)
	icon_state = "sec"

/obj/structure/closet/secure_closet/medspec/populate_contents()
	new /obj/item/clothing/glasses/sunglasses/sechud/tactical(src)
	new /obj/item/clothing/mask/gas/ihs(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/clothing/under/rank/medspec(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/storage/belt/tactical/ironhammer(src)
	new /obj/item/clothing/shoes/reinforced/ironhammer(src)
	new /obj/item/clothing/gloves/stungloves(src)
	new /obj/item/cell/medium/high(src)
	new /obj/item/clothing/suit/storage/toggle/labcoat/medspec(src)
	new /obj/item/ammo_magazine/smg/rubber(src)
	new /obj/item/gun/projectile/automatic/molly(src)
	new /obj/item/storage/pouch/pistol_holster(src)
	new /obj/item/storage/briefcase/crimekit(src)

/obj/structure/closet/secure_closet/detective
	name = "Ironhammer Inspector locker"
	req_access = list(access_forensics_lockers)
	icon_state = "cabinetdetective"

/obj/structure/closet/secure_closet/detective/populate_contents()
	new /obj/item/clothing/under/rank/det(src)
	new /obj/item/clothing/under/rank/det/black(src)
	new /obj/item/clothing/under/rank/inspector(src)
	new /obj/item/clothing/suit/storage/detective(src)
	new /obj/item/clothing/suit/storage/detective/ironhammer(src)
	new /obj/item/clothing/mask/gas/ihs(src)
	new /obj/item/clothing/gloves/thick(src)
	new /obj/item/clothing/head/det(src)
	new /obj/item/clothing/head/det/grey(src)
	new /obj/item/clothing/shoes/reinforced/ironhammer(src)
	new /obj/item/storage/box/evidence(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/storage/belt/tactical/ironhammer(src)
	new /obj/item/clothing/suit/armor/vest/detective(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/clothing/glasses/sunglasses/sechud/tactical(src)
	new /obj/item/cell/small/high(src)
	new /obj/item/cell/small/high(src)
	new /obj/item/device/taperecorder(src)
	new /obj/item/gun/projectile/revolver/consul(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/ammo_magazine/slmagnum/rubber(src)
	new /obj/item/ammo_magazine/slmagnum/rubber(src)
	new /obj/item/ammo_magazine/slmagnum/rubber(src)
	new /obj/item/storage/pouch/pistol_holster(src)

/obj/structure/closet/secure_closet/injection
	name = "lethal injections locker"
	req_access = list(access_captain)
	icon_state = "secure"

/obj/structure/closet/secure_closet/injection/populate_contents()
	new /obj/item/reagent_containers/syringe/ld50_syringe/choral(src)
	new /obj/item/reagent_containers/syringe/ld50_syringe/choral(src)

/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_access = list(access_brig)
	anchored = TRUE
	icon_state = "secure"
	var/id

/obj/structure/closet/secure_closet/brig/populate_contents()
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/shoes/color/orange(src)

/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"
	req_access = list(access_security)
	icon_state = "sec"

/obj/structure/closet/secure_closet/courtroom/populate_contents()
	new /obj/item/clothing/shoes/color/brown(src)
	new /obj/item/paper/court(src)
	new /obj/item/paper/court(src)
	new /obj/item/paper/court(src)
	new /obj/item/pen(src)
	new /obj/item/clothing/suit/judgerobe(src)
	new /obj/item/clothing/head/powdered_wig(src)
	new /obj/item/storage/briefcase(src)
