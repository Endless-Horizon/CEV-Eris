/datum/unit_test/research_designs_uniqueness/Run()
	var/list/ids = list()
	var/list/build_paths = list()

	for(var/D in SSresearch.all_designs)
		var/datum/design/design = D
		group_by(ids, design, design.id)
		group_by(build_paths, design, design.build_path)

	var/number_of_issues = number_of_issues(ids, "IDs")
	number_of_issues += number_of_issues(build_paths, "Build Paths")

	TEST_ASSERT_EQUAL(number_of_issues, 0, "Multiple conflicting research designs found.")

/datum/unit_test/player_preferences_uniqueness/Run()
	var/list/preference_keys = list()

	for(var/cp in get_client_preferences())
		var/datum/client_preference/client_pref = cp
		group_by(preference_keys, client_pref, client_pref.key)

	var/number_of_issues = number_of_issues(preference_keys, "Keys")
	TEST_ASSERT_EQUAL(number_of_issues, 0, "Multiple conflicting player preference found.")

/// USED BY UNIT TEST: uniqueness.dm
/proc/number_of_issues(list/entries, type)
	var/issues = 0
	for(var/value in entries)
		var/list/list_of_designs = entries[value]
		if(list_of_designs.len > 1)
			// a failure in a falure? mgod.
			log_test("[type] - The following entries have the same value - [value]: " + english_list(list_of_designs))
			issues++
	return issues
