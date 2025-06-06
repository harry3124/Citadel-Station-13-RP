/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *		Holiday hats
 		Crown of Wrath
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "welding", SLOT_ID_LEFT_HAND = "welding")
	materials_base = list(MAT_STEEL = 3000, MAT_GLASS = 1000)
	var/up = 0
	armor_type = /datum/armor/head/hardhat
	inv_hide_flags = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	body_cover_flags = HEAD|FACE|EYES
	item_action_name = "Flip Welding Mask"
	siemens_coefficient = 0.9
	w_class = WEIGHT_CLASS_NORMAL
	var/base_state
	flash_protection = FLASH_PROTECTION_MAJOR
	tint = TINT_HEAVY
	drop_sound = 'sound/items/drop/helm.ogg'
	pickup_sound = 'sound/items/pickup/helm.ogg'

/obj/item/clothing/head/welding/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	toggle(user)


/obj/item/clothing/head/welding/verb/toggle_verb()
	set category = VERB_CATEGORY_OBJECT
	set name = "Adjust welding mask"
	set src in usr

	toggle(usr)

/obj/item/clothing/head/welding/proc/toggle(mob/user)
	if(!base_state)
		base_state = icon_state

	if(!CHECK_MOBILITY(user, MOBILITY_CAN_USE))
		return

	if(src.up)
		src.up = !src.up
		set_body_cover_flags(body_cover_flags | (EYES|FACE))
		inv_hide_flags |= (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
		icon_state = base_state
		flash_protection = FLASH_PROTECTION_MAJOR
		tint = initial(tint)
		to_chat(usr, "You flip the [src] down to protect your eyes.")
	else
		src.up = !src.up
		set_body_cover_flags(body_cover_flags & ~(EYES|FACE))
		inv_hide_flags &= ~(HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
		icon_state = "[base_state]up"
		flash_protection = FLASH_PROTECTION_NONE
		tint = TINT_NONE
		to_chat(usr, "You push the [src] up out of your face.")
	update_worn_icon()	//so our mob-overlays
	if (ismob(src.loc)) //should allow masks to update when it is opened/closed
		var/mob/M = src.loc
		M.update_inv_wear_mask()
	update_action_buttons()

/obj/item/clothing/head/welding/demon
	name = "demonic welding helmet"
	desc = "A painted welding helmet, this one has a demonic face on it."
	icon_state = "demonwelding"
	item_state_slots = list(
		SLOT_ID_LEFT_HAND = "demonwelding",
		SLOT_ID_RIGHT_HAND = "demonwelding",
		)

/obj/item/clothing/head/welding/knight
	name = "knightly welding helmet"
	desc = "A painted welding helmet, this one looks like a knights helmet."
	icon_state = "knightwelding"
	item_state_slots = list(
		SLOT_ID_LEFT_HAND = "knightwelding",
		SLOT_ID_RIGHT_HAND = "knightwelding",
		)

/obj/item/clothing/head/welding/fancy
	name = "fancy welding helmet"
	desc = "A painted welding helmet, the black and gold make this one look very fancy."
	icon_state = "fancywelding"
	item_state_slots = list(
		SLOT_ID_LEFT_HAND = "fancywelding",
		SLOT_ID_RIGHT_HAND = "fancywelding",
		)

/obj/item/clothing/head/welding/engie
	name = "engineering welding helmet"
	desc = "A painted welding helmet, this one has been painted the engineering colours."
	icon_state = "engiewelding"
	item_state_slots = list(
		SLOT_ID_LEFT_HAND = "engiewelding",
		SLOT_ID_RIGHT_HAND = "engiewelding",
		)

/obj/item/clothing/head/welding/arar
	name = "replikant welding helmet"
	desc = "A protective welding mask designed for repair-technician replikants, the visor slits are particularly difficult to see out of."
	icon_state = "ararwelding"
	item_state_slots = list(
		SLOT_ID_LEFT_HAND = "ararwelding",
		SLOT_ID_RIGHT_HAND = "ararwelding",
		)

/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	inv_hide_flags = HIDEEARS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	cold_protection_cover = HEAD

/obj/item/clothing/head/ushanka/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		to_chat(user, "You raise the ear flaps on the ushanka.")
	else
		src.icon_state = "ushankadown"
		to_chat(user, "You lower the ear flaps on the ushanka.")

/*
 * Pumpkin head
 */
/obj/item/clothing/head/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"//Could stand to be renamed
	inv_hide_flags = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_cover_flags = HEAD|FACE|EYES
	brightness_on = 2
	light_overlay = "helmet_light"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/drop/herb.ogg'
	pickup_sound = 'sound/items/pickup/herb.ogg'

/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	body_cover_flags = 0
	siemens_coefficient = 1.5
	item_icons = list()

/obj/item/clothing/head/richard
	name = "chicken mask"
	desc = "You can hear the distant sounds of rhythmic electronica."
	icon_state = "richard"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "chickenhead", SLOT_ID_LEFT_HAND = "chickenhead")
	body_cover_flags = HEAD|FACE
	inv_hide_flags = BLOCKHAIR

/obj/item/clothing/head/santa
	name = "santa hat"
	desc = "It's a festive christmas hat, in red!"
	icon_state = "santahatnorm"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "santahat", SLOT_ID_LEFT_HAND = "santahat")
	body_cover_flags = 0

/obj/item/clothing/head/santa/green
	name = "green santa hat"
	desc = "It's a festive christmas hat, in green!"
	icon_state = "santahatgreen"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "santahatgreen", SLOT_ID_LEFT_HAND = "santahatgreen")
	body_cover_flags = 0

// Ye Olde Bloodborne Cage Helmet
/obj/item/clothing/head/cage
	name = "scholarly cage"
	desc = "An aged iron cage meant to be worn upon one's head. It relies largely on the shoulders for support. Small, dried flecks of blood have visibly gathered in some of the recesses."
	icon = 'icons/clothing/head/cage_32x48.dmi'
	icon_state = "cage"
	body_cover_flags = HEAD
	w_class = WEIGHT_CLASS_NORMAL
	worn_render_flags = WORN_RENDER_SLOT_ONE_FOR_ALL

/*
 * Xenoarch/Surface Loot Hats
 */

// Triggers an effect when the wearer is 'in grave danger'.
// Causes brainloss when it happens.
/obj/item/clothing/head/psy_crown
	name = "broken crown"
	desc = "A crown-of-thorns with a missing gem."
	var/tension_threshold = 125
	var/cooldown = null // world.time of when this was last triggered.
	var/cooldown_duration = 3 MINUTES // How long the cooldown should be.
	var/flavor_equip = null // Message displayed to someone who puts this on their head. Drones don't get a message.
	var/flavor_unequip = null // Ditto, but for taking it off.
	var/flavor_drop = null // Ditto, but for dropping it.
	var/flavor_activate = null // Ditto, for but activating.
	var/brainloss_cost = 3 // Whenever it activates, inflict this much brainloss on the wearer, as its not good for the mind to wear things that manipulate it.

/obj/item/clothing/head/psy_crown/proc/activate_ability(var/mob/living/wearer)
	cooldown = world.time + cooldown_duration
	to_chat(wearer, flavor_activate)
	to_chat(wearer, "<span class='danger'>The inside of your head hurts...</span>")
	wearer.adjustBrainLoss(brainloss_cost)

/obj/item/clothing/head/psy_crown/equipped(var/mob/living/carbon/human/H)
	..()
	if(istype(H) && H.head == src && H.is_sentient())
		START_PROCESSING(SSobj, src)
		to_chat(H, flavor_equip)

/obj/item/clothing/head/psy_crown/dropped(mob/user, flags, atom/newLoc)
	..()
	STOP_PROCESSING(SSobj, src)
	var/mob/living/carbon/human/H = user
	if(!ishuman(H))
		return
	if(H.is_sentient())
		if(loc == H) // Still inhand.
			to_chat(H, flavor_unequip)
		else
			to_chat(H, flavor_drop)

/obj/item/clothing/head/psy_crown/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/head/psy_crown/process(delta_time)
	if(isliving(loc))
		var/mob/living/L = loc
		if(world.time >= cooldown && L.is_sentient() && L.get_tension() >= tension_threshold)
			activate_ability(L)


/obj/item/clothing/head/psy_crown/wrath
	name = "red crown"
	desc = "A crown-of-thorns set with a red gemstone that seems to glow unnaturally. It feels rather disturbing to touch."
	description_info = "This has a chance to cause the wearer to become extremely angry when in extreme danger."
	icon_state = "wrathcrown"
	flavor_equip = "<span class='warning'>You feel a bit angrier after putting on this crown.</span>"
	flavor_unequip = "<span class='notice'>You feel calmer after removing the crown.</span>"
	flavor_drop = "<span class='notice'>You feel much calmer after letting go of the crown.</span>"
	flavor_activate = "<span class='danger'>An otherworldly feeling seems to enter your mind, and it ignites your mind in fury!</span>"
	origin_tech = list(TECH_ARCANE = 4)

/obj/item/clothing/head/psy_crown/wrath/activate_ability(var/mob/living/wearer)
	..()
	wearer.add_modifier(/datum/modifier/berserk, 30 SECONDS)

/obj/item/clothing/head/psy_crown/gluttony
	name = "green crown"
	desc = "A crown-of-thorns set with a green gemstone that seems to glow unnaturally. It feels rather disturbing to touch."
	description_info = "This has a chance to cause the wearer to become extremely durable, but hungry when in extreme danger."
	icon_state = "gluttonycrown"
	flavor_equip = "<span class='warning'>You feel a bit hungrier after putting on this crown.</span>"
	flavor_unequip = "<span class='notice'>You feel sated after removing the crown.</span>"
	flavor_drop = "<span class='notice'>You feel much more sated after letting go of the crown.</span>"
	flavor_activate = "<span class='danger'>An otherworldly feeling seems to enter your mind, and it drives your mind into gluttony!</span>"

/obj/item/clothing/head/psy_crown/gluttony/activate_ability(var/mob/living/wearer)
	..()
	wearer.add_modifier(/datum/modifier/gluttonyregeneration, 45 SECONDS)
/obj/item/clothing/head/cone
	name = "warning cone"
	desc = "This cone is trying to warn you of something!"
	description_info = "It looks like you can wear it in your head slot."
	icon_state = "cone"
	item_state = "cone"
	body_cover_flags = HEAD
	attack_verb = list("warned", "cautioned", "smashed")
