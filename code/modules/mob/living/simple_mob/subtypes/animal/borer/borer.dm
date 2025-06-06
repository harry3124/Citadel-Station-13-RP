// Borers are probably still going to be buggy as fuck, this is just bringing their mob defines up to the new system.
// IMO they're a relic of several ages we're long past, their code and their design showing this plainly, but removing them would
// make certain people Unhappy so here we are. They need a complete redesign but thats beyond the scope of the rewrite.

/datum/category_item/catalogue/fauna/borer
	name = "Cortical Borer"
	desc = "Cortical Borers are one of the many parasitic life forms \
	encountered on the Frontier. Often treated - justifiably - with disgust \
	and fear, evidence of a cortical borer can send a community spiralling \
	into panic and paranoia. Borers hijack the cortex of their hosts, fully \
	taking control of their victim's motor functions and speech, effectively \
	locking the host inside their own body. Borers reproduce inside their host \
	bodies, making it vital to their life cycle that they remain undetected. \
	Cortical borers are notably vulnerable to sugar, a fact often exploited when \
	screening for infested hosts."
	value = CATALOGUER_REWARD_HARD

/mob/living/simple_mob/animal/borer
	name = "cortical borer"
	desc = "A small, quivering sluglike creature."
	icon_state = "brainslug"
	item_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	catalogue_data = list(/datum/category_item/catalogue/fauna/borer)

	response_help  = "pokes"
	response_disarm = "prods"
	response_harm   = "stomps on"
	attacktext = list("nipped")
	friendly = list("prods")

	status_flags = STATUS_CAN_PUSH
	pass_flags = ATOM_PASS_TABLE
	movement_base_speed = 10 / 5

	universal_understand = TRUE
	can_be_antagged = TRUE

	holder_type = /obj/item/holder/borer
	ai_holder_type = null // This is player-controlled, always.

	var/chemicals = 10							// A resource used for reproduction and powers.
	var/max_chemicals = 250						// Max of said resource.
	var/mob/living/carbon/human/host = null		// The humanoid host for the brain worm.
	var/true_name = null						// String used when speaking among other worms.
	var/mob/living/captive_brain/host_brain		// Used for swapping control of the body back and forth.
	var/controlling = FALSE						// Used in human death ceck.
	var/docile = FALSE							// Sugar can stop borers from acting.
	var/has_reproduced = FALSE
	var/roundstart = FALSE						// If true, spawning won't try to pull a ghost.
	var/used_dominate							// world.time when the dominate power was last used.

/mob/living/simple_mob/animal/borer/roundstart
	roundstart = TRUE

/mob/living/simple_mob/animal/borer/Login()
	..()
	if(mind)
		borers.add_antagonist(mind)

/mob/living/simple_mob/animal/borer/Initialize(mapload)
	add_language("Cortical Link")

	add_verb(src, /mob/living/proc/ventcrawl)
	add_verb(src, /mob/living/proc/hide)

	true_name = "[pick("Primary","Secondary","Tertiary","Quaternary")] [rand(1000,9999)]"

	if(!roundstart)
		INVOKE_ASYNC(src, PROC_REF(request_player))

	return ..()

/mob/living/simple_mob/animal/borer/handle_special()
	if(host && !stat && !host.stat)
		// Handle docility.
		if(host.reagents.has_reagent("sugar") && !docile)
			var/message = "You feel the soporific flow of sugar in your host's blood, lulling you into docility."
			var/target = controlling ? host : src
			to_chat(target, SPAN_WARNING( message))
			docile = TRUE

		else if(docile)
			var/message = "You shake off your lethargy as the sugar leaves your host's blood."
			var/target = controlling ? host : src
			to_chat(target, SPAN_NOTICE(message))
			docile = FALSE

		// Chem regen.
		if(chemicals < max_chemicals)
			chemicals++

		// Control stuff.
		if(controlling)
			if(docile)
				to_chat(host, SPAN_WARNING( "You are feeling far too docile to continue controlling your host..."))
				host.release_control()
				return

			if(prob(5))
				host.adjustBrainLoss(0.1)

			if(prob(host.brainloss/20))
				host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_v","gasp"))]")

/mob/living/simple_mob/animal/borer/statpanel_data(client/C)
	. = ..()
	if(C.statpanel_tab("Status"))
		STATPANEL_DATA_ENTRY("Chemicals", "[chemicals]")

/mob/living/simple_mob/animal/borer/proc/detatch()
	if(!host || !controlling)
		return

	if(istype(host, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = host
		var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
		if(head)
			head.implants -= src

	controlling = FALSE

	host.remove_language("Cortical Link")
	remove_verb(host, /mob/living/carbon/proc/release_control)
	remove_verb(host, /mob/living/carbon/proc/punish_host)
	remove_verb(host, /mob/living/carbon/proc/spawn_larvae)

	if(host_brain)
		// these are here so bans and multikey warnings are not triggered on the wrong people when ckey is changed.
		// computer_id and IP are not updated magically on their own in offline mobs -walter0o

		// This shit need to die in a phoron fire.

		// host -> self
		var/h2s_id = host.computer_id
		var/h2s_ip= host.lastKnownIP
		host.computer_id = null
		host.lastKnownIP = null

		src.ckey = host.ckey

		if(!src.computer_id)
			src.computer_id = h2s_id

		if(!host_brain.lastKnownIP)
			src.lastKnownIP = h2s_ip

		// brain -> host
		var/b2h_id = host_brain.computer_id
		var/b2h_ip= host_brain.lastKnownIP
		host_brain.computer_id = null
		host_brain.lastKnownIP = null

		host.ckey = host_brain.ckey

		if(!host.computer_id)
			host.computer_id = b2h_id

		if(!host.lastKnownIP)
			host.lastKnownIP = b2h_ip

	qdel(host_brain)


/mob/living/simple_mob/animal/borer/proc/leave_host()
	if(!host)
		return

	if(host.mind)
		borers.remove_antagonist(host.mind)

	forceMove(host.loc)
	update_perspective()

	machine = null

	if(istype(host, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = host
		var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
		if(head)
			head.implants -= src

	host.machine = null
	host = null

/mob/living/simple_mob/animal/borer/proc/request_player()
	var/datum/ghost_query/Q = new /datum/ghost_query/borer()
	var/list/winner = Q.query() // This will sleep the proc for awhile.
	if(winner.len)
		var/mob/observer/dead/D = winner[1]
		transfer_personality(D)

/mob/living/simple_mob/animal/borer/proc/transfer_personality(mob/candidate)
	if(!candidate || !candidate.mind)
		return

	src.mind = candidate.mind
	candidate.mind.current = src
	ckey = candidate.ckey

	if(mind)
		mind.assigned_role = "Cortical Borer"
		mind.special_role = "Cortical Borer"

	to_chat(src, SPAN_NOTICE("You are a cortical borer! You are a brain slug that worms its way \
	into the head of its victim. Use stealth, persuasion and your powers of mind control to keep you, \
	your host and your eventual spawn safe and warm."))
	to_chat(src, "You can speak to your victim with <b>say</b>, to other borers with <b>say :x</b>, and use your Abilities tab to access powers.")

/mob/living/simple_mob/animal/borer/cannot_use_vents()
	return

// This is awful but its literally say code.
/mob/living/simple_mob/animal/borer/say(var/message, var/datum/prototype/language/speaking = null, var/verb="says", var/alt_name="", var/whispering = 0)
	message = sanitize(message)
	message = capitalize(message)

	if(!message)
		return

	if(stat >= DEAD)
		return say_dead(message)
	else if(stat)
		return

	if(client && client.prefs.muted & MUTE_IC)
		to_chat(src, SPAN_DANGER("You cannot speak in IC (muted)."))
		return

	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	var/datum/prototype/language/L = parse_language(message)
	if(L && L.language_flags & LANGUAGE_HIVEMIND)
		L.broadcast(src,trim(copytext(message,3)), src.true_name)
		return

	if(!host)
		if(chemicals >= 30)
			to_chat(src, SPAN_ALIEN("..You emit a psionic pulse with an encoded message.."))
			var/list/nearby_mobs = list()
			for(var/mob/living/LM in view(src, 1 + round(6 * (chemicals / max_chemicals))))
				if(LM == src)
					continue
				if(!LM.stat)
					nearby_mobs += LM
			var/mob/living/speaker
			if(nearby_mobs.len)
				speaker = input("Choose a target speaker.") as null|anything in nearby_mobs
			if(speaker)
				log_admin("[src.ckey]/([src]) tried to force [speaker] to say: [message]")
				message_admins("[src.ckey]/([src]) tried to force [speaker] to say: [message]")
				speaker.say("[message]")
				return
			to_chat(src, SPAN_ALIEN("..But nothing heard it.."))
		else
			to_chat(src, SPAN_WARNING( "You have no host to speak to."))
		return //No host, no audible speech.

	to_chat(src, "You drop words into [host]'s mind: \"[message]\"")
	to_chat(host, "Your own thoughts speak: \"[message]\"")

	for(var/mob/M in GLOB.player_list)
		if(istype(M, /mob/new_player))
			continue
		else if(M.stat == DEAD && M.get_preference_toggle(/datum/game_preference_toggle/observer/ghost_ears))
			to_chat(M, "[src.true_name] whispers to [host], \"[message]\"")

/mob/living/simple_mob/animal/borer/proc/surgically_remove(mob/living/carbon/human/target, obj/item/organ/external/chest/removing_from)
	if(controlling)
		target.release_control()
	detatch()
	leave_host()
