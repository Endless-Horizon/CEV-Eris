var/list/department_radio_keys = list(
	"r" = "right ear",   "R" = "right ear",
	"l" = "left ear",    "L" = "left ear",
	"i" = "intercom",    "I" = "intercom",
	"h" = "department",  "H" = "department",
	"+" = "special",	 //activate radio-specific special functions
	"c" = "Command",     "C" = "Command",
	"n" = "Science",     "N" = "Science",
	"m" = "Medical",     "M" = "Medical",
	"e" = "Engineering", "E" = "Engineering",
	"s" = "Security",    "S" = "Security",
	"w" = "whisper",     "W" = "whisper",
	"y" = "Mercenary",   "Y" = "Mercenary",
	"u" = "Supply",      "U" = "Supply",
	"v" = "Service",     "V" = "Service",
	"p" = "AI Private",  "P" = "AI Private",
	"t" = "NT Voice",    "T" = "NT Voice",

	"к" = "right ear",   "К" = "right ear",
	"д" = "left ear",    "Д" = "left ear",
	"ш" = "intercom",    "Ш" = "intercom",
	"р" = "department",  "Р" = "department",
	"с" = "Command",     "С" = "Command",
	"т" = "Science",     "Т" = "Science",
	"ь" = "Medical",     "Ь" = "Medical",
	"у" = "Engineering", "У" = "Engineering",
	"ы" = "Security",    "Ы" = "Security",
	"ц" = "whisper",     "Ц" = "whisper",
	"н" = "Mercenary",   "Н" = "Mercenary",
	"г" = "Supply",      "Г" = "Supply",
	"м" = "Service",     "М" = "Service",
	"з" = "AI Private",  "З" = "AI Private",
	"е" = "NT Voice",    "Е" = "NT Voice",
)


var/list/channel_to_radio_key = new
/proc/get_radio_key_from_channel(var/channel)
	var/key = channel_to_radio_key[channel]
	if(!key)
		for(var/radio_key in department_radio_keys)
			if(department_radio_keys[radio_key] == channel)
				key = radio_key
				break
		if(!key)
			key = ""
		channel_to_radio_key[channel] = key

	return key

/mob/living/proc/binarycheck()

	if(istype(src, /mob/living/silicon/pai))
		return

	if(!ishuman(src))
		return

	var/mob/living/carbon/human/H = src
	if(H.l_ear || H.r_ear)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.l_ear, /obj/item/device/radio/headset))
			dongle = H.l_ear
		else
			dongle = H.r_ear
		if(!istype(dongle))
			return FALSE
		if(dongle.translate_binary)
			return TRUE

/mob/living/proc/get_default_language()
	return default_language

/mob/living/proc/is_muzzled()
	return 0

/mob/living/proc/handle_speech_problems(var/message, var/verb)
	var/list/returns[3]
	var/speech_problem_flag = 0

	if((HULK in mutations) && health >= 25 && length(message))
		message = "[uppertext(message)]!!!"
		verb = pick("yells", "roars", "hollers")
		speech_problem_flag = 1
	if(slurring)
		message = slur(message)
		verb = pick("slobbers", "slurs")
		speech_problem_flag = 1
	if(stuttering)
		message = stutter(message)
		verb = pick("stammers", "stutters")
		speech_problem_flag = 1

	returns[1] = message
	returns[2] = verb
	returns[3] = speech_problem_flag
	return returns

/mob/living/proc/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name, speech_volume)
	if(message_mode == "intercom")
		for(var/obj/item/device/radio/intercom/I in view(1, null))
			I.talk_into(src, message, verb, speaking, speech_volume)
			used_radios += I
	return 0

/mob/living/proc/handle_speech_sound()
	var/list/returns[2]
	returns[1] = null
	returns[2] = null
	return returns

/mob/living/proc/get_speech_ending(verb, var/ending)
	if(ending=="!")
		return pick("exclaims", "shouts", "yells")
	if(ending=="?")
		return "asks"
	return verb

// returns message
/mob/living/proc/getSpeechVolume(var/message)
	var/volume = chem_effects[CE_SPEECH_VOLUME] ? round(chem_effects[CE_SPEECH_VOLUME]) : 2	// 2 is default text size in byond chat
	var/ending = copytext(message, length(message))
	if(ending == "!")
		volume ++
	return volume

/mob/living/say(var/message, var/datum/language/speaking = null, var/verb="says", var/alt_name="")
	if(client)
		if(client.prefs.muted&MUTE_IC)
			to_chat(src, "\red You cannot speak in IC (Muted).")
			return

	if(stat)
		if(stat == DEAD)
			return say_dead(message)
		return

	if(GLOB.in_character_filter.len)
		if(findtext(message, config.ic_filter_regex))
			// let's try to be a bit more informative!
			var/warning_message = "A splitting spike of headache prevents you from saying whatever vile words you planned to say! You think better of saying such nonsense again. The following terms break the atmosphere and are not allowed: &quot;"
			var/list/words = splittext(message, " ")
			var/cringe = ""
			for (var/word in words)
				if (findtext(word, config.ic_filter_regex))
					warning_message = "[warning_message]<b>[word]</b> "
					cringe += "/<b>[word]</b>"
				else
					warning_message = "[warning_message][word] "


			warning_message = trim(warning_message)
			to_chat(src, SPAN_WARNING("[warning_message]&quot;"))
			//log_and_message_admins("[src] just tried to say cringe: [cringe]", src) //Uncomment this if you want to keep tabs on who's saying cringe words.
			return

	if(HUSK in mutations)
		return

	if(is_muzzled())
		to_chat(src, SPAN_DANGER("You're muzzled and cannot speak!"))
		return

	var/prefix = copytext(message,1,2)
	if(prefix == get_prefix_key(/decl/prefix/custom_emote))
		return emote(copytext(message,2))
	if(prefix == get_prefix_key(/decl/prefix/visible_emote))
		return custom_emote(1, copytext(message,2))

	//parse the radio code and consume it
	var/message_mode = parse_message_mode(message, "headset")
	if (message_mode)
		if (message_mode == "headset")
			message = copytext(message,2)//parse ;
		else
			message = copytext_char(message,3)//parse :s

	message = trim_left(message)

	//parse the language code and consume it
	if(!speaking)
		speaking = parse_language(message)
	if(speaking)
		message = copytext(message, 2 + length(speaking.key))
	else
		speaking = get_default_language()

	message = capitalize(message)
	// This is broadcast to all mobs with the language,
	// irrespective of distance or anything else.
	if(speaking && speaking.flags&HIVEMIND)
		speaking.broadcast(src, trim(message))
		return 1

	verb = say_quote(message, speaking)

	message = trim_left(message)
	var/message_pre_stutter = message
	if(!(speaking && speaking.flags&NO_STUTTER))

		var/list/handle_s = handle_speech_problems(message, verb)
		message = handle_s[1]
		verb = handle_s[2]

	if(!message)
		return 0

	var/list/obj/item/used_radios = new


	if(handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name, getSpeechVolume(message)))
		return TRUE

	var/list/handle_v = handle_speech_sound()
	var/sound/speech_sound = handle_v[1]
	var/sound_vol = handle_v[2] * (chem_effects[CE_SPEECH_VOLUME] ? chem_effects[CE_SPEECH_VOLUME] : 1)

	var/italics = FALSE
	var/message_range = world.view
	//speaking into radios
	if(used_radios.len)
		italics = TRUE
		message_range = 1
		if(speaking)
			message_range = speaking.get_talkinto_msg_range(message)
		var/msg
		if(!speaking || !(speaking.flags&NO_TALK_MSG))
			msg = SPAN_NOTICE("\The [src] talks into \the [used_radios[1]]")
		for(var/mob/living/M in hearers(5, src))
			if((M != src) && msg)
				M.show_message(msg)
			if(speech_sound)
				sound_vol *= 0.5

	var/turf/T = get_turf(src)

	//handle nonverbal and sign languages here
	if(speaking)
		if(speaking.flags&NONVERBAL)
			if(prob(30))
				src.custom_emote(1, "[pick(speaking.signlang_verb)].")

		if(speaking.flags&SIGNLANG)
			return say_signlang(message, pick(speaking.signlang_verb), speaking)

	var/list/listening = list()
	var/list/listening_obj = list()
	var/list/listening_falloff = list() //People that are quite far away from the person speaking, who just get a _quiet_ version of whatever's being said.

	if(T)
		//make sure the air can transmit speech - speaker's side
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = (environment) ? environment.return_pressure() : 0
		if(pressure < SOUND_MINIMUM_PRESSURE)
			message_range = 1

		//sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
		if(pressure < ONE_ATMOSPHERE * 0.4)
			italics = TRUE
			sound_vol *= 0.5 //muffle the sound a bit, so it's like we're actually talking through contact
		var/falloff = (message_range + round(3 * (chem_effects[CE_SPEECH_VOLUME] ? chem_effects[CE_SPEECH_VOLUME] : 1))) //A wider radius where you're heard, but only quietly. This means you can hear people offscreen.
		//DO NOT FUCKING CHANGE THIS TO GET_OBJ_OR_MOB_AND_BULLSHIT() -- Hugs and Kisses ~Ccomp
		var/list/hear = hear(message_range, T)
		var/list/hear_falloff = hear(falloff, T)

		for(var/X in GLOB.player_list)
			if(!ismob(X))
				continue
			var/mob/M = X
			if(QDELETED(M)) //Some times nulls and deleteds stay in this list. This is a workaround to prevent ic chat breaking for everyone when they do.
				continue //Remove if underlying cause (likely byond issue) is fixed. See TG PR #49004.
			if(M.stat == DEAD && M.get_preference_value(/datum/client_preference/ghost_ears) == GLOB.PREF_ALL_SPEECH)
				listening |= M
				continue
			if(M.locs.len && (M.locs[1] in hear))
				listening |= M
				continue //To avoid seeing BOTH normal message and quiet message
			else if(M.locs.len && (M.locs[1] in hear_falloff))
				listening_falloff |= M

		for(var/obj in GLOB.hearing_objects)
			if(get_turf(obj) in hear)
				listening_obj |= obj

	var/speech_bubble_test = say_test(message)
	var/image/speech_bubble = image('icons/mob/talk.dmi', src, "h[speech_bubble_test]")
	speech_bubble.layer = ABOVE_MOB_LAYER
	QDEL_IN(speech_bubble, 30)

	var/list/speech_bubble_recipients = list()
	for(var/X in listening) //Again, as we're dealing with a lot of mobs, typeless gives us a tangible speed boost.
		if(!ismob(X))
			continue
		var/mob/M = X
		if(M.client)
			speech_bubble_recipients += M.client
		M.hear_say(message, verb, speaking, alt_name, italics, src, speech_sound, sound_vol, getSpeechVolume(message))
	for(var/X in listening_falloff)
		if(!ismob(X))
			continue
		var/mob/M = X
		if(M.client)
			speech_bubble_recipients += M.client
		M.hear_say(message, verb, speaking, alt_name, italics, src, speech_sound, sound_vol, 1)

	INVOKE_ASYNC(GLOBAL_PROC, .proc/animate_speechbubble, speech_bubble, speech_bubble_recipients, 30)
	INVOKE_ASYNC(src, /atom/movable/proc/animate_chat, message, speaking, italics, speech_bubble_recipients, 40)

	for(var/obj/O in listening_obj)
		spawn(0)
			if(!QDELETED(O)) //It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message, verb, speaking, getSpeechVolume(message), message_pre_stutter)


	log_say("[name]/[key] : [message]")
	return TRUE


/proc/animate_speechbubble(image/I, list/show_to, duration)
	var/matrix/M = matrix()
	M.Scale(0,0)
	I.transform = M
	I.alpha = 0
	for(var/client/C in show_to)
		C.images += I
	animate(I, transform = 0, alpha = 255, time = 5, easing = ELASTIC_EASING)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/fade_speechbubble, I), duration-5)

/proc/fade_speechbubble(image/I)
	animate(I, alpha = 0, time = 5, easing = EASE_IN)


/mob/living/proc/say_signlang(var/message, var/verb="gestures", var/datum/language/language)
	for (var/mob/O in viewers(src, null))
		O.hear_signlang(message, verb, language, src)
	return 1

/obj/effect/speech_bubble
	var/mob/parent

/mob/living/proc/GetVoice()
	return name

/mob/living/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = FALSE,\
		mob/speaker = null, speech_sound, sound_vol, speech_volume)
	if(!client)
		return

	if((sdisabilities & DEAF) || ear_deaf)
		// INNATE is the flag for audible-emote-language, so we don't want to show an "x talks but you cannot hear them" message if it's set
		if(!language || !(language.flags & INNATE))
			if(speaker == src)
				to_chat(src, SPAN_WARNING("You cannot hear yourself speak!"))
			else
				var/speaker_name = speaker.name
				if(ishuman(speaker))
					var/mob/living/carbon/human/H = speaker
					speaker_name = H.rank_prefix_name(speaker_name)
				to_chat(src,"<span class='name'>[speaker_name]</span>[alt_name] talks but you cannot hear \him.")
		return

	//make sure the air can transmit speech - hearer's side
	var/turf/T = get_turf(src)
	if(T)
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = (environment) ? environment.return_pressure() : 0
		if(pressure < SOUND_MINIMUM_PRESSURE && get_dist(speaker, src) > 1)
			return

		//sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
		if(pressure < ONE_ATMOSPHERE * 0.4)
			italics = TRUE
			sound_vol *= 0.5 //muffle the sound a bit, so it's like we're actually talking through contact

	if(sleeping || stat == UNCONSCIOUS)
		hear_sleep(message)
		return

	//non-verbal languages are garbled if you can't see the speaker. Yes, this includes if they are inside a closet.
	if(language)
		if(language.flags&NONVERBAL)
			if(!speaker || (src.sdisabilities&BLIND || src.blinded) || !(speaker in view(src)))
				message = stars(message)

	if(!(language && language.flags&INNATE)) // skip understanding checks for INNATE languages
		if(!say_understands(speaker, language))
			if(isanimal(speaker))
				var/mob/living/simple_animal/S = speaker
				if(S.speak.len)
					message = pick(S.speak)
			else
				if(language)
					message = language.scramble(message)
				else
					message = stars(message)

	..()


/mob/living/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, speaker = null, hard_to_hear = 0, voice_name ="")
	if(!client)
		return

	if(sdisabilities&DEAF || ear_deaf)
		if(prob(20))
			to_chat(src, SPAN_WARNING("You feel your headset vibrate but can hear nothing from it!"))
		return

	if(sleeping || stat == UNCONSCIOUS) //If unconscious or sleeping
		hear_sleep(message)
		return

	//non-verbal languages are garbled if you can't see the speaker. Yes, this includes if they are inside a closet.
	if(language && language.flags&NONVERBAL)
		if(!speaker || (src.sdisabilities&BLIND || src.blinded) || !(speaker in view(src)))
			message = stars(message)

	// skip understanding checks for INNATE languages
	if(!(language && language.flags&INNATE))
		if(!say_understands(speaker, language))
			if(isanimal(speaker))
				var/mob/living/simple_animal/S = speaker
				if(S.speak && S.speak.len)
					message = pick(S.speak)
				else
					return
			else
				if(language)
					message = language.scramble(message)
				else
					message = stars(message)

		if(hard_to_hear)
			message = stars(message)

	..()

/mob/living/proc/hear_sleep(var/message)
	var/heard = ""
	if(prob(15))
		var/list/punctuation = list(",", "!", ".", ";", "?")
		var/list/messages = splittext(message, " ")
		var/R = rand(1, messages.len)
		var/heardword = messages[R]
		if(copytext(heardword, 1, 1) in punctuation)
			heardword = copytext(heardword, 2)
		if(copytext(heardword, -1) in punctuation)
			heardword = copytext(heardword, 1, length(heardword))
		heard = "<span class = 'game_say'>...You hear something about...[heardword]</span>"

	else
		heard = "<span class = 'game_say'>...<i>You almost hear someone talking</i>...</span>"

	to_chat(src, heard)
