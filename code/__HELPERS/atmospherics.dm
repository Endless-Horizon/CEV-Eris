/proc/analyze_gases(var/obj/A, var/mob/user)
	var/air_contents = A.return_air()
	var/list/result = atmosanalyzer_scan(A, air_contents)
	return result

/proc/atmosanalyzer_scan(var/obj/target, var/datum/gas_mixture/mixture, var/mob/user)
	. = list()
	. += SPAN_NOTICE("Results of the analysis of \the [target]:")
	if(!mixture)
		mixture = target.return_air()

	if(mixture)
		var/pressure = mixture.return_pressure()
		var/total_moles = mixture.total_moles

		if (total_moles>0)
			. += SPAN_NOTICE("Pressure: [round(pressure, 0.1)] kPa")
			for(var/mix in mixture.gas)
				. += SPAN_NOTICE("[gas_data.name[mix]]: [round((mixture.gas[mix] / total_moles) * 100)]%")
			. += SPAN_NOTICE("Temperature: [round(mixture.temperature-T0C)]&deg;C")
			return
	. += SPAN_NOTICE("\The [target] is empty!")

/obj/proc/atmosanalyze(var/mob/user)
	return

/obj/item/tank/atmosanalyze(var/mob/user)
	return atmosanalyzer_scan(src, src.air_contents, user)

/obj/machinery/portable_atmospherics/atmosanalyze(var/mob/user)
	return atmosanalyzer_scan(src, src.air_contents, user)

/obj/machinery/atmospherics/pipe/atmosanalyze(var/mob/user)
	return atmosanalyzer_scan(src, src.parent.air, user)

/obj/machinery/power/rad_collector/atmosanalyze(var/mob/user)
	if(P)	return atmosanalyzer_scan(src, src.P.air_contents, user)

/obj/item/flamethrower/atmosanalyze(var/mob/user)
	if(ptank)	return atmosanalyzer_scan(src, ptank.air_contents, user)
