/*
	Deferred spawn storage containers
*/

/*
	These are a special type of storage container used for less-accessed gear. They create their contents through a
	spawn_contents proc which is called the first time the box is opened or interacted with.

	The key thing here is, these contents are not spawned at roundstart, only when a player actually needs them
	And thusly, if no player ever does, then those items are not sitting around wasting memory and CPU time

	Most of the things in this file are intended for use by external antags, and are thus exceptionally powerful
*/


/obj/item/weapon/storage/deferred
	var/list/initial_contents = list() //List of stuff that will be in this box
	//Can be used as an assoc list and allow you to enter a quantity as the value

	var/contents_spawned = FALSE

	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"

/obj/item/weapon/storage/deferred/proc/spawn_contents()
	contents_spawned = TRUE
	for (var/a in initial_contents)
		var/quantity = 1
		if (initial_contents[a])
			quantity = initial_contents[a]

		for (var/i = 0; i < quantity; i++)
			new a(src)
	make_exact_fit()

/obj/item/weapon/storage/deferred/open(var/mob/user)
	if (!contents_spawned)
		spawn_contents()
	.=..()

/obj/item/weapon/storage/deferred/show_to(var/mob/user)
	if (!contents_spawned)
		spawn_contents()
	.=..()


/obj/item/weapon/storage/deferred/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if (!contents_spawned)
		spawn_contents()
	.=..()


/obj/item/weapon/storage/deferred/rations
	name = "field rations kit"
	icon_state = "donk_kit"
	desc = "A box of preserved, ready-to-eat food for soldiers and spacefarers on the go"
	initial_contents = list(/obj/random/rations = 10)


/obj/item/weapon/storage/deferred/toolmod
	name = "tool modifications kit"
	desc = "A sturdy container full of contraptions, bits of material, components and add-ons for modifying tools"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	initial_contents = list(/obj/random/tool_upgrade = 9,
	/obj/random/tool_upgrade/rare = 3)


/obj/item/weapon/storage/deferred/pouches
	name = "uniform modification kit"
	desc = "A box full of hard-wearing pouches designed for easy attachment to clothing and armor. Good for carrying extra ammo or tools in the field"
	initial_contents = list(/obj/random/pouch = 8)



//Medical
/obj/item/weapon/storage/deferred/surgery
	name = "surgery kit"
	desc = "Contains tools for surgery. Has precise foam fitting for safe transport."
	icon_state = "surgeon"
	item_state = "firstaid-surgeon"
	initial_contents = list(
		/obj/item/weapon/tool/bonesetter,
		/obj/item/weapon/tool/cautery,
		/obj/item/weapon/tool/saw/circular,
		/obj/item/weapon/tool/hemostat,
		/obj/item/weapon/tool/retractor,
		/obj/item/weapon/tool/scalpel,
		/obj/item/weapon/tool/surgicaldrill,
		/obj/item/stack/medical/advanced/bruise_pack
		)
	can_hold = list(
		/obj/item/weapon/tool/bonesetter,
		/obj/item/weapon/tool/cautery,
		/obj/item/weapon/tool/saw/circular,
		/obj/item/weapon/tool/hemostat,
		/obj/item/weapon/tool/retractor,
		/obj/item/weapon/tool/scalpel,
		/obj/item/weapon/tool/surgicaldrill,
		/obj/item/stack/medical/advanced/bruise_pack
		)


/obj/item/weapon/storage/deferred/meds
	name = "combat medical kit"
	desc = "Contains advanced medical treatments."
	icon_state = "bezerk"
	item_state = "firstaid-advanced"
	initial_contents = list(/obj/item/weapon/storage/pill_bottle/bicaridine,
	/obj/item/weapon/storage/pill_bottle/dermaline,
	/obj/item/weapon/storage/pill_bottle/dexalin_plus,
	/obj/item/weapon/storage/pill_bottle/dylovene,
	/obj/item/weapon/storage/pill_bottle/tramadol,
	/obj/item/weapon/storage/pill_bottle/spaceacillin,
	/obj/item/stack/medical/splint)



//Crates
//These use open topped crate sprites but are still functionally boxes. They can be picked up, but are too large to fit in anything
/obj/item/weapon/storage/deferred/crate
	w_class = ITEM_SIZE_HUGE //This is too big to fit in a backpack

/obj/item/weapon/storage/deferred/crate/tools
	name = "tool storage box"
	desc = "A moderately sized crate full of assorted tools"
	icon_state = "plasmacrate"
	item_state = "toolbox_yellow"
	initial_contents = list(/obj/random/tool = 8, /obj/random/tool/advanced = 3)


/obj/item/weapon/storage/deferred/crate/saw
	name = "infantry support crate"
	desc = "a crate containing two L6 SAW light machine guns, and 640 rounds of 7.62mm ammunition"
	icon_state = "weaponcrate"
	item_state = "toolbox_yellow"
	initial_contents = list(/obj/item/weapon/gun/projectile/automatic/l6_saw = 2, /obj/item/ammo_magazine/ammobox/a762 = 8)


/obj/item/weapon/storage/deferred/crate/ak
	name = "rifleman crate"
	desc = "a crate containing six AK-47 rifles, and plenty of magazines"
	icon_state = "weaponcrate"
	item_state = "toolbox_yellow"
	initial_contents = list(/obj/item/weapon/gun/projectile/automatic/ak47/fs  = 6, /obj/item/ammo_magazine/ak47 = 14)

/obj/item/weapon/storage/deferred/crate/grenadier
	name = "grenadier crate"
	desc = "a crate containing one \"Lenar\" launcher, and copious quantities of hand-propelled explosive devices"
	icon_state = "weaponcrate"
	item_state = "toolbox_yellow"
	initial_contents = list(/obj/item/weapon/grenade/frag/explosive = 3,
	/obj/item/weapon/grenade/frag = 14,
	/obj/item/weapon/grenade/empgrenade/low_yield = 4,
	/obj/item/weapon/grenade/smokebomb = 8,
	/obj/item/weapon/gun/launcher/grenade/lenar = 1)

/obj/item/weapon/storage/deferred/crate/marksman
	name = "marksman crate"
	desc = "a crate containing one \"Penetrator\" rifle, and seventy 14.5mm AP shells"
	icon_state = "weaponcrate"
	item_state = "toolbox_yellow"
	initial_contents = list(/obj/item/weapon/gun/projectile/heavysniper = 1,
	/obj/item/weapon/storage/box/sniperammo = 2)

/obj/item/weapon/storage/deferred/crate/sidearm
	name = "sidearm crate"
	desc = "a crate containing six Makarov 9mm pistols, 200 rounds of 9mm ammunition, and six fixed-blade combat knives"
	icon_state = "weaponcrate"
	item_state = "toolbox_yellow"
	initial_contents = list(/obj/item/weapon/gun/projectile/clarissa/makarov = 6,
	/obj/item/ammo_magazine/mc9mm  = 20,
	/obj/item/weapon/material/knife/boot = 6)

/obj/item/weapon/storage/deferred/crate/cells
	name = "power cell bin"
	desc = "A moderately sized crate full of various power cells"
	icon_state = "plasmacrate"
	item_state = "toolbox_yellow"
	initial_contents = list(/obj/random/powercell = 16)