//As a general rule, all origin backrounds must have summ of +5 of stat values

/datum/category_group/setup_option_category/background/origin
	name = "Origin"
	category_item_type = /datum/category_item/setup_option/background/origin

/datum/category_item/setup_option/background/origin

/datum/category_item/setup_option/background/origin/oberth
	name = "Oberth"
	desc = "An independent colony founded by German immigrants from old Earth and consisting of one giant hive city on a barren desert planet. \
			It was once one of the most promising of colonies, back when the terraforming process had just begun; a group of scientists gathered together to forge a brighter future. \
			Now, after a stalemated civil war, Oberth has degenerated into an anarcho-capitalist hell ruled by three governments, all unable to establish control over the city or stop ravaging band wars. \
			Even Hanza and NeoTheology failed to bring order. Though still a place of infinite possibilities, most of them are illegal."

	stat_modifiers = list(
		STAT_ROB = 6,
		STAT_TGH = -5,
		STAT_BIO = 0,
		STAT_MEC = 6,
		STAT_VIG = 6,
		STAT_COG = -8
	)

/datum/category_item/setup_option/background/origin/oberth/apply(mob/living/carbon/human/character)
  ..()
  character.add_language(LANGUAGE_GERMAN)


/datum/category_item/setup_option/background/origin/predstraza
	name = "Predstraza"
	desc = "The product of a widely held idea back on Earth that if one were to bring all of the Balkan populations on one colony ship, they would be forced to put aside their differences and work together to survive. \
			Unfortunately, that idea failed miserably and is still failing. \
			A jungle death world, full of hostile fauna and mired in endless armed conflict. \
			The Serbian government occupied all of Predstraza's space ports and controls most of the civilized regions. \
			Located far from Hanza or NT territories, it's a place favored for business by pirates, smugglers and all manner of outlaw."

	stat_modifiers = list(
		STAT_ROB = 10,
		STAT_TGH = 10,
		STAT_BIO = 0,
		STAT_MEC = -10,
		STAT_VIG = 5,
		STAT_COG = -10
	)

/datum/category_item/setup_option/background/origin/predstraza/apply(mob/living/carbon/human/character)
  ..()
  character.add_language(LANGUAGE_SERBIAN)

/datum/category_item/setup_option/background/origin/sich_prime
	name = "Sich Prime"
	desc = "A Ukrainian colony that was a major industrial center during the Corporation Wars, during which they made the fatal mistake of siding with Nanotrasen. \
			Bombed and poisoned, this planet suffered the harshest toll of the war, both from population loss and ecological devastation. \
			While ostensibly under the direct control of Hanza, its local military is extremely disloyal and known to support the Founders - a revanchist international group that seeks the return of planetary government's national control over space."

	stat_modifiers = list(
		STAT_ROB = 5,
		STAT_TGH = -5,
		STAT_BIO = 10,
		STAT_MEC = 5,
		STAT_VIG = -5,
		STAT_COG = -5
	)


/datum/category_item/setup_option/background/origin/new_rome
	name = "New Rome"
	desc = "One of the first colonies founded by American settlers, New Rome was rich with biosphere and natural resources and served as Nanotrasen's headquarters when it was still an emerging power. As such, it holds the highest human population of any planet in the galaxy. \
			Although the War ended before it was sieged, New Rome suffered an economic crisis following the fall of Nanotrasen and never recovered. \
			Formerly a garden world, it is now dotted with hive cities, decaying ecologies, widespread poverty, and NeoTheology desperately trying to revive the ecosphere artificially with biomatter technology. \
			On New Rome, one must make the choice: to remain free and die impoverished and starving, or join the cult of NeoTheology to survive with a stable job and a place to live."

	stat_modifiers = list(
		STAT_ROB = 5,
		STAT_TGH = 5,
		STAT_BIO = 10,
		STAT_MEC = 5,
		STAT_VIG = -10,
		STAT_COG = -10
	)

/datum/category_item/setup_option/background/origin/new_rome/apply(mob/living/carbon/human/character)
  ..()
  character.add_language(LANGUAGE_LATIN)


/datum/category_item/setup_option/background/origin/shimatengoku
	name = "Shimatengoku"
	desc = "Founded by a Japanese megacorporation, Shimatengoku was - and still is - a high tech paradise. With 95% of its surface covered in seawater, its residents mostly live on islands, or drift along on gigantic oceanborne colonies. \
			When the time of the Corporation War came, Shimatengoku made the wise decision to side with the Syndicate, and prospered immensely as a result. \
			While there is a local government administration, the planet is mostly controlled by Frozen Star, an enormous company that is responsible for producing most of the military products found in Hanza. \
			Frozen Star itself is owned by a family with ties to the Yakuza, organized crime syndicates originating from old Earth's Japan. Fittingly, is a cruelly efficient place."

	stat_modifiers = list(
		STAT_ROB = -6,
		STAT_TGH = -7,
		STAT_BIO = -7,
		STAT_MEC = 10,
		STAT_VIG = 10,
		STAT_COG = 5
	)

/datum/category_item/setup_option/background/origin/shimatengoku/apply(mob/living/carbon/human/character)
  ..()
  character.add_language(LANGUAGE_NEOHONGO)


/datum/category_item/setup_option/background/origin/hmss_destined
	name = "HMSS \"Destined\""
	desc = "A British colony ship that was one of those who failed to locate a habitable world before exhausting its fuel supply; however, unlike the others, the crew managed to survive by turning their ship into the largest station in Hanza controlled space. \
			Plated in rusty metal, with high costs of living, a permanent space roach infestation and no natural ecology to speak of, the \"Destined\" can be aptly described as an industrial hell. \
			While The Corporation War was rather merciful to it, and the station remained neutral throughout most of the conflict, in the end, it succumbed to Syndicate occupation. \
			The \"Destined\" is widely known for its anachronistic Monarchical government and system of noble peerage, with most successful nobles controlling smaller stations near it and others bent on quelling the chaos within the Colony proper. \
			They are also members of Asters Guild, and this whole station is considered major Guild territory."

	stat_modifiers = list(
		STAT_ROB = 5,
		STAT_TGH = 5,
		STAT_BIO = -10,
		STAT_MEC = 5,
		STAT_VIG = 10,
		STAT_COG = -10
	)


/datum/category_item/setup_option/background/origin/crozet
	name = "Crozet"
	desc = "A lifeless, unforgiving ice world, rich with rare minerals, life on Crozet is only possible underground. \
			Originally founded by a French mining company, it was occupied later by exiled nobility from the HMSS \"Destined\". \
			The exiles founded the Four Great Houses to defend the colony's sovereignty, as well as their right to work the local population to death in the mines. \
			This lasted until Nanotrasen invaded with the help of one of the Houses, and later, Crozet was left under NeoTheology control under the terms of a peace treaty. \
			The local population are prone to revolt after decades of mistreatment and generally want to be left alone, making them ripe for recruitment by the Founders."

	stat_modifiers = list(
		STAT_ROB = 5,
		STAT_TGH = 10,
		STAT_BIO = -7,
		STAT_MEC = -7,
		STAT_VIG = 10,
		STAT_COG = -6
	)


/datum/category_item/setup_option/background/origin/first_expeditionary_fleet
	name = "First Expeditionary Fleet"
	desc = "A collection of old and modified colony ships, FTL capable shipyards, mobile hydroponics, and an armada of military ships. \
			The de facto Headquarters of the Ironhammer PMC, the armada can be deployed whenever or wherever is needed for a contract, or even evacuate to deep space if necessary. \
			It moves from planet to planet in Hanza space, and is often used by larger, being used as a giant power projector over planetary governments. \
			For the fleet to function, a gigantic amount of manpower is required, and the armada's ships tend to be as populous as small cities, with both civilians and military personnel. \
			Life in the Fleet is rather dull and spartan most of the time, with deep traditions of asceticism rooted in the crew of every ship. \
			Needless to say, every planet it visits experiences a large tourism boom, growth in consumerism, and every bar and whorehouse running out of vacancy in under a day."

	stat_modifiers = list(
		STAT_ROB = 5,
		STAT_TGH = 5,
		STAT_BIO = -15,
		STAT_MEC = 5,
		STAT_VIG = 15,
		STAT_COG = -10
	)


/datum/category_item/setup_option/background/origin/end_point
	name = "End Point"
	desc = "A trinary system with complicated orbits and black hole located in a safe distance from all of the habitable planets in the system. \
			One of the first colonies, because of how rich the planets are in resources, and their abundance - the system being composed of more than a hundred of large celestial bodies. \
			It's also an extremely valuable place for scientists, due to its habitable planets, the black hole and rare materials. \
			End Point was never controlled by a single power. \
			Smaller colony ships, belonging to third-world countries, damaged ships or just exploration cruisers - they have all found their place here, guided by a black hole and the riches highlighted by it. \
			Even before the war it was full of conflicts between local governments, pirates and corporations, and it just got worse afterwards. \
			While it's formally under Hanza control now, the war resulted in a fall of many governments, thus the anarchy spreads, and patchwork states are being born and die every year. \
			Nations are mixed in a spiral of endless conflict, all of the old Earth languages are present there, and any ideology and religion can be found here. \
			This system is also known for Moebius HQ - a large station orbiting the End Point black hole."

	stat_modifiers = list(
		STAT_ROB = -9,
		STAT_TGH = -8,
		STAT_BIO = 10,
		STAT_MEC = 10,
		STAT_VIG = -8,
		STAT_COG = 10
	)


/datum/category_item/setup_option/background/origin/nss_forecaster
	name = "NSS \"Forecaster\""
	desc = "Designed to serve as large, FTL capable mining platform by the first days of NanoTrasen. \
			And it was used for that, until stars started coming back from Null Space. \
			In order to salvage those wonders first, NanoTrasen has sent this platform, reworked to serve as a local forward operating base, and renamed it to Central Command. \
			The war broke out, and without any support from the mainland, after relentless attacks from the Syndicate, and the destruction of many stations under CentCom's control, such as NSS 13 \"Exodus\", they surrendered to Syndicate. \
			Now it's an independent station under Ironhammer control, that oversees the spread of Null Space artifacts, or at least is trying to. \
			It's a place for grand deals to be made, friends to be sold, a place where people run from law and boring life,for a fresh start in Null Space. \
			And - in most cases - die a horrible death in the end."

	stat_modifiers = list(
		STAT_ROB = 2,
		STAT_TGH = 2,
		STAT_BIO = -10,
		STAT_MEC = 2,
		STAT_VIG = 10,
		STAT_COG = 2
	)


/datum/category_item/setup_option/background/origin/eureka
    name = "Eureka"
    desc = "Once a paradise for the Australian colonists that lived on it, their neutrality during the corporate wars cost them this paradise. \
            And thus did the Syndicate and Nanotrasen both bomb Eureka to hell, causing once verdant lands to become hellish deserts of nuclear proportions. \
            As a side effect of this once the corporate wars ended, Eurekans are known to be eerily good trackers and pathfinders in these conditions and elsewhere, causing what's left of the Eurekan people to pay a tithe to Hansa and Neotheology both in the form of criminals. \
            All in the name of saving what's left."

    stat_modifiers = list(
        STAT_ROB = -5,
        STAT_TGH = 5,
        STAT_BIO = 10,
        STAT_MEC = -10,
        STAT_VIG = 10,
        STAT_COG = -5
    )

/datum/category_item/setup_option/background/origin/streltsy
	name = "Wandering Streltsy"
	desc = "The Streltsy are known for their actions during the corporate wars on certain worlds such as Eureka and Predstraza. Serbians know them as valuable debt settlers and an escape from the conditions of their worlds, while more civilized worlds view them as despoilers and raiders. \
			While both of these preconceptions are correct in their own right, a less known fact is that most Streltsy who've survived the corporate war are still suffering the consequences of their participation due to the decimation of their numbers during the war, leading to a miserable quality of life and forcing them to start recruitment from wartorn worlds to desperately replenish their numbers from before the war. \
			Despite this, the survivors and their newer members are unparalleled in the arts of war, but lacking in the art of general technomancy."
	stat_modifiers = list(
		STAT_ROB = 5,
		STAT_TGH = 10,
		STAT_BIO = -10,
		STAT_MEC = -5,
		STAT_VIG = 10,
		STAT_COG = -10
	)

	restricted_jobs = list(/datum/job/captain, /datum/job/hop, /datum/job/chaplain, /datum/job/merchant, /datum/job/cmo, /datum/job/rd, /datum/job/ihc)
	restricted_depts = IRONHAMMER | MEDICAL | SCIENCE | CHURCH | GUILD | CIVILIAN | SERVICE

/datum/category_item/setup_option/background/origin/ihmaids
	name = "Ironhammer M.A.I.D.S Corps"
	desc = "The Ironhammer Medical, Acquisition, Industrial Design and Security Corps are normally posted to construction work of particular importance to Ironhammer assets, such as fortifications or barracks for the garrisons on the way to the null sector, along with triage work for when an accident inevitably happens at those garrisons. \
			At other times, they're assigned to Ironhammer security teams on exploratory missions into the null sector due to their prowess as construction specialists and medics."

	stat_modifiers = list(
		STAT_ROB = -10,
		STAT_TGH = -5,
		STAT_BIO = 10,
		STAT_MEC = 10,
		STAT_VIG = -10,
		STAT_COG = 10
	)
	restricted_jobs = list(/datum/job/captain, /datum/job/hop, /datum/job/chaplain, /datum/job/merchant, /datum/job/cmo, /datum/job/rd, /datum/job/chief_engineer)
	restricted_depts = ENGINEERING | MEDICAL | SCIENCE | CHURCH | GUILD | CIVILIAN | SERVICE
