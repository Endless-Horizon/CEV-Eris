/datum/unit_test/loadout_has_cost_and_name/Run()
	for(var/geartype in subtypesof(/datum/gear))
		var/datum/gear/G = geartype

		TEST_ASSERT(!initial(G.display_name), "Loadout ([G]) has no display name.")
		TEST_ASSERT(!initial(G.cost), "Loadout ([G]) has no cost.")
		TEST_ASSERT(!initial(G.path), "Loadout ([G]) has no path definition.")
