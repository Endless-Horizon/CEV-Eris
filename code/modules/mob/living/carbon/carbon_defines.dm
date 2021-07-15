/mob/living/carbon
	gender = MALE
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/list/stomach_contents = list()
	var/list/datum/disease2/disease/virus2 = list()
	var/list/antibodies = list()

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
					  // life should decrease this by 1 every tick
	// total amount of wounds on mob, used to spread out healing and the like over all wounds
	var/obj/item/handcuffed //Whether or not the mob is handcuffed
	var/obj/item/legcuffed  //Same as handcuffs but for legs. Bear traps use this.
	//Active emote/pose
	var/pose

	//Values from all base organs should add up to this
	var/total_blood_req = 40
	var/total_oxygen_req = 50
	var/total_nutriment_req = DEFAULT_HUNGER_FACTOR

	var/datum/reagents/metabolism/bloodstr
	var/datum/reagents/metabolism/ingested
	var/datum/reagents/metabolism/touching
	var/datum/metabolism_effects/metabolism_effects
	var/losebreath = 0 //if we failed to breathe last tick

	var/coughedtime
	var/lastpuke = 0

	var/cpr_time = 1
	nutrition = 400//Carbon

	var/is_watching = TRUE  //used for remote viewing of multiz structures
	var/can_multiz_pb = FALSE // used for point-blanking people that camp ladders.

	var/obj/item/tank/internal //Human/Monkey


	bad_type = /mob/living/carbon
	//TODO: move to brain

