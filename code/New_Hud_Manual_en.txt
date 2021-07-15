//existing overlays: flash, pain, blind, damageoverlay, blurry, druggy, nvg, thermal, meson, science
Used global variables:
GLOB.HUDdatums - here datums with subtype /datum/hud are contained, using association datum's name = datum itself

________________________________________________________________________________________________________________________
Datum /datum/hud
This datum contains information about HUD: name, elements etc.


name - datum's name
list/HUDneed - a list of necessary elements (e.g. healthbar). Using this list mob's HUDneed and HUDprocess is filling
list/slot_data - a list of inventory elements. Using this list mob's HUDinventory is filling
icon/icon - used dmi file
HUDfrippery - a list of HUD frippery. Using this list mob's HUDfrippery is filling
HUDoverlays - a list of "technical" elements. Using this list mob's HUDtech is filling and mob's HUDprocess is complemented
ConteinerData - information for functions /obj/item/storage/proc/space_orient_objs and /obj/item/storage/proc/slot_orient_objs.
IconUnderlays - a list of underlays for HUD's elements via "max" version. May be empty.
MinStyleFlag - a flag, which denotes if a HUD's type has "min" version. Take the values 1 or 0

An example of element in HUDneed list:
"health"      = list("type" = /obj/screen/health, "loc" = "16,6", "minloc" = "15,7", "background" = "back1"),

Description of the entered data:
"health" - HUD's name and ID
"type" - HUD's type, needed in order that system know what to create exactly
"loc" - position on a screen in a "max" version
"minloc" - position on a screen in a "min". Optional. used if MinStyleFlag = 1
"background" - underlay used in the "max" version. Name is taken from IconUnderlays. Optional.

An example of element in HUDoverlays list:
"damageoverlay" = list("type" = /obj/screen/damageoverlay, "loc" = "1,1", "icon" =  'icons/mob/screen1_full.dmi'),

Description of the entered data:
"damageoverlay" - HUD's name and ID
"type" - HUD's type, needed in order that system know what to create exactly
"loc" - position on a screen
"icon" - used dmi file, rewrites icon of a datum. Optional.

An example of element in slot_data list:
"Uniform" =   list("loc" = "2,1","minloc" = "1,2", "state" = "center",  "hideflag" = TOGGLE_INVENTORY_FLAG, "background" = "back1"),

Description of entered data:
"Uniform" - slot's name
"loc" - position on a screen in a "max" version
"minloc" position on a screen in a "min". Optional. used if MinStyleFlag = 1
"hideflag" - used for functions that hides HUD's elements, such as /obj/screen/toggle_invetory/proc/hideobjects(), /mob/verb/button_pressed_F12 (does not work). Optional.
"background" - underlay used in the "max" version. Name is taken from IconUnderlays. Optional.

An example of element in HUDfrippery list
list("loc" = "1,1", "icon_state" = "frame2-2",  "hideflag" = TOGGLE_INVENTORY_FLAG),

Description of entered data:
"loc" - position on a screen in a "max" version
"icon_state" - icon, which is taken from dmi file
"hideflag" - used for functions that hides HUD's elements, such as /obj/screen/toggle_invetory/proc/hideobjects(), /mob/verb/button_pressed_F12 (does not work). Optional.

________________________________________________________________________________________________________________________
Description of objects for HUD

General type: /obj/screen

Used unique variables:
	var/mob/living/parentmob - mob to which HUD is tied
	var/process_flag = 0 - flag of necessity call subprogram process()

Used subprograms:
/Click() - for elements which works by clicking on them
/process() - for elements that do something constantly (generally on call mob's life).

________________________________________________________________________________________________________________________
Datum /datum/species

Used unique variables:
var/datum/hud_data/hud - here contains a link for datum with subtype /datum/hud_data
var/hud_type - here contains datum type /datum/hud_data for race

________________________________________________________________________________________________________________________
Datum /datum/hud_data

Used unique variables:
	var/list/ProcessHUD - in this list "names" of HUD elements are introducted for initialization.
	Example: "health"

	var/list/gear - a list for HUD elements of inventory, slot's "name" is used with association.
	Example: "i_clothing" =   slot_w_uniform,
________________________________________________________________________________________________________________________
Used variables at mob's level
/mob/living
	var/list/HUDneed - a list of HUD elements for displaying on screen
	var/list/HUDinventory -  a list of HUD elements, which are the "inventory" of a mob, for displaying on screen
	var/list/HUDfrippery - a list of all the frippery (e.g. frame)
	var/list/HUDprocess -  a list of HUD elements, which process() is needed to be called
	var/list/HUDtech - a list of HUD elements, which are "technical" (e.g. layer for mob's blindness), for displaying on screen
	var/defaultHUD - default HUD name which is used by mob

________________________________________________________________________________________________________________________
Used subprograms at mob's level
/mob/proc/create_HUD() - subprogram for creating HUD elements
/mob/living/proc/destroy_HUD() - subprogram for destroying HUD elements
/mob/living/proc/show_HUD() - subprogram for displaying HUD elements at client's

/mob/living/proc/check_HUD() - basic subprogram which analyzes "correctness" of a HUD, and create/display elements on screen
/mob/living/proc/check_HUDdatum() - checks current mob's datum for correctness, returns 1, if all is correct, or 0 in any other case
/mob/living/proc/check_HUDinventory() - checks mob's variable HUDinventory for correctness, returns 1, if all is correct, or 0 in any other case. (does not use, but exists)
/mob/living/proc/check_HUDneed() - checks mob's variable HUDneed for correctness, returns 1, if all is correct, or 0 in any other case. (does not use, but exists)
/mob/living/proc/check_HUDfrippery() - checks mob's variable HUDfrippery for correctness, returns 1, if all is correct, or 0 in any other case. (does not use, but exists)
/mob/living/proc/check_HUDprocess() - checks mob's variable HUDprocess for correctness, returns 1, if all is correct, or 0 in any other case. (does not use, but exists)
/mob/living/proc/check_HUDtech() - checks mob's variable HUDtech for correctness, returns 1, if all is correct, or 0 in any other case. (does not use, but exists)

The following subprograms creates elements in the corresponding arrays
/mob/living/proc/create_HUDinventory() - in mob's HUDinventory
/mob/living/proc/create_HUDneed() - in mob's HUDneed
/mob/living/proc/create_HUDfrippery() - in mob's HUDfrippery
/mob/living/proc/create_HUDprocess() - in mob's HUDprocess
/mob/living/proc/create_HUDtech() - in mob's HUDtech

________________________________________________________________________________________________________________________
How does this work



________________________________________________________________________________________________________________________
An agreement for single style

1) By rewriting the code for mob's suptype features, create new file with the naming "[type_name]_hud". E.g. human_hud.dm, robot_hud.dm.
2) By creating new subprogram for work with the system, write its naming ang add in the end _HUD. E.g. create_HUD(), show_HUD().
2.1) By working with variables, add variable's naming. E.g. check_HUDfrippery()
3) By rewriting the code for features of subtype /obj/screen, create new file with the naming "[HUDname]_screen_object",
if you are creating elements for "race", create file with naming "[species_name]_[HUDname]_screen_object".
NOTE: "screen_object.dmi" contains "base" code.
4)All subprograms which are responsible for checking smth (check_HUDdatum(), check_HUDinventory() etc.) should not contain code which does not related with checking,
e.g warning output. Subprograms which are responsible for checking must give the check result.