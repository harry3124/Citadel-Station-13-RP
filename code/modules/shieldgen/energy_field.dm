
//---------- actual energy field

// Each field object has a strength var (mensured in "Renwicks").
// Melee weapons do 5% of their normal (force var) damage, so a harmbaton would do 0.75 Renwick.
// Projectiles do 5% of their structural damage, so a normal laser would do 2 Renwick damage.
// For meteors, one Renwick is about equal to one layer of r-wall.
// Meteors will be completely halted by the shield if the shield survives the impact.
// Explosions do 4 Renwick of damage per severity, at a max of 12.

/obj/effect/energy_field
	name = "energy shield field"
	desc = "Impenetrable field of energy, capable of blocking anything as long as it's active."
	icon = 'icons/obj/machines/shielding.dmi'
	icon_state = "shield"
	alpha = 100
	anchored = TRUE
	plane = MOB_PLANE
	layer = ABOVE_MOB_LAYER
	density = FALSE
	CanAtmosPass = ATMOS_PASS_NOT_BLOCKED
	var/obj/machinery/shield_gen/my_gen = null
	var/strength = 0 // in Renwicks
	var/ticks_recovering = 10
	var/max_strength = 10

/obj/effect/energy_field/Initialize(mapload, new_gen)
	. = ..()
	my_gen = new_gen
	update_nearby_tiles()

/obj/effect/energy_field/Destroy()
	update_nearby_tiles()
	if(my_gen)
		my_gen.field.Remove(src)
		my_gen = null
	var/turf/current_loc = get_turf(src)
	. = ..()
	for(var/direction in GLOB.cardinal)
		var/turf/T = get_step(current_loc, direction)
		if(T)
			for(var/obj/effect/energy_field/F in T)
				F.update_icon()

/obj/effect/energy_field/legacy_ex_act(var/severity)
	adjust_strength(-(4 - severity) * 4)

/obj/effect/energy_field/attackby(obj/item/W, mob/user)
	if(W.damage_force)
		adjust_strength(-W.damage_force / 20)
		user.do_attack_animation(src)
		user.setClickCooldownLegacy(user.get_attack_speed_legacy(W))
	..()

/obj/effect/energy_field/attack_generic(mob/user, damage)
	if(damage)
		adjust_strength(-damage / 20)
		user.do_attack_animation(src)
		user.setClickCooldownLegacy(user.get_attack_speed_legacy())

/obj/effect/energy_field/inflict_atom_damage(damage, damage_type, damage_tier, damage_flag, damage_mode, hit_zone, attack_type, datum/weapon)
	adjust_strength(damage / 20)
	return damage

/obj/effect/energy_field/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	impact_effect(3) // Harmless, but still produces the 'impact' effect.
	..()

/obj/effect/energy_field/Bumped(atom/A)
	..(A)
	impact_effect(2)

/obj/effect/energy_field/handle_meteor_impact(var/obj/effect/meteor/meteor)
	var/penetrated = TRUE
	adjust_strength(-max((meteor.wall_power * meteor.hits) / 800, 0)) // One renwick (strength var) equals one r-wall for the purposes of meteor-stopping.
	sleep(1)
	if(density) // Check if we're still up.
		penetrated = FALSE
		explosion(meteor.loc, 0, 0, 0, 0, 0, 0, 0) // For the sound effect.

	// Returning FALSE will kill the meteor.
	return penetrated // If the shield's still around, the meteor was successfully stopped, otherwise keep going and plow into the station.

/obj/effect/energy_field/proc/adjust_strength(amount, impact = 1)
	var/old_density = density
	strength = between(0, strength + amount, max_strength)

	//maptext = "[round(strength, 0.1)]/[max_strength]"

	//if we take too much damage, drop out - the generator will bring us back up if we have enough power
	if(amount < 0) // Taking damage.
		if(impact)
			impact_effect(round(abs(amount * 2)))

		ticks_recovering = min(ticks_recovering + 2, 10)
		if(strength < 1) // We broke
			density = 0
			ticks_recovering = 10
			strength = 0

	else if(amount > 0) // Healing damage.
		if(strength >= 1)
			density = 1

	if(density != old_density)
		update_icon()
		update_nearby_tiles()

/obj/effect/energy_field/update_icon(update_neightbors = 0)
	cut_overlays()

	var/list/adjacent_shields_dir = list()
	for(var/direction in GLOB.cardinal)
		var/turf/T = get_step(src, direction)
		if(T) // Incase we somehow stepped off the map.
			for(var/obj/effect/energy_field/F in T)
				if(update_neightbors)
					F.update_icon(0)
				adjacent_shields_dir |= direction
				break
	// Icon_state and Glow
	if(density)
		icon_state = "shield"
		set_light(3, 3, "#66FFFF")
	else
		icon_state = "shield_broken"
		set_light(3, 5, "#FF9900")

	var/list/overlays_to_add = list()
	// Edge overlays
	for(var/found_dir in adjacent_shields_dir)
		overlays_to_add += image(src.icon, src, icon_state = "shield_edge", dir = found_dir)

	add_overlay(overlays_to_add)

// Small visual effect, makes the shield tiles brighten up by becoming more opaque for a moment, and spreads to nearby shields.
/obj/effect/energy_field/proc/impact_effect(var/i, var/list/affected_shields = list())
	i = between(1, i, 10)
	alpha = 200
	animate(src, alpha = initial(alpha), time = 1 SECOND)
	affected_shields |= src
	i--
	if(i)
		spawn(2)
			for(var/direction in GLOB.cardinal)
				var/turf/T = get_step(src, direction)
				if(T) // Incase we somehow stepped off the map.
					for(var/obj/effect/energy_field/F in T)
						if(!(F in affected_shields))
							F.impact_effect(i, affected_shields) // Spread the effect to them.
