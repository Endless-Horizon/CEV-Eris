/datum/trade_station/bluespace_technical
	max_missing_assortiment = 2

	name_pool = list("B-42-Alpha" = "Unknown signature, bluespace traces interfere with sensors. Unable to triangulate object.")
	assortiment = list(
		"#$285@$532#$@" = list(
			/obj/item/weapon/circuitboard/teleporter,
			/obj/item/weapon/bluespace_harpoon,
			/obj/item/weapon/tool/knife/dagger/bluespace,
			/obj/item/weapon/reagent_containers/glass/beaker/bluespace,
			/obj/item/weapon/circuitboard/bssilk_hub,
			/obj/item/mech_equipment/catapult
		)
	)

	offer_types = list(
		/obj/item/bluespace_crystal = 0.25,
		/obj/item/device/mmi/digital/posibrain,
		/obj/item/weapon/reagent_containers/food/snacks/csandwich = 4
	)
	spawn_probability = 10
