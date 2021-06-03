#define SANITY_PASSIVE_GAIN 0.2

#define SANITY_DAMAGE_MOD 0.6

#define SANITY_VIEW_DAMAGE_MOD 0.4

// Damage received from unpleasant stuff in view
#define SANITY_DAMAGE_VIEW(damage, vig, dist) ((damage) * SANITY_VIEW_DAMAGE_MOD * (1.2 - (vig) / STAT_LEVEL_MAX) * (1 - (dist)/15))

// Damage received from body damage
#define SANITY_DAMAGE_HURT(damage, vig) (min((damage) / 5 * SANITY_DAMAGE_MOD * (1.2 - (vig) / STAT_LEVEL_MAX), 60))

// Damage received from shock
#define SANITY_DAMAGE_SHOCK(shock, vig) ((shock) / 50 * SANITY_DAMAGE_MOD * (1.2 - (vig) / STAT_LEVEL_MAX))

// Damage received from psy effects
#define SANITY_DAMAGE_PSY(damage, vig) (damage * SANITY_DAMAGE_MOD * (2 - (vig) / STAT_LEVEL_MAX))

// Damage received from seeing someone die
#define SANITY_DAMAGE_DEATH(vig) (10 * SANITY_DAMAGE_MOD * (1 - (vig) / STAT_LEVEL_MAX))

#define SANITY_GAIN_SMOKE 0.05 // A full cig restores 300 times that
#define SANITY_GAIN_SAY 1

#define SANITY_COOLDOWN_SAY rand(30 SECONDS, 45 SECONDS)
#define SANITY_COOLDOWN_BREAKDOWN rand(7 MINUTES, 10 MINUTES)

#define SANITY_CHANGE_FADEOFF(level_change) (level_change * 0.75)

#define INSIGHT_PASSIVE_GAIN 0.05
#define INSIGHT_GAIN(level_change) (INSIGHT_PASSIVE_GAIN + level_change / 15)

#define INSIGHT_DESIRE_COUNT 2

#define INSIGHT_DESIRE_FOOD "food"
#define INSIGHT_DESIRE_ALCOHOL "alcohol"
#define INSIGHT_DESIRE_SMOKING "smoking"
#define INSIGHT_DESIRE_DRUGS "drugs"


#define EAT_COOLDOWN_MESSAGE 15 SECONDS

/datum/sanity
	var/flags
	var/mob/living/carbon/human/owner

	var/sanity_passive_gain_multiplier = 1
	var/sanity_invulnerability = 0
	var/level
	var/max_level = 100
	var/level_change = 0

	var/insight
	var/max_insight = INFINITY
	var/insight_passive_gain_multiplier = 1
	var/insight_gain_multiplier = 1
	var/insight_rest = 0
	var/max_insight_rest = INFINITY
	var/insight_rest_gain_multiplier = 1
	var/resting = 0
	var/max_resting = INFINITY

	var/list/valid_inspirations = list(/obj/item/weapon/oddity)
	var/list/desires = list()
	var/positive_prob = 20
	var/positive_prob_multiplier = 1
	var/negative_prob = 30

	var/view_damage_threshold = 20
	var/environment_cap_coeff = 1 //How much we are affected by environmental cognitohazards. Multiplies the above threshold

	var/say_time = 0
	var/breakdown_time = 0
	var/spook_time = 0

	var/death_view_multiplier = 1

	var/list/datum/breakdown/breakdowns = list()

	var/eat_time_message = 0

	var/life_tick_modifier = 2	//How often is the onLife() triggered and by how much are the effects multiplied

/datum/sanity/New(mob/living/carbon/human/H)
	owner = H
	level = max_level
	insight = rand(0, 30)
	RegisterSignal(owner, COMSIG_MOB_LIFE, .proc/onLife)
	RegisterSignal(owner, COMSIG_HUMAN_SAY, .proc/onSay)

/datum/sanity/proc/give_insight(value)
	var/new_value = value
	if(value > 0)
		new_value = max(0, value * insight_gain_multiplier)
	insight = min(insight + new_value, max_insight)

/datum/sanity/proc/give_resting(value)
	resting = min(resting + value, max_resting)

/datum/sanity/proc/give_insight_rest(value)
	var/new_value = value
	if(value > 0)
		new_value = max(0, value * insight_rest_gain_multiplier)
	insight_rest += new_value

/datum/sanity/proc/onLife()
	handle_breakdowns()
	if(owner.stat == DEAD || owner.life_tick % life_tick_modifier || owner.in_stasis || (owner?.species?.lower_sanity_process && !owner.client))
		return
	var/affect = SANITY_PASSIVE_GAIN * sanity_passive_gain_multiplier
	if(owner.stat) //If we're unconscious
		changeLevel(affect)
		return
	if(!(owner.sdisabilities & BLIND) && !owner.blinded)
		affect += handle_area()
		affect -= handle_view()
	changeLevel(max(affect  * life_tick_modifier, min((view_damage_threshold*environment_cap_coeff) - level, 0)))
	handle_Insight()
	handle_level()
	SEND_SIGNAL(owner, COMSIG_HUMAN_SANITY, level)

/datum/sanity/proc/handle_view()
	. = 0
	if(sanity_invulnerability)
		return
	var/vig = owner.stats.getStat(STAT_VIG)
	for(var/atom/A in view(owner.client ? owner.client : owner))
		if(A.sanity_damage) //If this thing is not nice to behold
			. += SANITY_DAMAGE_VIEW(A.sanity_damage, vig, get_dist(owner, A))

		if(owner.stats.getPerk(PERK_MORALIST) && ishuman(A)) //Moralists react negatively to people in distress
			var/mob/living/carbon/human/H = A
			if(H.sanity.level < 30 || H.health < 50)
				. += SANITY_DAMAGE_VIEW(0.1, vig, get_dist(owner, A))


/datum/sanity/proc/handle_area()
	var/area/my_area = get_area(owner)
	if(!my_area)
		return 0
	. = my_area.sanity.affect
	if(. < 0)
		. *= owner.stats.getStat(STAT_VIG) / STAT_LEVEL_MAX

/datum/sanity/proc/handle_breakdowns()
	for(var/datum/breakdown/B in breakdowns)
		if(!B.update())
			breakdowns -= B

/datum/sanity/proc/handle_Insight()
	var/moralist_factor = 1
	var/style_factor = owner.get_style_factor()
	if(owner.stats.getPerk(PERK_MORALIST))
		for(var/mob/living/carbon/human/H in view(owner))
			if(H.sanity.level > 60)
				moralist_factor += 0.02
	give_insight(INSIGHT_GAIN(level_change) * insight_passive_gain_multiplier * moralist_factor * style_factor * life_tick_modifier)
	while(resting < max_resting && insight >= 100)
		give_resting(1)
		if(owner.stats.getPerk(PERK_ARTIST))
			to_chat(owner, SPAN_NOTICE("You have gained insight.[resting ? null : " Now you need to make art. You cannot gain more insight before you do."]"))
		else
			to_chat(owner, SPAN_NOTICE("You have gained insight.[resting ? null : " Now you need to rest and rethink your life choices."]"))
			pick_desires()
			insight -= 100
		owner.playsound_local(get_turf(owner), 'sound/sanity/psychochimes.ogg', 100)

	var/obj/screen/sanity/hud = owner.HUDneed["sanity"]
	hud?.update_icon()

/datum/sanity/proc/handle_level()
	level_change = SANITY_CHANGE_FADEOFF(level_change)

	if(level < 40 && world.time >= spook_time)
		spook_time = world.time + rand(1 MINUTES, 8 MINUTES) - (40 - level) * 1 SECONDS //Each missing sanity point below 40 decreases cooldown by a second

		var/static/list/effects_40 = list(
			.proc/effect_emote = 25,
			.proc/effect_quote = 50
		)
		var/static/list/effects_30 = effects_40 + list(
			.proc/effect_sound = 1,
			.proc/effect_whisper = 25,
		)
		var/static/list/effects_20 = effects_30 + list(
			.proc/effect_hallucination = 30
		)

		call(src, pickweight(level < 30 ? level < 20 ? effects_20 : effects_30 : effects_40))()


/datum/sanity/proc/pick_desires()
	desires.Cut()
	var/list/candidates = list(
		INSIGHT_DESIRE_FOOD,
		INSIGHT_DESIRE_ALCOHOL,
		INSIGHT_DESIRE_SMOKING,
		INSIGHT_DESIRE_DRUGS,
	)
	for(var/i = 0; i < INSIGHT_DESIRE_COUNT; i++)
		var/desire = pick_n_take(candidates)
		var/list/potential_desires = list()
		switch(desire)
			if(INSIGHT_DESIRE_FOOD)
				potential_desires = all_types_food.Copy()
			if(INSIGHT_DESIRE_ALCOHOL)
				potential_desires = all_taste_drinks.Copy()
			else
				desires += desire
				continue
		if(potential_desires.len)
			var/candidate = pick(potential_desires)
			desires += candidate
	print_desires()

/datum/sanity/proc/print_desires()
	if(!resting)
		return
	to_chat(owner, SPAN_NOTICE("You desire [english_list(desires)]."))

/datum/sanity/proc/add_rest(type, amount)
	if(!(type in desires))
		amount /= 16
	give_insight_rest(amount)
	if(insight_rest >= 100)
		insight_rest = 0
		finish_rest()

/datum/sanity/proc/finish_rest()
	var/list/stat_change = list()

	var/stat_pool = resting * 15
	while(stat_pool--)
		LAZYAPLUS(stat_change, pick(ALL_STATS), 1)

	for(var/stat in stat_change)
		owner.stats.changeStat(stat, stat_change[stat])

	if(!owner.stats.getPerk(PERK_ARTIST))
		INVOKE_ASYNC(src, .proc/oddity_stat_up, resting)

	if(owner.stats.getPerk(PERK_ARTIST))
		to_chat(owner, SPAN_NOTICE("You have created art and improved your stats."))
	else
		to_chat(owner, SPAN_NOTICE("You have rested well and improved your stats."))
	owner.playsound_local(get_turf(owner), 'sound/sanity/rest.ogg', 100)
	owner.pick_individual_objective()
	resting = 0

/datum/sanity/proc/oddity_stat_up(multiplier)
	var/list/inspiration_items = list()
	for(var/obj/item/I in owner.get_contents())
		if(is_type_in_list(I, valid_inspirations) && I.GetComponent(/datum/component/inspiration))
			inspiration_items += I
	if(inspiration_items.len)
		var/obj/item/O = inspiration_items.len > 1 ? owner.client ? input(owner, "Select something to use as inspiration", "Level up") in inspiration_items : pick(inspiration_items) : inspiration_items[1]
		if(!O)
			return
		GET_COMPONENT_FROM(I, /datum/component/inspiration, O) // If it's a valid inspiration, it should have this component. If not, runtime
		var/list/L = I.calculate_statistics()
		for(var/stat in L)
			var/stat_up = L[stat] * multiplier
			to_chat(owner, SPAN_NOTICE("Your [stat] stat goes up by [stat_up]"))
			owner.stats.changeStat(stat, stat_up)
		if(I.perk)
			if(owner.stats.addPerk(I.perk))
				I.perk = null
		for(var/mob/living/carbon/human/H in viewers(owner))
			SEND_SIGNAL(H, COMSIG_HUMAN_ODDITY_LEVEL_UP, owner, O)

/datum/sanity/proc/onDamage(amount)
	changeLevel(-SANITY_DAMAGE_HURT(amount, owner.stats.getStat(STAT_VIG)))

/datum/sanity/proc/onPsyDamage(amount)
	changeLevel(-SANITY_DAMAGE_PSY(amount, owner.stats.getStat(STAT_VIG)))

/datum/sanity/proc/onSeeDeath(mob/M)
	if(ishuman(M))
		var/penalty = -SANITY_DAMAGE_DEATH(owner.stats.getStat(STAT_VIG))
		if(owner.stats.getPerk(PERK_NIHILIST))
			var/effect_prob = rand(1, 100)
			switch(effect_prob)
				if(1 to 25)
					M.stats.addTempStat(STAT_COG, 5, INFINITY, "Fate Nihilist")
				if(25 to 50)
					M.stats.removeTempStat(STAT_COG, "Fate Nihilist")
				if(50 to 75)
					penalty *= -1
				if(75 to 100)
					penalty *= 0
		if(M.stats.getPerk(PERK_TERRIBLE_FATE) && prob(100-owner.stats.getStat(STAT_VIG)))
			setLevel(0)
		else
			changeLevel(penalty*death_view_multiplier)

/datum/sanity/proc/onShock(amount)
	changeLevel(-SANITY_DAMAGE_SHOCK(amount, owner.stats.getStat(STAT_VIG)))

/datum/sanity/proc/onDrug(datum/reagent/drug/R, multiplier)
	changeLevel(R.sanity_gain * multiplier)
	if(resting)
		add_rest(INSIGHT_DESIRE_DRUGS, 4 * multiplier)

/datum/sanity/proc/onToxin(datum/reagent/toxin/R, multiplier)
	changeLevel(-R.sanityloss * multiplier)

/datum/sanity/proc/onReagent(datum/reagent/E, multiplier)
	var/sanity_gain = E.sanity_gain_ingest
	if(E.id == "ethanol")
		sanity_gain /= 5
	changeLevel(sanity_gain * multiplier)
	if(resting && E.taste_tag.len)
		for(var/taste_tag in E.taste_tag)
			if(multiplier <= 1 )
				add_rest(taste_tag, 4 * 1/E.taste_tag.len)  //just so it got somme effect of things with small multipliers
			else
				add_rest(taste_tag, 4 * multiplier/E.taste_tag.len)

/datum/sanity/proc/onEat(obj/item/weapon/reagent_containers/food/snacks/snack, snack_sanity_gain, snack_sanity_message)
	if(world.time > eat_time_message && snack_sanity_message)
		eat_time_message = world.time + EAT_COOLDOWN_MESSAGE
		to_chat(owner, "[snack_sanity_message]")
	changeLevel(snack_sanity_gain)
	if(snack.cooked && resting && snack.taste_tag.len)
		for(var/taste in snack.taste_tag)
			add_rest(taste, snack_sanity_gain * 50/snack.taste_tag.len)

/datum/sanity/proc/onSmoke(obj/item/clothing/mask/smokable/S)
	changeLevel(SANITY_GAIN_SMOKE * S.quality_multiplier)
	if(resting)
		add_rest(INSIGHT_DESIRE_SMOKING, 0.4 * S.quality_multiplier)

/datum/sanity/proc/onSay()
	if(world.time < say_time)
		return
	say_time = world.time + SANITY_COOLDOWN_SAY
	changeLevel(SANITY_GAIN_SAY)

/datum/sanity/proc/changeLevel(amount)
	if(sanity_invulnerability && amount < 0)
		return
	updateLevel(level + amount)

/datum/sanity/proc/setLevel(amount)
	if(sanity_invulnerability)
		restoreLevel(amount)
		return
	updateLevel(amount)

/datum/sanity/proc/restoreLevel(amount)
	if(level <= amount)
		return
	updateLevel(amount)

/datum/sanity/proc/updateLevel(new_level)
	new_level = CLAMP(new_level, 0, max_level)
	level_change += abs(new_level - level)
	level = new_level
	if(level == 0 && world.time >= breakdown_time)
		breakdown()
	var/obj/screen/sanity/hud = owner.HUDneed["sanity"]
	hud?.update_icon()

/datum/sanity/proc/breakdown(var/positive_breakdown = FALSE)
	breakdown_time = world.time + SANITY_COOLDOWN_BREAKDOWN

	for(var/obj/item/device/mind_fryer/M in GLOB.active_mind_fryers)
		if(get_turf(M) in view(get_turf(owner)))
			M.reg_break(owner)

	for(var/obj/item/weapon/implant/carrion_spider/mindboil/S in GLOB.active_mindboil_spiders)
		if(get_turf(S) in view(get_turf(owner)))
			S.reg_break(owner)

	var/list/possible_results
	if((prob(positive_prob) && positive_prob_multiplier > 0) || positive_breakdown)
		possible_results = subtypesof(/datum/breakdown/positive)
	else if(prob(negative_prob))
		possible_results = subtypesof(/datum/breakdown/negative)
	else
		possible_results = subtypesof(/datum/breakdown/common)

	for(var/datum/breakdown/B in breakdowns)
		possible_results -= B.type

	while(possible_results.len)
		var/breakdown_type = pick(possible_results)
		var/datum/breakdown/B = new breakdown_type(src)

		if(!B.can_occur())
			possible_results -= breakdown_type
			qdel(B)
			continue

		if(B.occur())
			breakdowns += B
			for(var/mob/living/carbon/human/H in viewers(owner))
				SEND_SIGNAL(H, COMSIG_HUMAN_BREAKDOWN, owner, B)
		return

#undef SANITY_PASSIVE_GAIN
