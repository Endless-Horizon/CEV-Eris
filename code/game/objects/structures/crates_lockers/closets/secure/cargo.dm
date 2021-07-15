/obj/structure/closet/secure_closet/personal/cargotech
	name = "guild technician's locker"
	req_access = list(access_merchant)
	access_occupy = list(access_cargo)
	icon_state = "cargo"

/obj/structure/closet/secure_closet/personal/cargotech/populate_contents()
	new /obj/item/clothing/under/rank/cargotech(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/thick(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/device/scanner/price(src)

/obj/structure/closet/secure_closet/reinforced/quartermaster
	name = "guild merchant's locker"
	req_access = list(access_merchant)
	icon_state = "qm"

/obj/structure/closet/secure_closet/reinforced/quartermaster/populate_contents()
	new /obj/item/clothing/under/rank/cargotech(src)
	new /obj/item/clothing/shoes/color/brown(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/thick(src)
	new /obj/item/clothing/suit/fire(src)
	new /obj/item/tank/emergency_oxygen(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/powered/meson(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/gun/projectile/shotgun/pump(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/device/scanner/price(src)

/obj/structure/closet/secure_closet/personal/artist
	name = "guild artist's locker"
	req_access = list(access_merchant)
	access_occupy = list(access_artist)
	icon_state = "cargo"
	spawn_frequency = 0

/obj/structure/closet/secure_closet/personal/artist/populate_contents()
	new/obj/item/clothing/suit/artist(src)
	new/obj/item/clothing/under/rank/artist(src)
	new/obj/item/clothing/suit/artist(src)
	new/obj/item/clothing/shoes/artist_shoes(src)
	new/obj/item/clothing/head/beret/artist(src)
	new/obj/item/clothing/glasses/artist(src)
	new/obj/item/clothing/mask/gas/artist_hat(src)
	new/obj/item/device/radio/headset/headset_cargo(src)
	new/obj/item/electronics/circuitboard/artist_bench(src)

/obj/structure/closet/wardrobe/color/pink/artist

/obj/structure/closet/wardrobe/color/pink/artist/populate_contents()
	new/obj/item/clothing/under/mime(src)
	new/obj/item/clothing/shoes/color/black(src)
	new/obj/item/clothing/gloves/color/white(src)
	new/obj/item/clothing/mask/gas/mime(src)
	new/obj/item/clothing/head/beret(src)
	new/obj/item/pen/crayon/mime(src)
	new/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing(src)
	new/obj/item/bikehorn(src)
	new/obj/item/clothing/glasses/monocle(src)
	new/obj/item/storage/fancy/crayons(src)
	new/obj/item/reagent_containers/spray/waterflower(src)
	new/obj/item/device/pda/clown(src)
	new/obj/item/clothing/mask/gas/plaguedoctor(src)
	new/obj/item/clothing/gloves/color/green(src)
	new/obj/item/clothing/gloves/color/rainbow(src)
	new/obj/item/storage/backpack/clown(src)
	new/obj/item/clothing/shoes/clown_shoes(src)
	new/obj/item/clothing/under/rank/clown(src)
	new/obj/item/clothing/mask/gas/clown_hat(src)
	new/obj/item/clothing/under/gnome(src)
	new/obj/item/clothing/mask/gnome(src)
	new/obj/item/clothing/head/collectable/gnome(src)
