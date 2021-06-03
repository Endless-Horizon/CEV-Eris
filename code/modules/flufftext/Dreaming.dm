
var/list/dreams = list(
	"an ID card","a bottle","a familiar face","a crewmember","a toolbox","a ironhammer operative","the captain",
	"voices from all around","deep space","a doctor","the engine","a traitor","an ally","darkness",
	"light","a scientist","a monkey","a catastrophe","a loved one","a gun","warmth","freezing","the sun",
	"a hat","the Luna","a ruined station","a planet","plasma","air","the medical bay","the bridge","blinking lights",
	"a blue light","an abandoned laboratory","NanoTrasen","mercenaries","blood","healing","power","respect",
	"riches","space","a crash","happiness","pride","a fall","water","flames","ice","melons","flying","the eggs","money",
	"the First Officer","the Ironhammer Commander","a Technomancer Exultant","a Moebius Expedition Overseer","a Moebius Biolab Officer",
	"the inspector","the gunnery sergeant","a member of the internal affairs","a station engineer","the janitor","atmospheric technician",
	"the guild merchant","a guild technician","the botanist","a guild miner","the psychologist","the chemist","the geneticist",
	"the virologist","the roboticist","the chef","the bartender","the preacher","the librarian","a mouse",
	"a beach","the holodeck","a smokey room","a voice","the cold","a mouse","an operating table","the bar","the rain",
	"the ai core","the mining station","the research station","a beaker of strange liquid",
	)

/mob/living/carbon/proc/dream()
	dreaming = 1

	spawn(0)
		for(var/i = rand(1,4),i > 0, i--)
			to_chat(src, "\blue <i>... [pick(dreams)] ...</i>")
			sleep(rand(40,70))
			if(paralysis <= 0)
				dreaming = 0
				return
		dreaming = 0
		return

mob/living/carbon/proc/handle_dreams()
	if(client && !dreaming && prob(5))
		dream()

mob/living/carbon/var/dreaming = 0
