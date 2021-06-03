//var/global/list/datum/pipe_network/pipe_networks = list()

/datum/pipe_network
	var/list/datum/gas_mixture/gases = list() //All of the gas_mixtures continuously connected in this network
	var/volume = 0	//caches the total volume for atmos machines to use in gas calculations

	var/list/obj/machinery/atmospherics/normal_members
	var/list/datum/pipeline/line_members
		//membership roster to go through for updates and what not

	///Should we equalize air amoung all our members?
	var/update = TRUE
	///Is this pipeline being reconstructed?
	var/building = FALSE
	//var/datum/gas_mixture/air_transient = null

/datum/pipe_network/New()
	//air_transient = new()
	normal_members = list()
	line_members = list()
	SSair.networks += src

/datum/pipe_network/Destroy()
	SSair.networks -= src
	// if(building)
	// 	SSair.remove_from_expansion(src)

	for(var/obj/machinery/atmospherics/normal_member in normal_members)
		normal_member.reassign_network(src,null)

	for(var/datum/pipeline/line_member in line_members)
		line_member.network = null

	gases.Cut()
	normal_members.Cut()
	line_members.Cut()

	. = ..()

/datum/pipe_network/process()
	//Equalize gases amongst pipe if called for
	if(!update || building)
		return
	reconcile_air() //equalize_gases(gases)

	//Give pipelines their process call for pressure checking and what not. Have to remove pressure checks for the time being as pipes dont radiate heat - Mport
	//for(var/datum/pipeline/line_member in line_members)
	//	line_member.Process()

///Preps a pipeline for rebuilding, insterts it into the rebuild queue
/datum/pipe_network/proc/build_network(obj/machinery/atmospherics/start_normal, obj/machinery/atmospherics/reference)
	//Purpose: Generate membership roster
	//Notes: Assuming that members will add themselves to appropriate roster in network_expand()
	// building = TRUE
	if(!start_normal)
		qdel(src)
		return

	start_normal.network_expand(src, reference)

	update_network_gases()

	if(!((normal_members.len > 0) || (line_members.len > 0)))
		qdel(src)

/datum/pipe_network/proc/merge(datum/pipe_network/parent_pipeline)
	if(parent_pipeline == src)
		return

	normal_members |= parent_pipeline.normal_members
	line_members |= parent_pipeline.line_members

	for(var/obj/machinery/atmospherics/normal_member in parent_pipeline.normal_members)
		normal_member.reassign_network(parent_pipeline, src)

	for(var/datum/pipeline/line_member in parent_pipeline.line_members)
		line_member.network = src

	update_network_gases()
	return 1

/datum/pipe_network/proc/update_network_gases()
	//Go through membership roster and make sure gases is up to date

	gases = list()
	volume = 0

	for(var/obj/machinery/atmospherics/normal_member in normal_members)
		var/result = normal_member.return_network_air(src)
		if(result) gases += result

	for(var/datum/pipeline/line_member in line_members)
		gases += line_member.air

	for(var/datum/gas_mixture/air in gases)
		volume += air.volume

/datum/pipe_network/proc/reconcile_air()
	equalize_gases(gases)
