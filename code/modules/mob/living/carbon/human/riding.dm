//! file contains wrappers and hooks
/mob/living/carbon/human/drag_drop_buckle_interaction(atom/A, mob/user)
	if(!ismob(A) || (A == src))
		// first of all, if it's not a mob or if it's literally ourselves, kick it down
		return ..()
	// we're going to do a snowflaked Funny:
	// if we don't have a human riding filter, assume an admin is bussing(tm) and we should stop caring
	if(!LoadComponent(/datum/component/riding_filter/mob/human))
		return ..()
	// do standard stuff
	var/mob/buckling = A
	if(buckling == user)
		// prechecks
		if((buckling.get_effective_size() - get_effective_size()) >= 0.5)
			to_chat(buckling, SPAN_WARNING("How do you intend on mounting [src] when you are that big?"))
			return FALSE
		if(!isTaurTail(tail_style))
			if(a_intent != INTENT_HELP || buckling.a_intent != INTENT_HELP)
				return FALSE
			if(check_grab(buckling) != GRAB_PASSIVE)
				to_chat(user, SPAN_WARNING("[src] must be grabbing you passively for you to climb on."))
				return TRUE
		if(lying || buckling.lying)
			return FALSE
		carry_piggyback(buckling)
	else if(user == src)
		// prechecks
		if((buckling.get_effective_size() - get_effective_size()) >= 0.5)
			to_chat(user, SPAN_WARNING("How do you intend on carrying [buckling] when you are that small?"))
			return FALSE
		if(a_intent != INTENT_GRAB)
			return FALSE
		if(!buckling.lying)
			to_chat(user, SPAN_WARNING("[buckling] must be laying down if you want to carry them!"))
			return TRUE
		if(check_grab(buckling) != GRAB_PASSIVE)
			to_chat(user, SPAN_WARNING("You must be grabbing [buckling] passively to carry them."))
			return TRUE
		carry_fireman(buckling)
	return FALSE

// todo: this should become far more deliberate so it isn't easy to accidentally kick someone off
/mob/living/carbon/human/click_unbuckle_interaction(mob/user)
	if(user != src)
		// we can kick people off ourselves, others have to push us down or disarm offhands.
		return FALSE
	if(user.a_intent != INTENT_GRAB)
		// only allow kick-off while in grab intent
		return FALSE
	return ..()

/mob/living/carbon/human/verb/toggle_rider_control()

	set name = "Give Reins"
	set desc = "Give or take the person riding on you control of your movement."
	set category = VERB_CATEGORY_IC
	var/datum/component/riding_filter/mob/human/riding_filter = GetComponent(/datum/component/riding_filter/mob/human)
	if(!riding_filter)
		to_chat(src, "<span class='warning'>Your form is incompatible with being ridden</warning>")
		return
	if(riding_filter.handler_typepath == /datum/component/riding_handler/mob/human)
		riding_filter.handler_typepath = /datum/component/riding_handler/mob/human/controllable
		to_chat(src, "<span class='notice'>You can now be controlled")
	else
		riding_filter.handler_typepath = /datum/component/riding_handler/mob/human
		to_chat(src, "<span class='notice'>You can no longer be controlled")
	var/datum/component/riding_handler/mob/human/riding_handler = GetComponent(/datum/component/riding_handler/mob/human)
	if(!riding_handler)
		//No need to update the handler if it doesn't exist.
		return
	riding_handler.riding_handler_flags ^= CF_RIDING_HANDLER_IS_CONTROLLABLE

/mob/living/carbon/human/verb/buck_rider()

	set name = "Buck Rider"
	set desc = "Throw someone riding you off."
	set category = VERB_CATEGORY_IC
	for(var/mob/M in buckled_mobs)
		if(buckled_mobs[M] == BUCKLE_SEMANTIC_HUMAN_PIGGYBACK)
			M.visible_message(
				SPAN_NOTICE("[src] bucks and throws [M] of their back."),
				SPAN_WARNING("[src] bucks and throws you of their back!")
				)
			unbuckle_mob(M, BUCKLE_OP_FORCE, src, buckled_mobs[M])

/mob/living/carbon/human/proc/carry_piggyback(mob/living/carbon/other, instant = FALSE, delay_mod = 1, loc_check = TRUE)
	if(loc_check && !Adjacent(other))
		return FALSE
	other.visible_message(
		SPAN_NOTICE("[other] starts climbing onto [src]!"),
		SPAN_NOTICE("You start climbing onto [src]!")
	)
	if(!instant && !do_after(other, HUMAN_PIGGYBACK_DELAY * delay_mod, src, FALSE))
		return FALSE
	drop_grab(other)
	user_buckle_mob(other, BUCKLE_OP_DEFAULT_INTERACTION | BUCKLE_OP_SILENT, other, BUCKLE_SEMANTIC_HUMAN_PIGGYBACK)
	other.visible_message(
		SPAN_NOTICE("[other] climbs onto [src]!"),
		SPAN_NOTICE("You climb onto [src]!")
	)

/mob/living/carbon/human/proc/carry_fireman(mob/living/carbon/other, instant = FALSE, delay_mod = 1, loc_check = TRUE)
	if(loc_check && !Adjacent(other))
		return FALSE
	visible_message(
		SPAN_NOTICE("[src] starts picking up [other] over [p_their()] shoulders!"),
		SPAN_NOTICE("You start picking up [other] over your shoulders!")
	)
	if(!instant && !do_after(src, HUMAN_FIREMAN_DELAY * delay_mod, other, FALSE))
		return FALSE
	drop_grab(other)
	user_buckle_mob(other, BUCKLE_OP_DEFAULT_INTERACTION | BUCKLE_OP_SILENT, other, BUCKLE_SEMANTIC_HUMAN_FIREMAN)
	visible_message(
		SPAN_NOTICE("[src] picks [other] up over [p_their()] shoulders!"),
		SPAN_NOTICE("You pick [other] up over your shoulders!")
	)

/mob/living/carbon/human/buckle_lying(mob/M)
	var/semantic = buckled_mobs[M]
	return semantic == BUCKLE_SEMANTIC_HUMAN_FIREMAN? 90 : 0
