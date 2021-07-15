/datum/design/research/item/part
	build_type = AUTOLATHE | PROTOLATHE
	name_category = "component"
	category = CAT_STOCKPARTS

/datum/design/research/item/part/AssembleDesignDesc()
	if(!desc)
		desc = "A stock part used in the construction of various devices."

/datum/design/research/item/part/basic_capacitor
	build_path = /obj/item/stock_parts/capacitor
	sort_string = "CAAAA"

/datum/design/research/item/part/adv_capacitor
	build_path = /obj/item/stock_parts/capacitor/adv
	sort_string = "CAAAB"

/datum/design/research/item/part/super_capacitor
	build_path = /obj/item/stock_parts/capacitor/super
	sort_string = "CAAAC"

/datum/design/research/item/part/micro_mani
	build_path = /obj/item/stock_parts/manipulator
	sort_string = "CAABA"

/datum/design/research/item/part/nano_mani
	build_path = /obj/item/stock_parts/manipulator/nano
	sort_string = "CAABB"

/datum/design/research/item/part/pico_mani
	build_path = /obj/item/stock_parts/manipulator/pico
	sort_string = "CAABC"

/datum/design/research/item/part/basic_matter_bin
	build_path = /obj/item/stock_parts/matter_bin
	sort_string = "CAACA"

/datum/design/research/item/part/adv_matter_bin
	build_path = /obj/item/stock_parts/matter_bin/adv
	sort_string = "CAACB"

/datum/design/research/item/part/super_matter_bin
	build_path = /obj/item/stock_parts/matter_bin/super
	sort_string = "CAACC"

/datum/design/research/item/part/basic_micro_laser
	build_path = /obj/item/stock_parts/micro_laser
	sort_string = "CAADA"

/datum/design/research/item/part/high_micro_laser
	build_path = /obj/item/stock_parts/micro_laser/high
	sort_string = "CAADB"

/datum/design/research/item/part/ultra_micro_laser
	build_path = /obj/item/stock_parts/micro_laser/ultra
	sort_string = "CAADC"

/datum/design/research/item/part/basic_sensor
	build_path = /obj/item/stock_parts/scanning_module
	sort_string = "CAAEA"

/datum/design/research/item/part/adv_sensor
	build_path = /obj/item/stock_parts/scanning_module/adv
	sort_string = "CAAEB"

/datum/design/research/item/part/phasic_sensor
	build_path = /obj/item/stock_parts/scanning_module/phasic
	sort_string = "CAAEC"


// Telecomm parts
/datum/design/research/item/part/subspace_ansible
	build_path = /obj/item/stock_parts/subspace/ansible
	category = "Telecoms | Bluespace"
	sort_string = "UAAAA"

/datum/design/research/item/part/hyperwave_filter
	build_path = /obj/item/stock_parts/subspace/filter
	category = "Telecoms | Bluespace"
	sort_string = "UAAAB"

/datum/design/research/item/part/subspace_amplifier
	build_path = /obj/item/stock_parts/subspace/amplifier
	category = "Telecoms | Bluespace"
	sort_string = "UAAAC"

/datum/design/research/item/part/subspace_treatment
	build_path = /obj/item/stock_parts/subspace/treatment
	category = "Telecoms | Bluespace"
	sort_string = "UAAAD"

/datum/design/research/item/part/subspace_analyzer
	build_path = /obj/item/stock_parts/subspace/analyzer
	category = "Telecoms | Bluespace"
	sort_string = "UAAAE"

/datum/design/research/item/part/subspace_crystal
	build_path = /obj/item/stock_parts/subspace/crystal
	category = "Telecoms | Bluespace"
	sort_string = "UAAAF"

/datum/design/research/item/part/subspace_transmitter
	build_path = /obj/item/stock_parts/subspace/transmitter
	category = "Telecoms | Bluespace"
	sort_string = "UAAAG"

/datum/design/research/item/part/artificialbscrystal
	name = "Artificial BlueSpace Crystal"
	build_path = /obj/item/bluespace_crystal/artificial
	category = "Telecoms | Bluespace"
	sort_string = "VAAAF"

// SMES coils
/datum/design/research/item/part/smes_coil
	build_path = /obj/item/stock_parts/smes_coil
	sort_string = "UAAAH"

/datum/design/research/item/part/smes_coil/weak
	build_path = /obj/item/stock_parts/smes_coil/weak
	sort_string = "UAAAI"

/datum/design/research/item/part/smes_coil/super_io
	build_path = /obj/item/stock_parts/smes_coil/super_io
	sort_string = "UAAAJ"

/datum/design/research/item/part/smes_coil/super_capacity
	build_path = /obj/item/stock_parts/smes_coil/super_capacity
	sort_string = "UAAAK"

// RPED
/datum/design/research/item/part/RPED
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	build_path = /obj/item/storage/part_replacer
	sort_string = "CBAAA"

/datum/design/research/item/part/rocket
	name = "Rocket Engine"
	build_path = /obj/item/rocket_engine