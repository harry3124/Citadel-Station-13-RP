//AMMUNITION

/obj/item/arrow
	name = "bolt"
	desc = "It's got a tip for you - get the point?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolt"
	item_state = "bolt"
	drop_sound = 'sound/items/drop/sword.ogg'
	pickup_sound = 'sound/items/pickup/sword.ogg'
	throw_force = 8
	w_class = WEIGHT_CLASS_NORMAL
	damage_mode = DAMAGE_MODE_SHARP

/obj/item/arrow/proc/removed() //Helper for metal rods falling apart.
	return

/obj/item/spike
	name = "alloy spike"
	desc = "It's about a foot of weird silver metal with a wicked point."
	damage_mode = DAMAGE_MODE_SHARP
	throw_force = 5
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons.dmi'
	icon_state = "metal-rod"
	item_state = "bolt"
	drop_sound = 'sound/items/drop/sword.ogg'
	pickup_sound = 'sound/items/pickup/sword.ogg'

/obj/item/arrow/quill
	name = "alien quill"
	desc = "A wickedly barbed quill from some bizarre animal."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "quill"
	item_state = "quill"
	throw_force = 5

/obj/item/arrow/rod
	name = "metal rod"
	desc = "Don't cry for me, Orithena."
	icon_state = "metal-rod"

/obj/item/arrow/rod/removed(mob/user)
	if(throw_force == 15) // The rod has been superheated - we don't want it to be useable when removed from the bow.
		to_chat(user, "[src] shatters into a scattering of overstressed metal shards as it leaves the crossbow.")
		var/obj/item/material/shard/shrapnel/S = new()
		S.loc = get_turf(src)
		qdel(src)

/obj/item/gun/launcher/crossbow
	name = "powered crossbow"
	desc = "A 2557AD twist on an old classic. Pick up that can."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "crossbow"
	item_state = "crossbow-solid"
	fire_sound = 'sound/weapons/punchmiss.ogg' // TODO: Decent THWOK noise.
	fire_sound_text = "a solid thunk"
	firemodes = /datum/firemode{
		cycle_cooldown = 2.5 SECONDS;
	}
	slot_flags = SLOT_BACK
	safety_state = GUN_NO_SAFETY
	one_handed_penalty = 10

	var/obj/item/bolt
	var/tension = 0                         // Current draw on the bow.
	var/max_tension = 5                     // Highest possible tension.
	var/release_speed = 5                   // Speed per unit of tension.
	var/obj/item/cell/cell = null    // Used for firing superheated rods.
	var/current_user                        // Used to check if the crossbow has changed hands since being drawn.

/obj/item/gun/launcher/crossbow/update_release_force()
	release_force = tension*release_speed

/obj/item/gun/launcher/crossbow/start_firing_cycle(atom/firer, angle, firing_flags, datum/firemode/firemode, atom/target, datum/event_args/actor/actor)
	if(tension <= 0)
		actor?.chat_feedback(
			SPAN_WARNING("The bolt on [src] isn't drawn back!"),
			target = src,
		)
		return FALSE
	return ..()

/obj/item/gun/launcher/crossbow/consume_next_throwable(datum/gun_firing_cycle/cycle)
	. = bolt
	bolt = null
	if(!.)
		return GUN_FIRED_FAIL_EMPTY

/obj/item/gun/launcher/crossbow/post_fire(datum/gun_firing_cycle/cycle)
	. = ..()
	tension = 0

/obj/item/gun/launcher/crossbow/should_attack_self_switch_firemodes()
	//True is normally returned if we have firemodes set, and that would make attack_self return early, never to draw
	return FALSE

/obj/item/gun/launcher/crossbow/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(tension)
		if(bolt)
			user.visible_message("[user] relaxes the tension on [src]'s string and removes [bolt].","You relax the tension on [src]'s string and remove [bolt].")
			bolt.loc = get_turf(src)
			var/obj/item/arrow/A = bolt
			bolt = null
			A.removed(user)
		else
			user.visible_message("[user] relaxes the tension on [src]'s string.","You relax the tension on [src]'s string.")
		tension = 0
		update_icon()
	else
		draw(user)

/obj/item/gun/launcher/crossbow/proc/draw(var/mob/user as mob)

	if(!bolt)
		to_chat(user, "You don't have anything nocked to [src].")
		return

	if(user.restrained())
		return

	current_user = user
	user.visible_message("[user] begins to draw back the string of [src].","<span class='notice'>You begin to draw back the string of [src].</span>")
	tension = 1

	while(bolt && tension && loc == current_user)
		if(!do_after(user, 25)) //crossbow strings don't just magically pull back on their own.
			user.visible_message("[usr] stops drawing and relaxes the string of [src].","<span class='warning'>You stop drawing back and relax the string of [src].</span>")
			tension = 0
			update_icon()
			return

		//double check that the user hasn't removed the bolt in the meantime
		if(!(bolt && tension && loc == current_user))
			return

		tension++
		update_icon()

		if(tension >= max_tension)
			tension = max_tension
			to_chat(usr, "[src] clunks as you draw the string to its maximum tension!")
			return

		user.visible_message("[usr] draws back the string of [src]!","<span class='notice'>You continue drawing back the string of [src]!</span>")

/obj/item/gun/launcher/crossbow/proc/increase_tension(var/mob/user as mob)

	if(!bolt || !tension || current_user != user) //Arrow has been fired, bow has been relaxed or user has changed.
		return


/obj/item/gun/launcher/crossbow/attackby(obj/item/W as obj, mob/user as mob)
	if(!bolt)
		if (istype(W,/obj/item/arrow))
			if(!user.attempt_insert_item_for_installation(W, src))
				return
			bolt = W
			user.visible_message("[user] slides [bolt] into [src].","You slide [bolt] into [src].")
			update_icon()
			return
		else if(istype(W,/obj/item/stack/rods))
			var/obj/item/stack/rods/R = W
			if (R.use(1))
				bolt = new /obj/item/arrow/rod(src)
				bolt.fingerprintslast = src.fingerprintslast
				bolt.loc = src
				update_icon()
				user.visible_message("[user] jams [bolt] into [src].","You jam [bolt] into [src].")
				superheat_rod(user)
			return

	if(istype(W, /obj/item/cell))
		if(!cell)
			if(!user.attempt_insert_item_for_installation(W, src))
				return
			cell = W
			to_chat(user, "<span class='notice'>You jam [cell] into [src] and wire it to the firing coil.</span>")
			superheat_rod(user)
		else
			to_chat(user, "<span class='notice'>[src] already has a cell installed.</span>")

	else if(W.is_screwdriver())
		if(cell)
			var/obj/item/C = cell
			C.loc = get_turf(user)
			to_chat(user, "<span class='notice'>You jimmy [cell] out of [src] with [W].</span>")
			playsound(src, W.tool_sound, 50, 1)
			cell = null
		else
			to_chat(user, "<span class='notice'>[src] doesn't have a cell installed.</span>")

	else
		..()

/obj/item/gun/launcher/crossbow/proc/superheat_rod(var/mob/user)
	if(!user || !cell || !bolt) return
	if(cell.charge < 500) return
	if(bolt.throw_force >= 15) return
	if(!istype(bolt,/obj/item/arrow/rod)) return

	to_chat(user, "<span class='notice'>[bolt] plinks and crackles as it begins to glow red-hot.</span>")
	bolt.throw_force = 15
	bolt.icon_state = "metal-rod-superheated"
	cell.use(500)

/obj/item/gun/launcher/crossbow/update_icon_state()
	. = ..()
	if(tension > 1)
		icon_state = "crossbow-drawn"
	else if(bolt)
		icon_state = "crossbow-nocked"
	else
		icon_state = "crossbow"

// Crossbow construction.
/obj/item/crossbowframe
	name = "crossbow frame"
	desc = "A half-finished crossbow."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "crossbowframe0"
	item_state = "crossbow-solid"

	var/buildstate = 0

/obj/item/crossbowframe/update_icon()
	icon_state = "crossbowframe[buildstate]"

/obj/item/crossbowframe/examine(mob/user, dist)
	. = ..()
	switch(buildstate)
		if(1)
			. += "It has a loose rod frame in place."
		if(2)
			. += "It has a steel backbone welded in place."
		if(3)
			. += "It has a steel backbone and a cell mount installed."
		if(4)
			. += "It has a steel backbone, plastic lath and a cell mount installed."
		if(5)
			. += "It has a steel cable loosely strung across the lath."

/obj/item/crossbowframe/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/rods))
		if(buildstate == 0)
			var/obj/item/stack/rods/R = W
			if(R.use(3))
				to_chat(user, "<span class='notice'>You assemble a backbone of rods around the wooden stock.</span>")
				buildstate++
				update_icon()
			else
				to_chat(user, "<span class='notice'>You need at least three rods to complete this task.</span>")
			return
	else if(istype(W, /obj/item/weldingtool))
		if(buildstate == 1)
			var/obj/item/weldingtool/T = W
			if(T.remove_fuel(0,user))
				if(!src || !T.isOn()) return
				playsound(src, W.tool_sound, 50, 1)
				to_chat(user, "<span class='notice'>You weld the rods into place.</span>")
			buildstate++
			update_icon()
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(buildstate == 2)
			if(C.use(5))
				to_chat(user, "<span class='notice'>You wire a crude cell mount into the top of the crossbow.</span>")
				buildstate++
				update_icon()
			else
				to_chat(user, "<span class='notice'>You need at least five segments of cable coil to complete this task.</span>")
			return
		else if(buildstate == 4)
			if(C.use(5))
				to_chat(user, "<span class='notice'>You string a steel cable across the crossbow's lath.</span>")
				buildstate++
				update_icon()
			else
				to_chat(user, "<span class='notice'>You need at least five segments of cable coil to complete this task.</span>")
			return
	else if(W.is_material_stack_of(/datum/prototype/material/plastic))
		if(buildstate == 3)
			var/obj/item/stack/material/P = W
			if(P.use(3))
				to_chat(user, "<span class='notice'>You assemble and install a heavy plastic lath onto the crossbow.</span>")
				buildstate++
				update_icon()
			else
				to_chat(user, "<span class='notice'>You need at least three plastic sheets to complete this task.</span>")
			return
	else if(W.is_screwdriver())
		if(buildstate == 5)
			to_chat(user, "<span class='notice'>You secure the crossbow's various parts.</span>")
			playsound(src, W.tool_sound, 50, 1)
			new /obj/item/gun/launcher/crossbow(get_turf(src))
			qdel(src)
		return
	else
		..()
