//config files
#define CONFIG_GET(X) global.config_tg.Get(/datum/config_entry/##X)
#define CONFIG_SET(X, Y) global.config_tg.Set(/datum/config_entry/##X, ##Y)

#define CONFIG_MAPS_FILE "maps.txt"

//flags
/// can't edit
#define CONFIG_ENTRY_LOCKED 1
/// can't see value
#define CONFIG_ENTRY_HIDDEN 2
