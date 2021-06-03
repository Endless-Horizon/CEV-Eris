GLOBAL_LIST_INIT(greek_letters, list("Alpha", "Beta", "Gamma", "Delta",
	"Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu",
	"Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi",
	"Chi", "Psi", "Omega"))

GLOBAL_LIST_INIT(phonetic_alphabet, list("Alpha", "Bravo", "Charlie",
	"Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet",
	"Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec",
	"Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray",
	"Yankee", "Zulu"))

GLOBAL_LIST_INIT(music_tracks, list(
	"Comet Halley" = /music_track/comet_haley,
	"Please Come Back Any Time" = /music_track/elevator,
	"Marhaba" = /music_track/marhaba,
	"In Orbit" = /music_track/inorbit,
	"Martian Cowboy" = /music_track/martiancowboy,
	"Monument" = /music_track/monument,
	"As Far As It Gets" = /music_track/asfarasitgets,
	"80s All Over Again" = /music_track/eighties,
	"Wild Encounters" = /music_track/wildencounters,
	"Metropolis" = /music_track/metropolis,
	"Bluespace" = /music_track/bluespace,
	"Exploring" = /music_track/exploring,
	"The Runner in Motion" = /music_track/runner,
	"Neotheology" = /music_track/neotheology,
	"Downtown 2" = /music_track/downtown
))

/proc/setup_music_tracks(var/list/tracks)
	. = list()
	var/track_list = LAZYLEN(tracks) ? tracks : GLOB.music_tracks
	for(var/track_name in track_list)
		var/track_path = track_list[track_name]
		. += new/datum/track(track_name, track_path)
