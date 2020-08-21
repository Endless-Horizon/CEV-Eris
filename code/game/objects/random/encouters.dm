#define DAMAGE_POWER_TRANSFER 450 //used to transfer power to containment field generators
#define ENCOUTER_PROBALITY 100

/obj/random/encouter
	spawn_nothing_percentage = 0
	var/list/obj/random/spawner/encouter/encouters = list(/obj/random/spawner/encouter/mine, /obj/random/spawner/encouter/miningbot, /obj/random/spawner/encouter/strangebeacon, \
	/obj/spawner/encouter/cryopod, /obj/spawner/encouter/cryopod, /obj/random/spawner/encouter/coffin, /obj/random/spawner/encouter/omnius)

/obj/random/encouter/item_to_spawn()
	..()
	return pick(encouters)


///////ENCOUTERS
//////////////////////

/obj/random/spawner/encouter
	spawn_nothing_percentage = 0
	var/justspawn = TRUE
	var/list/obj/randspawn = list()

/obj/random/spawner/encouter/item_to_spawn()
	..()
	if(justspawn == TRUE)
		return pick(randspawn)

/obj/random/spawner/encouter/mine
	randspawn = list(/obj/structure/mine/mine_no_primer, /obj/item/weapon/mine, /obj/structure/mine/mine_scraps)

/obj/random/spawner/encouter/miningbot
	randspawn = list(/mob/living/bot/miningonestar/resources, /mob/living/bot/miningonestar/resources/agressive, /mob/living/bot/miningonestar/resources/agressive/with_support, \
	/mob/living/bot/miningonestar/resources/in_work)

/obj/random/spawner/encouter/strangebeacon
	randspawn = list(/obj/structure/strangebeacon, /obj/structure/strangebeacon/bots, /obj/structure/strangebeacon/pods, \
	/obj/structure/strangebeacon/bombard)

/obj/spawner/encouter/cryopod
	tags_to_spawn = list(SPAWN_ENCOUNTER_CRYOPOD)

/obj/spawner/encouter/satellite
	tags_to_spawn = list(SPAWN_TAG_SATELITE)

/obj/random/spawner/encouter/coffin
	randspawn = list(/obj/structure/closet/coffin/spawnercorpse)

/obj/random/spawner/encouter/omnius
	randspawn = list(/obj/structure/ominous, /obj/structure/ominous/emitter, /obj/structure/ominous/teleporter)

///////ENCOUTERS
//////////////////////

