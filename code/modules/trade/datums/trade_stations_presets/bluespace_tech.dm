/datum/trade_station/bluespace_technical
	name_pool = list("B-42-Alpha" = "Unknown signature, bluespace traces interfere with sensors. Unable to triangulate object.")
	assortiment = list(
		"#$285@$532#$@" = list(
			/obj/item/electronics/circuitboard/teleporter,
			/obj/item/tool/knife/dagger/bluespace,
			/obj/item/reagent_containers/glass/beaker/bluespace,
			/obj/item/electronics/circuitboard/bssilk_hub,
		)
	)

	offer_types = list(
		/obj/item/bluespace_crystal = 0.25,
		/obj/item/device/mmi/digital/posibrain,
		/obj/item/reagent_containers/food/snacks/csandwich = 4
	)
	spawn_probability = 10
