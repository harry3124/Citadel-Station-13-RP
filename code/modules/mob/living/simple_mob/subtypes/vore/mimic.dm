/datum/category_item/catalogue/fauna/mimic
	name = "Aberration - Mimic"
	desc = "A being that seems to take the form of a crates, closets, doors and even the floor as a means of camouflage. \
	It seems to lie in wait for it's prey, and then pounce once the unsuspecting person attempts to open it or steps on it. \
	They are comfortable in near all enviroments and its natural camouflage abilities has allowed it to infiltrate starships \
	spreading across the wider galaxy from an unknown origin world. These methods are so effective that the species has spread \
	across the galaxy becoming a ubiquitous but dangerous pest species."
	value = CATALOGUER_REWARD_HARD

/obj/structure/closet/crate/mimic
	name = "old crate"
	desc = "A rectangular steel crate. This one looks particularly unstable."
	icon = 'icons/mob/mimic.dmi'
	icon_state = "mimic"
	icon_opened = "open"
	icon_closed = "mimic"
	closet_appearance = /singleton/closet_appearance/crate
	var/mimic_chance = 30
	var/mimic_active = TRUE

	catalogue_data = list(/datum/category_item/catalogue/fauna/mimic)

/obj/structure/closet/crate/mimic/open()
	if(src.opened)
		return 0
	if(!src.can_open())
		return 0

	if(mimic_active)
		mimic_active = FALSE
		if(prob(mimic_chance))
			var/mob/living/simple_mob/vore/aggressive/mimic/new_mimic = new(loc, src)
			visible_message("<font color='red'><b>The [new_mimic] suddenly growls as it turns out to be a mimic!</b></font>") //Controls the vars of the mimic that spawns
			forceMove(new_mimic)
			new_mimic.real_crate = src
			new_mimic.name = name
			new_mimic.desc = desc
			new_mimic.icon = 'icons/mob/mimic.dmi'
			new_mimic.icon_state = "mimicopen"
			new_mimic.icon_living = "mimicopen"
		else
			return ..()
	else
		return ..()

/obj/structure/closet/crate/mimic/safe
	mimic_chance = 0
	mimic_active = FALSE

/obj/structure/closet/crate/mimic/guaranteed
	mimic_chance = 100

/obj/structure/closet/crate/mimic/dangerous
	mimic_chance = 70

/obj/structure/closet/crate/mimic/cointoss
	mimic_chance = 50

/mob/living/simple_mob/vore/aggressive/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon_state = "mimicopen"
	icon_living = "mimicopen"
	icon = 'icons/mob/animal.dmi'

	iff_factions = MOB_IFF_FACTION_CHIMERIC

	maxHealth = 125
	health = 125
	movement_base_speed = 10 / 7

	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"

	legacy_melee_damage_lower = 7
	legacy_melee_damage_upper = 15
	attacktext = list("attacked")
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	ai_holder_type = /datum/ai_holder/polaris/mimic

	var/obj/structure/closet/crate/real_crate

	var/knockdown_chance = 10 //Stubbing your toe on furniture hurts.

	showvoreprefs = 0 //Hides mechanical vore prefs for mimics. You can't see their gaping maws when they're just sitting idle.

/mob/living/simple_mob/vore/aggressive/mimic
	swallowTime = 3 SECONDS

/datum/ai_holder/polaris/mimic
	wander = FALSE
	hostile = TRUE

/mob/living/simple_mob/vore/aggressive/mimic/apply_melee_effects(var/atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(prob(knockdown_chance))
			L.afflict_paralyze(20 * 3)
			L.visible_message(SPAN_DANGER("\The [src] knocks down \the [L]!"))

/mob/living/simple_mob/vore/aggressive/mimic/will_show_tooltip()
	return FALSE

/mob/living/simple_mob/vore/aggressive/mimic/death()
	..()
	if(real_crate)
		real_crate.forceMove(loc)
	real_crate = null
	qdel(src)

//NEW AND TERRIFYING AIRLOCK MIMIC

/obj/structure/closet/crate/mimic/airlock
	name = "Dusty Airlock"
	desc = "It opens and closes. Though it appears it has been a while since it opened."
	icon_state = "amimic"
	icon_opened = "amimicopen"
	icon_closed = "amimic"
	mimic_chance = 30
	anchored = 1 //You will not be able to push back the airlock mimic
	density = 1
	opacity = 1
	closet_appearance = null

/obj/structure/closet/crate/mimic/airlock/open()
	if(src.opened)
		return 0
	if(!src.can_open())
		return 0

	if(mimic_active)
		mimic_active = FALSE
		if(prob(mimic_chance))
			var/mob/living/simple_mob/vore/aggressive/mimic/airlock/new_mimic = new(loc, src)
			visible_message("<font color='red'><b>The [new_mimic] suddenly growls as it turns out to be a mimic!</b></font>") //Controls the vars of the mimic that spawns
			forceMove(new_mimic)
			new_mimic.real_crate = src
			new_mimic.name = name
			new_mimic.desc = desc
			new_mimic.icon = icon
			new_mimic.icon_state = "amimicopen"
			new_mimic.icon_living = "amimicopen"
		else
			qdel(src.loc)
			new/obj/machinery/door/airlock/maintenance/common (src.loc) //Places the Airlock
			qdel(src)//Deletes the "mimic"
			return ..()
	else
		return ..()

/obj/structure/closet/crate/mimic/airlock/safe
	mimic_chance = 0

/obj/structure/closet/crate/mimic/airlock/guaranteed
	mimic_chance = 100

/obj/structure/closet/crate/mimic/airlock/dangerous
	mimic_chance = 70

/obj/structure/closet/crate/mimic/airlock/cointoss
	mimic_chance = 50

/mob/living/simple_mob/vore/aggressive/mimic/airlock
	name = "Maintnence Access"
	desc = "It opens and closes."
	icon_state = "amimicopen"
	icon_living = "amimicopen"

	maxHealth = 250
	health = 250
	movement_base_speed = 10 / 10

	legacy_melee_damage_lower = 15
	legacy_melee_damage_upper = 30
	attack_armor_pen = 50 //Its jaw is an airlock. Its got enough bite strength.

	armor_legacy_mob = list(
				"melee" = 70,
				"bullet" = 30,
				"laser" = 30,
				"energy" = 30,
				"bomb" = 10,
				"bio" = 100,
				"rad" = 100) //Its an airlock.

/mob/living/simple_mob/vore/aggressive/mimic/airlock/will_show_tooltip()
	return FALSE

/mob/living/simple_mob/vore/aggressive/mimic/airlock/death()
	new/obj/machinery/door/airlock/maintenance/common (src.loc)
	real_crate = null
	qdel(src)


//Less Terrifying Closet Mimic
/obj/structure/closet/crate/mimic/closet
	name = "old closet"
	desc = "It's a basic storage unit. It seems awfully rickety."
	icon_state = "cmimic"
	closet_appearance = /singleton/closet_appearance
	mimic_chance = 30
	mimic_active = TRUE

/obj/structure/closet/crate/mimic/closet/open()
	if(src.opened)
		return 0
	if(!src.can_open())
		return 0

	if(mimic_active)
		mimic_active = FALSE
		if(prob(mimic_chance))
			var/mob/living/simple_mob/vore/aggressive/mimic/closet/new_mimic = new(loc, src)
			visible_message("<font color='red'><b>The [new_mimic] suddenly growls as it turns out to be a mimic!</b></font>") //Controls the mimic that spawns
			forceMove(new_mimic)
			new_mimic.real_crate = src
			new_mimic.name = name
			new_mimic.desc = desc
			new_mimic.icon = 'icons/mob/animal.dmi'
			new_mimic.icon_state = "cmimicopen"
			new_mimic.icon_living = "cmimicopen"
		else
			return ..()
	else
		return ..()

/obj/structure/closet/crate/mimic/closet/safe
	mimic_chance = 0
	mimic_active = FALSE

/obj/structure/closet/crate/mimic/closet/guaranteed
	mimic_chance = 100

/obj/structure/closet/crate/mimic/closet/dangerous
	mimic_chance = 70

/obj/structure/closet/crate/mimic/closet/cointoss
	mimic_chance = 50

/mob/living/simple_mob/vore/aggressive/mimic/closet
	name = "old closet"
	desc = "It's a basic storage unit. It seems awfully rickety."
	icon_state = "cmimicopen"
	icon_living = "cmimicopen"
	icon = 'icons/mob/animal.dmi'

	maxHealth = 150
	health = 150
	movement_base_speed = 10 / 7

	legacy_melee_damage_lower = 10
	legacy_melee_damage_upper = 20
	attack_armor_pen =  25 // NOM NOM

	armor_legacy_mob = list(
				"melee" = 10,
				"bullet" = 20,
				"laser" = 20,
				"energy" = 20,
				"bomb" = 20,
				"bio" = 100,
				"rad" = 100)

/mob/living/simple_mob/vore/aggressive/mimic/closet/will_show_tooltip()
	return FALSE

/mob/living/simple_mob/vore/aggressive/mimic/closet/death()
	..()
	if(real_crate)
		real_crate.forceMove(loc)
	real_crate = null
	qdel(src)

//Floor Mimics... Because mimics you have to interact with to activate was not enough...

/obj/effect/floormimic //As Floor Mimics are triggered by bumps rather than click interaction... They are effects rather than structures
	name = "loose wooden floor"
	desc = "The boards here look rather loose."
	density = 0
	anchored = 1
	icon = 'icons/mob/mimic.dmi'
	icon_state = "wmimic"
	var/mimic_chance = 30
	var/mimic_active = TRUE
	var/mimic_type = /mob/living/simple_mob/vore/aggressive/mimic/floor

/obj/effect/floormimic/Crossed(atom/movable/AM)
	. = ..()
	tryTrigger(AM)

/obj/effect/floormimic/Bumped(atom/movable/AM)
	. = ..()
	tryTrigger(AM)

/obj/effect/floormimic/proc/tryTrigger(atom/movable/victim)
	if(!isliving(victim))
		return
	var/mob/living/L = victim
	if(L.is_avoiding_ground())
		return
	awaken(L)

/obj/effect/floormimic/proc/awaken(mob/living/L)
	if(!mimic_active)
		qdel(src)
		return
	mimic_active = FALSE
	if(!prob(mimic_chance))
		qdel(src)
		return
	var/mob/living/simple_mob/vore/aggressive/mimic/floor/new_mimic = new mimic_type(drop_location())
	visible_message("<span class='boldwarning'>The [new_mimic] suddenly growls beneath you as it turns out to be a mimic!</span>")

/obj/effect/floormimic/attackby(obj/item/I, mob/living/L)
	if(mimic_active)
		awaken(L)
	else
		return ..()

/obj/effect/floormimic/legacy_ex_act(severity)
	qdel(src)

/obj/effect/floormimic/safe
	mimic_chance = 0

/obj/effect/floormimic/guaranteed
	mimic_chance = 100

/obj/effect/floormimic/dangerous
	mimic_chance = 70

/obj/effect/floormimic/cointoss
	mimic_chance = 50

/mob/living/simple_mob/vore/aggressive/mimic/floor
	name = "loose wooden floor"
	desc = "The boards here look rather loose."
	icon = 'icons/mob/mimic.dmi'
	icon_state = "wmimicopen"
	icon_living = "wmimicopen"

	maxHealth = 100
	health = 100
	movement_base_speed = 10 / 5

	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"

	legacy_melee_damage_lower = 5
	legacy_melee_damage_upper = 5
	base_attack_cooldown = 5

/mob/living/simple_mob/vore/aggressive/mimic/floor/death()
	qdel(src)

/obj/effect/floormimic/tile
	name = "loose floor tiles"
	desc = "The tiles here look rather loose."
	density = FALSE
	anchored = TRUE
	icon_state = "tmimic"
	mimic_type = /mob/living/simple_mob/vore/aggressive/mimic/floor/tile

/obj/effect/floormimic/tile/safe
	mimic_chance = 0

/obj/effect/floormimic/tile/guaranteed
	mimic_chance = 100

/obj/effect/floormimic/tile/dangerous
	mimic_chance = 70

/obj/effect/floormimic/tile/cointoss
	mimic_chance = 50

/mob/living/simple_mob/vore/aggressive/mimic/floor/tile
	name = "loose floor tiles"
	desc = "The tiles here look rather loose."
	icon = 'icons/mob/mimic.dmi'
	icon_state = "tmimicopen"
	icon_living = "tmimicopen"

	maxHealth = 125
	health = 125
	movement_base_speed = 10 / 7

	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"

	legacy_melee_damage_lower = 15
	legacy_melee_damage_upper = 15
	base_attack_cooldown = 10

/obj/effect/floormimic/plating
	name = "loose plating"
	desc = "The plating here looks rather loose."
	density = FALSE
	anchored = TRUE
	icon_state = "pmimic"
	mimic_type = /mob/living/simple_mob/vore/aggressive/mimic/floor/plating

/obj/effect/floormimic/plating/safe
	mimic_chance = 0

/obj/effect/floormimic/plating/guaranteed
	mimic_chance = 100

/obj/effect/floormimic/plating/dangerous
	mimic_chance = 70

/obj/effect/floormimic/plating/cointoss
	mimic_chance = 50

/mob/living/simple_mob/vore/aggressive/mimic/floor/plating
	name = "loose plating"
	desc = "The plating here look rather loose."
	icon = 'icons/mob/mimic.dmi'
	icon_state = "pmimicopen"
	icon_living = "pmimicopen"

	maxHealth = 150
	health = 150
	movement_base_speed = 10 / 7

	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"

	legacy_melee_damage_lower = 15
	legacy_melee_damage_upper = 15
	base_attack_cooldown = 10
	attack_armor_pen = 50
