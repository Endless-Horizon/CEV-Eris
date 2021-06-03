GLOBAL_LIST_EMPTY(all_observable_events)

//see proc/get_average_color()
GLOBAL_LIST_EMPTY(average_icon_color)

//see getFlatTypeIcon()
GLOBAL_LIST_EMPTY(initialTypeIcon)

GLOBAL_DATUM(lobbyScreen, /datum/lobbyscreen)

// WORLD TOPIC CACHING //
GLOBAL_VAR(topic_status_lastcache)
GLOBAL_LIST(topic_status_cache)

// adminbusing is allowed here, shut the fuck up
GLOBAL_VAR_INIT(internal_tick_usage, 0.2 * world.tick_lag)

GLOBAL_VAR_INIT(fallback_alerted, FALSE)
GLOBAL_PROTECT(fallback_alerted) // NO TOUCHY

GLOBAL_VAR_INIT(next_promise_id, 0)
GLOBAL_PROTECT(next_promise_id) // NO TOUCHY

// MOVE TO mob.dm in this same dir
GLOBAL_LIST_EMPTY(mob_living_list) //all instances of /mob/living and subtypes
GLOBAL_LIST_EMPTY(new_player_list) //all /mob/dead/new_player, in theory all should have clients and those that don't are in the process of spawning and get deleted when done.
GLOBAL_LIST_EMPTY(joined_player_list) //all clients that have joined the game at round-start or as a latejoin.

// MOVE TO objects.dm in the same dir
GLOBAL_LIST_EMPTY(machines)         //NOTE: this is a list of ALL machines now. The processing machines list is SSmachine.processing !
