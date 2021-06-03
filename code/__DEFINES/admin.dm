// A set of constants used to determine which type of mute an admin wishes to apply.
// Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO, etc. = (MUTE_IC << 1)
// Therefore there needs to be a gap between the flags for the automute flags.
#define MUTE_IC        0x1
#define MUTE_OOC       0x2
#define MUTE_PRAY      0x4
#define MUTE_ADMINHELP 0x8
#define MUTE_DEADCHAT  0x10
#define MUTE_ALL       0xFFFF

// Number of identical messages required to get the spam-prevention auto-mute thing to trigger warnings and automutes.
#define SPAM_TRIGGER_WARNING  5
#define SPAM_TRIGGER_AUTOMUTE 10

// Some constants for DB_Ban
#define BANTYPE_PERMA       1
#define BANTYPE_TEMP        2
#define BANTYPE_JOB_PERMA   3
#define BANTYPE_JOB_TEMP    4
#define BANTYPE_ANY_FULLBAN 5 // Used to locate stuff to unban.

#define ROUNDSTART_LOGOUT_REPORT_TIME 6000 // Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

// Admin permissions.
#define R_FUN           0x1
#define R_SERVER        0x2
#define R_DEBUG         0x4
#define R_PERMISSIONS   0x8
#define R_MENTOR        0x10
#define R_MOD           0x20
#define R_ADMIN         0x40

// Host permission (sum of all permissions above) is equal to 127 or 0x7F
#define R_HOST 0x7F // Used for debug/mock only

#define R_MAXPERMISSION 0x40 // This holds the maximum value for a permission. It is used in iteration, so keep it updated.

#define ADMIN_VERB_ADD(path, rights, keep)\
	world/registrate_verbs() {..(); cmd_registrate_verb(path, rights, keep);}

#define ADMIN_QUE(user) "(<a href='?_src_=holder;adminmoreinfo=[REF(user)]'>?</a>)"
#define ADMIN_FLW(user) "(<a href='?_src_=holder;adminplayerobservefollow=[REF(user)]'>FLW</a>)"
// #define ADMIN_PP(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];adminplayeropts=[REF(user)]'>PP</a>)"
// #define ADMIN_VV(atom) "(<a href='?_src_=vars;[HrefToken(TRUE)];Vars=[REF(atom)]'>VV</a>)"
// #define ADMIN_SM(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];subtlemessage=[REF(user)]'>SM</a>)"
// #define ADMIN_TP(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];traitor=[REF(user)]'>TP</a>)"
// #define ADMIN_SP(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];skill=[REF(user)]'>SP</a>)"
// #define ADMIN_KICK(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];boot2=[REF(user)]'>KICK</a>)"
// #define ADMIN_CENTCOM_REPLY(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];CentComReply=[REF(user)]'>RPLY</a>)"
// #define ADMIN_SYNDICATE_REPLY(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];SyndicateReply=[REF(user)]'>RPLY</a>)"
// #define ADMIN_SC(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];adminspawncookie=[REF(user)]'>SC</a>)"
// #define ADMIN_SMITE(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];adminsmite=[REF(user)]'>SMITE</a>)"
#define ADMIN_LOOKUP(user) "[key_name_admin(user)][ADMIN_QUE(user)]"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
// #define ADMIN_SET_SD_CODE "(<a href='?_src_=holder;[HrefToken(TRUE)];set_selfdestruct_code=1'>SETCODE</a>)"
// #define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_SM(user)] [ADMIN_FLW(user)] [ADMIN_TP(user)] [ADMIN_INDIVIDUALLOG(user)] [ADMIN_SMITE(user)]"
// #define ADMIN_FULLMONTY(user) "[key_name_admin(user)] [ADMIN_FULLMONTY_NONAME(user)]"
#define ADMIN_JMP(src) "(<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define COORD(src) "[src ? src.Admin_Coordinates_Readable() : "nonexistent location"]"
#define AREACOORD(src) "[src ? src.Admin_Coordinates_Readable(TRUE) : "nonexistent location"]"
#define ADMIN_COORDJMP(src) "[src ? src.Admin_Coordinates_Readable(FALSE, TRUE) : "nonexistent location"]"
#define ADMIN_VERBOSEJMP(src) "[src ? src.Admin_Coordinates_Readable(TRUE, TRUE) : "nonexistent location"]"
// #define ADMIN_INDIVIDUALLOG(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];individuallog=[REF(user)]'>LOGS</a>)"

/atom/proc/Admin_Coordinates_Readable(area_name, admin_jump_ref)
	var/turf/T = Safe_COORD_Location()
	return T ? "[area_name ? "[get_area_name(T)] " : " "]([T.x],[T.y],[T.z])[admin_jump_ref ? " [ADMIN_JMP(T)]" : ""]" : "nonexistent location"

/atom/proc/Safe_COORD_Location()
	var/atom/A = drop_location()
	if(!A)
		return //not a valid atom.
	var/turf/T = get_step(A, 0) //resolve where the thing is.
	if(!T) //incase it's inside a valid drop container, inside another container. ie if a mech picked up a closet and has it inside it's internal storage.
		var/atom/last_try = A.loc?.drop_location() //one last try, otherwise fuck it.
		if(last_try)
			T = get_step(last_try, 0)
	return T

/turf/Safe_COORD_Location()
	return src
