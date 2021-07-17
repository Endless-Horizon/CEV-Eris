/obj/item/clothing/head/centhat
	name = "\improper CentCom. hat"
	icon_state = "centcom"
	item_state_slots = list(
		slot_l_hand_str = "centhat",
		slot_r_hand_str = "centhat",
		)
	desc = "It's good to be emperor."
	siemens_coefficient = 0.9
	body_parts_covered = 0

/obj/item/clothing/head/hairflower
	name = "hair flower pin"
	icon_state = "hairflower"
	desc = "Smells nice."
	slot_flags = SLOT_HEAD | SLOT_EARS
	body_parts_covered = 0

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "tophat"
	siemens_coefficient = 0.9
	body_parts_covered = 0


/obj/item/clothing/head/mailman
	name = "station cap"
	icon_state = "mailman"
	desc = "<i>Choo-choo</i>!"
	body_parts_covered = 0

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	body_parts_covered = 0

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish"
	icon_state = "hasturhood"
	flags_inv = BLOCKHAIR
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	siemens_coefficient = 0.9
	body_parts_covered = 0

/obj/item/clothing/head/syndicatefake
	name = "red space-helmet replica"
	item_state_slots = list(
		slot_l_hand_str = "syndicate-helm-black-red",
		slot_r_hand_str = "syndicate-helm-black-red",
		)
	icon_state = "syndicate"
	desc = "A plastic replica of a bloodthirsty mercenary's space helmet, you'll look just like a real murderous criminal operative in this! This is a toy, it is not made for use in space!"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	siemens_coefficient = 2
	body_parts_covered = HEAD|FACE|EYES
	item_flags = COVER_PREVENT_MANIPULATION

/obj/item/clothing/head/bandana/green
	name = "green bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "greenbandana"
	item_state = "greenbandana"
	flags_inv = 0
	body_parts_covered = 0

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "fight for what's righteous!"
	icon_state = "justicered"
	flags_inv = BLOCKHAIR
	body_parts_covered = HEAD|EYES

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you looks useless, and only good for your sex appeal."
	icon_state = "bunny"
	body_parts_covered = 0

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state_slots = list(
		slot_l_hand_str = "det_hat",
		slot_r_hand_str = "det_hat",
		)
	siemens_coefficient = 0.9

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	body_parts_covered = 0

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	body_parts_covered = 0

/obj/item/clothing/head/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	flags_inv = BLOCKHEADHAIR

/obj/item/clothing/head/bowler
	name = "bowler-hat"
	desc = "Gentleman, elite aboard!"
	icon_state = "bowler"
	body_parts_covered = 0

//stylish bs12 hats

/obj/item/clothing/head/bowlerhat
	name = "bowler hat"
	icon_state = "bowler_hat"
	desc = "For the gentleman of distinction."
	body_parts_covered = 0

/obj/item/clothing/head/beaverhat
	name = "beaver hat"
	icon_state = "beaver_hat"
	desc = "Soft felt makes this hat both comfortable and elegant."

/obj/item/clothing/head/boaterhat
	name = "boater hat"
	icon_state = "boater_hat"
	desc = "The ultimate in summer fashion."

/obj/item/clothing/head/fedora
	name = "fedora"
	icon_state = "fedora"
	desc = "A sharp, stylish hat."

/obj/item/clothing/head/feathertrilby
	name = "feather trilby"
	icon_state = "feather_trilby"
	desc = "A sharp, stylish hat with a feather."

/obj/item/clothing/head/fez
	name = "fez"
	icon_state = "fez"
	desc = "You should wear a fez. Fezzes are cool."

//end bs12 hats

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	flags_inv = BLOCKHEADHAIR
	siemens_coefficient = 2

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	item_state_slots = list(
		slot_l_hand_str = "chickensuit",
		slot_r_hand_str = "chickensuit",
		)
	flags_inv = BLOCKHAIR
	siemens_coefficient = 0.7
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/head/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	flags_inv = BLOCKHEADHAIR
	siemens_coefficient = 0.7

/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	item_state_slots = list(
		slot_l_hand_str = "xenos_helm",
		slot_r_hand_str = "xenos_helm",
		)
	desc = "A helmet made out of chitinous alien hide."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	siemens_coefficient = 2
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/head/philosopher_wig
	name = "natural philosopher's wig"
	desc = "A stylish monstrosity unearthed from Earth's Renaissance period. With this most distinguish'd wig, you'll be ready for your next soiree!"
	icon_state = "philosopher_wig"
	item_state_slots = list(
		slot_l_hand_str = "pwig",
		slot_r_hand_str = "pwig",
		)
	flags_inv = BLOCKHEADHAIR
	siemens_coefficient = 2 //why is it so conductive?!
	body_parts_covered = 0

/obj/item/clothing/head/bandana/orange //themij: Taryn Kifer
	name = "orange bandana"
	desc = "An orange piece of cloth, worn on the head."
	icon_state = "orange_bandana"
	body_parts_covered = 0

/obj/item/clothing/head/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	item_flags = THICKMATERIAL
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|BLOCKHAIR
	body_parts_covered = HEAD|FACE|EARS
	siemens_coefficient = 1

/obj/item/clothing/head/beret/german
	name = "Oberth Republic beret"
	desc = "Brown beret with emblem. Material that it made of will protect against energy projectiles."
	icon_state = "germanberet"
	armor = list(
		melee = 5,
		bullet = 5,
		energy = 25,
		bomb = 0,
		bio = 0,
		rad = 0
	)

/obj/item/clothing/head/ranger
	name = "ranger hat"
	desc = "A rather generic sergeant hat. On second look it's actually a ranger hat."
	icon_state = "ranger"
	item_state = "ranger"
	price_tag = 400

/obj/item/clothing/head/inhaler
	name = "odd looking helmet"
	desc = "A confusingly complex helmet. It is capable of protecting you so it's more useful than being a simple decoration."
	icon_state = "inhaler"
	item_state = "inhaler"
	item_flags = THICKMATERIAL
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|BLOCKHAIR
	body_parts_covered = HEAD|FACE|EARS
	siemens_coefficient = 1
	price_tag = 600
	armor = list(
		melee = 20,
		bullet = 15,
		energy = 10,
		bomb = 0,
		bio = 20,
		rad = 25
	)

/obj/item/clothing/head/skull
	name = "white skull"
	desc = "This is actually a white plastic skull, don't expect much protection."
	icon_state = "skull-white"
	item_state = "skull-white"
	flags_inv = HIDEMASK|HIDEEARS|BLOCKHAIR
	body_parts_covered = HEAD|FACE|EARS
	price_tag = 300
	armor = list(
		melee = 10,
		bullet = 5,
		energy = 5,
		bomb = 0,
		bio = 0,
		rad = 0
	)

/obj/item/clothing/head/skull/black
	name = "black skull"
	desc = "This is actually a black plastic skull, don't expect much protection."
	icon_state = "skull-black"
	item_state = "skull-black"
	price_tag = 300

/obj/item/clothing/head/skull/drip
	name = "golden skull"
	desc = "This is actually a skull made of gold! How the hell did this show up here?"
	icon_state = "skull-drip"
	item_state = "skull-drip"
	spawn_blacklisted = TRUE //its 10k, also decent armour
	price_tag = 10000
	armor = list(
		melee = 30,
		bullet = 25,
		energy = 25,
		bomb = 0,
		bio = 0,
		rad = 0
	)
