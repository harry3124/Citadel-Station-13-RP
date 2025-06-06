/// all player ghosts
GLOBAL_LIST_EMPTY(observer_list)

/mob/observer/dead
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/ghost.dmi'
	icon_state = "ghost"
	layer = BELOW_MOB_LAYER
	plane = OBSERVER_PLANE
	alpha = 127
	stat = DEAD
	mobility_flags = NONE
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	SET_APPEARANCE_FLAGS(PIXEL_SCALE | KEEP_TOGETHER)
	/// Do we set dir on move
	var/updatedir = TRUE
	var/can_reenter_corpse
	var/datum/hud/living/carbon/hud = null // hud
	var/bootime = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/has_enabled_antagHUD = FALSE
	var/medHUD = FALSE
	var/antagHUD = FALSE
	universal_speak = TRUE
	var/admin_ghosted = FALSE
	/// Is the ghost able to see things humans can't?
	var/ghostvision = TRUE
	incorporeal_move = TRUE

	var/is_manifest = FALSE //If set to 1, the ghost is able to whisper. Usually only set if a cultist drags them through the veil.
	var/ghost_sprite = null
	var/global/list/possible_ghost_sprites = list(
		"Clear" = "blank",
		"Green Blob" = "otherthing",
		"Bland" = "ghost",
		"Robed-B" = "ghost1",
		"Robed-BAlt" = "ghost2",
		"King" = "ghostking",
		"Shade" = "shade",
		"Hecate" = "ghost-narsie",
		"Glowing Statue" = "armour",
		"Artificer" = "artificer",
		"Behemoth" = "behemoth",
		"Harvester" = "harvester",
		"Wraith" = "wraith",
		"Viscerator" = "viscerator",
		"Corgi" = "corgi",
		"Tamaskan" = "tamaskan",
		"Black Cat" = "blackcat",
		"Lizard" = "lizard",
		"Goat" = "goat",
		"Space Bear" = "bear",
		"Bats" = "bat",
		"Chicken" = "chicken_white",
		"Parrot"= "parrot_fly",
		"Goose" = "goose",
		"Penguin" = "penguin_new",
		"Penguin (Old)" = "penguin",
		"Penguin (Baby)" = "penguin_baby",
		"Brown Crab" = "crab",
		"Gray Crab" = "evilcrab",
		"Trout" = "trout-swim",
		"Salmon" = "salmon-swim",
		"Pike" = "pike-swim",
		"Koi" = "koi-swim",
		"Carp" = "carp",
		"Red Robes" = "robe_red",
		"Faithless" = "faithless",
		"Shadowform" = "forgotten",
		"Dark Ethereal" = "bloodguardian",
		"Holy Ethereal" = "lightguardian",
		"Red Elemental" = "magicRed",
		"Blue Elemental" = "magicBlue",
		"Pink Elemental" = "magicPink",
		"Orange Elemental" = "magicOrange",
		"Green Elemental" = "magicGreen",
		"Daemon" = "daemon",
		"Guard Spider" = "guard",
		"Hunter Spider" = "hunter",
		"Nurse Spider" = "nurse",
		"Rogue Drone" = "drone",
		"ED-209" = "ed209",
		"Beepsky" = "secbot"
		)
	var/last_revive_notification = null // world.time of last notification, used to avoid spamming players from defibs or cloners.
	/// stealthmin vars
	var/original_name
	/// are we a poltergeist and get to do stupid things like move items, throw things, and move chairs?
	var/is_spooky = FALSE
	//For a better follow selection:
	var/datum/orbit_menu/orbit_menu

/mob/observer/dead/Initialize(mapload)
	GLOB.observer_list += src
	var/mob/body = loc
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = world.view //I mean. I don't even know if byond has occlusion culling... but...
	plane = OBSERVER_PLANE //Why doesn't the var above work...???
	add_verb(src, /mob/observer/dead/proc/dead_tele)

	var/turf/T
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?
		attack_log = body.attack_log	//preserve our attack logs by copying them to our ghost

		if (ishuman(body))
			var/mob/living/carbon/human/H = body
			icon = H.icon
			icon_state = H.icon_state
			// todo: fixup (get rid of other planes)
			for(var/key in H.standing_overlays)
				add_overlay(H.standing_overlays[key])
			for(var/slot_id in H.inventory.rendered_normal_overlays)
				add_overlay(H.inventory.rendered_normal_overlays[slot_id])
		else
			icon = body.icon
			icon_state = body.icon_state
			// todo: fixup (get rid of other planes)
			add_overlay(body.overlays)

		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				if(gender == MALE)
					name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
				else
					name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.

	if(!T)
		T = SSjob.get_latejoin_spawnpoint()
	if(!T)
		T = locate(1,1,1)
	forceMove(T)

	if(!name) //To prevent nameless ghosts
		name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
	real_name = name
	return ..()

/mob/observer/dead/Destroy()
	GLOB.observer_list -= src
	return ..()

/mob/observer/dead/Topic(href, href_list)
	if (href_list["track"])
		var/mob/target = locate(href_list["track"]) in GLOB.mob_list
		if(target)
			ManualFollow(target)
	if(href_list["reenter"])
		reenter_corpse()
		return
	if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		if(get_dist(src, get_turf(I)) > 7)
			return
		src.examinate(I)

/mob/observer/dead/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/book/tome))
		var/mob/observer/dead/M = src
		M.manifest(user)

/mob/observer/dead/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	return TRUE

/mob/observer/dead/set_stat(new_stat, update_mobility = TRUE)
	CRASH("It is best if observers stay dead, thank you.")

/mob/observer/dead/Life(seconds, times_fired)
	if((. = ..()))
		return

	if(!client)
		return

	if(!loc)
		return

	handle_regular_hud_updates()
	handle_vision()

/mob/proc/ghostize(var/can_reenter_corpse = 1)
	if(key)
		SSplaytime.queue_playtimes(client)
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.vr_holder && !can_reenter_corpse)
				H.exit_vr()
				return 0
		var/mob/observer/dead/ghost = new(src)	//Transfer safety to observer spawning proc.
		ghost.can_reenter_corpse = can_reenter_corpse
		ghost.timeofdeath = src.timeofdeath //BS12 EDIT
		transfer_client_to(ghost)
		if(istype(loc, /obj/structure/morgue))
			var/obj/structure/morgue/M = loc
			M.update()
		else if(istype(loc, /obj/structure/closet/body_bag))
			var/obj/structure/closet/body_bag/B = loc
			B.update()
		if(ghost.client)
			ghost.client.time_died_as_mouse = ghost.timeofdeath
		if(ghost.client && !ghost.client.holder && !config_legacy.antag_hud_allowed)		// For new ghosts we remove the verb from even showing up if it's not allowed.
			remove_verb(ghost, /mob/observer/dead/verb/toggle_antagHUD)	// Poor guys, don't know what they are missing!
		ghost.client?.holder?.update_stealth_ghost()
		return ghost

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = VERB_CATEGORY_OOC
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	if(stat == DEAD && !forbid_seeing_deadchat)
		announce_ghost_joinleave(ghostize(1))
	else
		var/response
		if(src.client && src.client.holder)
			response = alert(src, "You have the ability to Admin-Ghost. The regular Ghost verb will announce your presence to dead chat. Both variants will allow you to return to your body using 'aghost'.\n\nWhat do you wish to do?", "Are you sure you want to ghost?", "Ghost", "Admin Ghost", "Stay in body")
			if(response == "Admin Ghost")
				if(!src.client)
					return
				src.client.admin_ghost()
		else
			response = alert(src, "Are you -sure- you want to ghost?\n(You are alive, or otherwise have the potential to become alive. Don't abuse ghost unless you are inside a cryopod or equivalent! You can't change your mind so choose wisely!)", "Are you sure you want to ghost?", "Ghost", "Stay in body")
		if(response != "Ghost")
			return
		resting = 1
		var/turf/location = get_turf(src)
		var/special_role = check_special_role()
		if(!istype(loc,/obj/machinery/cryopod))
			log_and_message_admins("has ghosted outside cryo[special_role ? " as [special_role]" : ""]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>JMP</a>)",usr)
		else if(special_role)
			log_and_message_admins("has ghosted in cryo as [special_role]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>JMP</a>)",usr)
		var/mob/observer/dead/ghost = ghostize(0)	// 0 parameter is so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
		if(ghost)
			ghost.timeofdeath = world.time 	// Because the living mob won't have a time of death and we want the respawn timer to work properly.
			ghost.set_respawn_timer()
			announce_ghost_joinleave(ghost)

/mob/observer/dead/can_use_hands()
	return 0

/mob/observer/dead/is_active()
	return 0

/mob/observer/dead/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!client)
		return
	if(!(mind && mind.current && can_reenter_corpse))
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		to_chat(usr, "<span class='warning'>Another consciousness is in your body... it is resisting you.</span>")
		return
	if(prevent_respawns.Find(mind.name))
		to_chat(usr,"<span class='warning'>You already quit this round as this character, sorry!</span>")
		return
	if(mind.current.ajourn && mind.current.stat != DEAD) //check if the corpse is astral-journeying (it's client ghosted using a cultist rune).
		var/found_rune
		for(var/obj/effect/rune/R in mind.current.loc)   //whilst corpse is alive, we can only reenter the body if it's on the rune
			if(R && R.word1 == cultwords["hell"] && R.word2 == cultwords["travel"] && R.word3 == cultwords["self"]) // Found an astral journey rune.
				found_rune = 1
				break
		if(!found_rune)
			to_chat(usr, "<span class='warning'>The astral cord that ties your body and your spirit has been severed. You are likely to wander the realm beyond until your body is finally dead and thus reunited with you.</span>")
			return
	mind.current.ajourn=0
	transfer_client_to(mind.current)
	mind.current.teleop = null
	if(istype(mind.current.loc, /obj/structure/morgue))
		var/obj/structure/morgue/M = mind.current.loc
		M.update(1)
	else if(istype(mind.current.loc, /obj/structure/closet/body_bag))
		var/obj/structure/closet/body_bag/B = mind.current.loc
		B.update(1)
	if(!admin_ghosted)
		announce_ghost_joinleave(mind, 0, "They now occupy their body again.")
	return 1

/mob/observer/dead/verb/toggle_medHUD()
	set category = "Ghost"
	set name = "Toggle MedicHUD"
	set desc = "Toggles Medical HUD allowing you to see how everyone is doing"

	medHUD = !medHUD
	if(medHUD)
		self_perspective.add_atom_hud(/datum/atom_hud/data/human/medical, ATOM_HUD_SOURCE_OBSERVER)
	else
		self_perspective.remove_atom_hud(/datum/atom_hud/data/human/medical, ATOM_HUD_SOURCE_OBSERVER)
	to_chat(src,"<font color=#4F49AF><B>Medical HUD [medHUD ? "Enabled" : "Disabled"]</B></font>")

/mob/observer/dead/verb/toggle_antagHUD()
	set category = "Ghost"
	set name = "Toggle AntagHUD"
	set desc = "Toggles AntagHUD allowing you to see who is the antagonist"

	if(!config_legacy.antag_hud_allowed && !client.holder)
		to_chat(src, "<font color='red'>Admins have disabled this for this round.</font>")
		return
	if(jobban_isbanned(src, "AntagHUD"))
		to_chat(src, "<font color='red'><B>You have been banned from using this feature</B></font>")
		return
	if(config_legacy.antag_hud_restricted && !has_enabled_antagHUD && !client.holder)
		var/response = alert(src, "If you turn this on, you will not be able to take any part in the round.","Are you sure you want to turn this feature on?","Yes","No")
		if(response == "No") return
		can_reenter_corpse = FALSE
		set_respawn_timer(-1)	// Foreeeever
	if(!has_enabled_antagHUD && !client.holder)
		has_enabled_antagHUD = TRUE

	antagHUD = !antagHUD
	if(antagHUD)
		self_perspective.add_atom_hud(/datum/atom_hud/antag, ATOM_HUD_SOURCE_OBSERVER)
	else
		self_perspective.remove_atom_hud(/datum/atom_hud/antag, ATOM_HUD_SOURCE_OBSERVER)
	to_chat(src,"<font color=#4F49AF><B>AntagHUD [antagHUD ? "Enabled" : "Disabled"]</B></font>")

/mob/observer/dead/proc/dead_tele(var/area/A in GLOB.sortedAreas)
	set category = "Ghost"
	set name = "Teleport"
	set desc = "Teleport to a location"

	if(!istype(usr, /mob/observer/dead))
		to_chat(usr, "Not when you're not dead!")
		return

	if(!A)
		A = input(usr, "Select an area:", "Ghost Teleport") as null|anything in GLOB.sortedAreas
	if(!A)
		return

	usr.forceMove(pick(get_area_turfs(A)))

/mob/observer/dead/verb/follow()
	set category = "Ghost"
	set name = "Follow"

	if(!orbit_menu)
		orbit_menu = new(src)
	orbit_menu.ui_interact(src)

// This is the ghost's follow verb with an argument
/mob/observer/dead/proc/ManualFollow(atom/movable/target)
	if (!istype(target))
		return

	//Attempt to orbit based on target size
	var/icon/I = icon(target.icon,target.icon_state,target.dir)

	var/orbitsize = (I.Width()+I.Height())*0.5
	orbitsize -= (orbitsize/world.icon_size)*(world.icon_size*0.25)

	orbit(target, orbitsize)

/mob/observer/dead/orbit()
	setDir(2) //reset dir so the right directional sprites show up
	return ..()

/mob/observer/dead/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	//restart our floating animation after orbit is done.
	pixel_y = 0
	pixel_x = 0
	transform = null
	animate(src, pixel_y = 2, time = 10, loop = -1)

/mob/observer/dead/verb/jumptomob(input in getmobs_ghost_follow()) //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob"
	set popup_menu = FALSE

	if(!istype(usr, /mob/observer/dead)) //Make sure they're an observer!
		return

	if(!input)
		input = input(usr, "Select a mob:", "Ghost Jump") as null|anything in getmobs_ghost_follow()
	if(!input)
		return

	var/target = getmobs_ghost_follow()[input]
	if (!target)//Make sure we actually have a target
		return
	else
		var/mob/M = target //Destination mob
		var/turf/T = get_turf(M) //Turf of the destination mob

		if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
			forceMove(T)
		else
			to_chat(src, "This mob is not located in the game world.")
/*
/mob/observer/dead/verb/boo()
	set category = "Ghost"
	set name = "Boo!"
	set desc= "Scare your crew members because of boredom!"

	if(bootime > world.time) return
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L)
		L.flicker()
		bootime = world.time + 600
		return
	//Maybe in the future we can add more <i>spooky</i> code here!
	return
*/

/mob/observer/dead/memory()
	set hidden = 1
	to_chat(src, "<font color='red'>You are dead! You have no mind to store memory!</font>")

/mob/observer/dead/add_memory()
	set hidden = 1
	to_chat(src, "<font color='red'>You are dead! You have no mind to store memory!</font>")

/mob/observer/dead/verb/analyze_air()
	set name = "Analyze Air"
	set category = "Ghost"

	if(!istype(usr, /mob/observer/dead)) return

	// Shamelessly copied from the Gas Analyzers
	if (!( istype(usr.loc, /turf) ))
		return

	var/datum/gas_mixture/environment = usr.loc.return_air()

	to_chat(src, "<font color=#4F49AF><B>Results:</B></font>")
	to_chat(src, jointext(environment.chat_analyzer_scan(NONE, TRUE, TRUE), "<br>"))

/mob/observer/dead/verb/become_mouse()
	set name = "Become mouse"
	set category = "Ghost"

	if(client.persistent.ligma)
		to_chat(src, "<span class='warning'>Spawning as a mouse is currently disabled.</span>")
		log_shadowban("[key_name(src)] mouse join blocked")
		return

	if(config_legacy.disable_player_mice)
		to_chat(src, "<span class='warning'>Spawning as a mouse is currently disabled.</span>")
		return

	if(!MayRespawn(1))
		return

	var/turf/T = get_turf(src)
	if(!T || (T.z in (LEGACY_MAP_DATUM).admin_levels))
		to_chat(src, "<span class='warning'>You may not spawn as a mouse on this Z-level.</span>")
		return

	var/timedifference = world.time - client.time_died_as_mouse
	if(client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
		var/timedifference_text
		timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
		to_chat(src, "<span class='warning'>You may only spawn again as a mouse more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>")
		return

	var/response = alert(src, "Are you -sure- you want to become a mouse?","Are you sure you want to squeek?","Squeek!","Nope!")
	if(response != "Squeek!") return  //Hit the wrong key...again.


	//find a viable mouse candidate
	var/mob/living/simple_mob/animal/passive/mouse/host
	var/obj/machinery/atmospherics/component/unary/vent_pump/vent_found
	var/list/found_vents = list()
	for(var/obj/machinery/atmospherics/component/unary/vent_pump/v in GLOB.machines)
		if(!v.welded && v.z == T.z && v.network && v.network.normal_members.len > 20)
			found_vents.Add(v)
	if(found_vents.len)
		vent_found = pick(found_vents)
		host = new /mob/living/simple_mob/animal/passive/mouse(vent_found)
	else
		to_chat(src, "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>")

	if(host)
		if(config_legacy.uneducated_mice)
			host.universal_understand = 0
		announce_ghost_joinleave(src, 0, "They are now a mouse.")
		transfer_client_to(host)
		host.add_ventcrawl(vent_found)
		host.update_perspective()
		to_chat(host, "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>")

/mob/observer/dead/verb/view_manfiest()
	set name = "Show Crew Manifest"
	set category = "Ghost"

	var/dat
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest()

	src << browse(HTML_SKELETON(dat), "window=manifest;size=370x420;can_close=1")

//This is called when a ghost is drag clicked to something.
/mob/observer/dead/OnMouseDropLegacy(atom/over)
	if(!usr || !over) return
	if (isobserver(usr) && usr.client && usr.client.holder && isliving(over))
		if (usr.client.holder.cmd_ghost_drag(src,over))
			return

	return ..()

//Used for drawing on walls with blood puddles as a spooky ghost.
/mob/observer/dead/verb/bloody_doodle()

	set category = "Ghost"
	set name = "Write in blood"
	set desc = "If the round is sufficiently spooky, write a short message in blood on the floor or a wall. Remember, no IC in OOC or OOC in IC."

	if(!(config_legacy.cult_ghostwriter))
		to_chat(src, "<font color='red'>That verb is not currently permitted.</font>")
		return

	if (!src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	var/ghosts_can_write
	if(SSticker.mode.name == "cult")
		if(cult.current_antagonists.len > config_legacy.cult_ghostwriter_req_cultists)
			ghosts_can_write = 1

	if(!ghosts_can_write && !check_rights(R_ADMIN, 0)) //Let's allow for admins to write in blood for events and the such.
		to_chat(src, "<font color='red'>The veil is not thin enough for you to do that.</font>")
		return

	var/list/choices = list()
	for(var/obj/effect/debris/cleanable/blood/B in view(1,src))
		if(B.amount > 0)
			choices += B

	if(!choices.len)
		to_chat(src, "<span class = 'warning'>There is no blood to use nearby.</span>")
		return

	var/obj/effect/debris/cleanable/blood/choice = input(src,"What blood would you like to use?") in null|choices

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	var/turf/simulated/T = src.loc
	if (direction != "Here")
		T = get_step(T,text2dir(direction))

	if (!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	if(!choice || choice.amount == 0 || !(src.Adjacent(choice)))
		return

	var/doodle_color = (choice.basecolor) ? choice.basecolor : "#A10808"

	var/num_doodles = 0
	for (var/obj/effect/debris/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = 50

	var/message = sanitize(input("Write a message. It cannot be longer than [max_length] characters.","Blood writing", ""))

	if (message)

		if (length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")

		var/obj/effect/debris/cleanable/blood/writing/W = new(T)
		W.basecolor = doodle_color
		W.update_icon()
		W.message = message
		W.add_hiddenprint(src)
		W.visible_message("<font color='red'>Invisible fingers crudely paint something in blood on [T]...</font>")

/mob/observer/dead/pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return 0
	usr.visible_message("<span class='deadsay'><b>[src]</b> points to [A]</span>")
	return 1

/mob/observer/dead/proc/manifest(mob/user)
	is_manifest = TRUE
	add_verb(src, /mob/observer/dead/proc/toggle_visibility)
	add_verb(src, /mob/observer/dead/proc/ghost_whisper)
	to_chat(src,"<font color='purple'>As you are now in the realm of the living, you can whisper to the living with the <b>Spectral Whisper</b> verb, inside the IC tab.</font>")
	if(plane != BYOND_PLANE)
		user.visible_message( \
			"<span class='warning'>\The [user] drags ghost, [src], to our plane of reality!</span>", \
			"<span class='warning'>You drag [src] to our plane of reality!</span>" \
		)
		toggle_visibility(TRUE)
	else
		var/datum/gender/T = GLOB.gender_datums[user.get_visible_gender()]
		user.visible_message ( \
			"<span class='warning'>\The [user] just tried to smash [T.his] book into that ghost!  It's not very effective.</span>", \
			"<span class='warning'>You get the feeling that the ghost can't become any more visible.</span>" \
		)

/mob/observer/dead/proc/toggle_icon(var/icon)
	if(!client)
		return

	var/iconRemoved = 0
	for(var/image/I in client.images)
		if(I.icon_state == icon)
			iconRemoved = 1
			qdel(I)

	if(!iconRemoved)
		var/image/J = image('icons/mob/mob.dmi', loc = src, icon_state = icon)
		client.images += J

/mob/observer/dead/proc/toggle_visibility(var/forced = 0)
	set category = "Ghost"
	set name = "Toggle Visibility"
	set desc = "Allows you to turn (in)visible (almost) at will."

	var/toggled_invisible
	if(!forced && plane == OBSERVER_PLANE && world.time < toggled_invisible + 600)
		to_chat(src, "You must gather strength before you can turn visible again...")
		return

	if(plane == BYOND_PLANE)
		toggled_invisible = world.time
		visible_message("<span class='emote'>It fades from sight...</span>", "<span class='info'>You are now invisible.</span>")
	else
		to_chat(src, "<span class='info'>You are now visible!</span>")

	plane = (plane == OBSERVER_PLANE) ? BYOND_PLANE : OBSERVER_PLANE
	invisibility = (plane == BYOND_PLANE) ? 0 : INVISIBILITY_OBSERVER

	// Give the ghost a cult icon which should be visible only to itself
	toggle_icon("cult")

/mob/observer/dead/canface()
	return 1

/mob/observer/dead/proc/can_admin_interact()
	return check_rights(R_ADMIN, 0, src)

/mob/observer/dead/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"
	set category = "Ghost"
	ghostvision = !ghostvision
	update_ghost_sight()
	to_chat(src,"You [ghostvision ? "now" : "no longer"] have ghost vision.")

/mob/observer/dead/MayRespawn(var/feedback = 0)
	if(!client)
		return 0
	if(mind && mind.current && mind.current.stat != DEAD && can_reenter_corpse)
		if(feedback)
			to_chat(src, "<span class='warning'>Your non-dead body prevent you from respawning.</span>")
		return 0
	if(config_legacy.antag_hud_restricted && has_enabled_antagHUD == 1)
		if(feedback)
			to_chat(src, "<span class='warning'>antagHUD restrictions prevent you from respawning.</span>")
		return 0
	return 1

/atom/proc/extra_ghost_link()
	return

/mob/extra_ghost_link(var/atom/ghost)
	if(client && eyeobj)
		return "|<a href='byond://?src=\ref[ghost];track=\ref[eyeobj]'>eye</a>"

/mob/observer/dead/extra_ghost_link(var/atom/ghost)
	if(mind && mind.current)
		return "|<a href='byond://?src=\ref[ghost];track=\ref[mind.current]'>body</a>"

/proc/ghost_follow_link(var/atom/target, var/atom/ghost)
	if((!target) || (!ghost)) return
	. = "<a href='byond://?src=\ref[ghost];track=\ref[target]'>follow</a>"
	. += target.extra_ghost_link(ghost)

//Culted Ghosts

/mob/observer/dead/proc/ghost_whisper()
	set name = "Spectral Whisper"
	set category = VERB_CATEGORY_IC

	if(is_manifest)  //Only able to whisper if it's hit with a tome.
		var/list/options = list()
		for(var/mob/living/Ms in view(src))
			options += Ms
		var/mob/living/M = input(src, "Select who to whisper to:", "Whisper to?", null) as null|mob in options
		if(!M)
			return 0
		var/msg = sanitize(input(src, "Message:", "Spectral Whisper") as text|null)
		if(msg)
			log_say("(SPECWHISP to [key_name(M)]): [msg]", src)
			to_chat(M, "<span class='warning'> You hear a strange, unidentifiable voice in your head... <font color='purple'>[msg]</font></span>")
			to_chat(src, "<span class='warning'> You said: '[msg]' to [M].</span>")
		else
			return
		return 1
	else
		to_chat(src, "<span class='danger'>You have not been pulled past the veil!</span>")

/mob/observer/dead/verb/choose_ghost_sprite()
	set category = "Ghost"
	set name = "Choose Sprite"

	var/choice
	var/previous_state
	var/finalized = "No"

	while(finalized == "No" && src.client)
		choice = input(usr,"What would you like to use for your ghost sprite?") as null|anything in possible_ghost_sprites
		if(!choice)
			return

		if(choice)
			icon = 'icons/mob/ghost.dmi'
			cut_overlays()

			if(icon_state && icon)
				previous_state = icon_state

			icon_state = possible_ghost_sprites[choice]
			finalized = alert("Look at your sprite. Is this what you wish to use?",,"No","Yes")

			ghost_sprite = possible_ghost_sprites[choice]

			if(finalized == "No")
				icon_state = previous_state

/mob/observer/dead/is_blind()
	return FALSE

/mob/observer/dead/is_deaf()
	return FALSE

/mob/observer/dead/verb/paialert()
	set category = "Ghost"
	set name = "Blank pAI alert"
	set desc = "Flash an indicator light on available blank pAI devices for a smidgen of hope."

	if(usr.client.prefs?.be_special & BE_PAI)
		var/count = 0
		for(var/obj/item/paicard/p in GLOB.all_pai_cards)
			var/obj/item/paicard/PP = p
			if(PP.pai == null)
				count++
		to_chat(usr,"<span class='notice'>Flashing the displays of [count] unoccupied PAIs.</span>")
	else
		to_chat(usr,"<span class='warning'>You have 'Be pAI' disabled in your character prefs, so we can't help you.</span>")

/mob/observer/dead/speech_bubble_appearance()
	return "ghost"


// Lets a ghost know someone's trying to bring them back, and for them to get into their body.
// Mostly the same as TG's sans the hud element, since we don't have TG huds.
/mob/observer/dead/proc/notify_revive(var/message, var/sound, flashwindow = TRUE)
	if((last_revive_notification + 2 MINUTES) > world.time)
		return
	last_revive_notification = world.time

	if(flashwindow)
		window_flash(client)
	if(message)
		to_chat(src, "<span class='ghostalert'><font size=4>[message]</font></span>")
	to_chat(src, "<span class='ghostalert'><a href=?src=[REF(src)];reenter=1>(Click to re-enter)</a></span>")
	if(sound)
		SEND_SOUND(src, sound(sound))

/mob/dead/observer/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE)
	return isAdminGhostAI(usr)

/mob/observer/dead/verb/nifjoin()
	set category = "Ghost"
	set name = "Join Into Soulcatcher"
	set desc = "Select a player with a working NIF + Soulcatcher NIFSoft to join into it."

	var/list/filtered = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H.nif?.imp_check(NIF_SOULCATCHER))
			continue
		var/datum/nifsoft/soulcatcher/SC = H.nif.imp_check(NIF_SOULCATCHER)
		if(!SC.visibility_check(ckey))
			continue
		filtered += H

	var/picked = tgui_input_list(usr, "Pick a friend with NIF and Soulcatcher to join into. Harrass strangers, get banned. Not everyone has a NIF w/ Soulcatcher.","Select a player", filtered)

	//Didn't pick anyone or picked a null
	if(!picked)
		return

	//Good choice testing and some instance-grabbing
	if(!ishuman(picked))
		to_chat(src,"<span class='warning'>[picked] isn't in a humanoid mob at the moment.</span>")
		return

	var/mob/living/carbon/human/H = picked

	if(H.stat || !H.client)
		to_chat(src,"<span class='warning'>[H] isn't awake/alive at the moment.</span>")
		return

	if(!H.nif)
		to_chat(src,"<span class='warning'>[H] doesn't have a NIF installed.</span>")
		return

	var/datum/nifsoft/soulcatcher/SC = H.nif.imp_check(NIF_SOULCATCHER)
	if(!SC?.visibility_check(ckey))
		to_chat(src,"<span class='warning'>[H] doesn't have the Soulcatcher NIFSoft installed, or their NIF is unpowered.</span>")
		return

	//Fine fine, we can ask.
	var/obj/item/nif/nif = H.nif
	to_chat(src,"<span class='notice'>Request sent to [H].</span>")

	if(client.persistent.ligma)
		sleep(rand(40,120))
		to_chat(src, SPAN_WARNING("[H] denied your request."))
		log_shadowban("[key_name(src)] SC join blocked.")
		return

	var/req_time = world.time
	nif.notify("Transient mindstate detected, analyzing...")
	sleep(15) //So if they are typing they get interrupted by sound and message, and don't type over the box
	var/response = tgui_alert(H,"[src] ([src.key]) wants to join into your Soulcatcher.","Soulcatcher Request",list("Deny","Allow"))

	if(response == "Deny")
		to_chat(src,"<span class='warning'>[H] denied your request.</span>")
		return

	if((world.time - req_time) > 1 MINUTES)
		to_chat(H,"<span class='warning'>The request had already expired. (1 minute waiting max)</span>")
		return

	//Final check since we waited for input a couple times.
	if(H && src && src.key && !H.stat && nif && SC)
		if(!mind) //No mind yet, aka haven't played in this round.
			mind = new(key)

		mind.name = name
		mind.current = src
		mind.active = TRUE

		SC.catch_mob(src) //This will result in us being deleted so...

/mob/observer/dead/verb/backup_ping()
	set category = "Ghost"
	set name = "Notify Transcore"
	set desc = "If your past-due backup notification was missed or ignored, you can use this to send a new one."

	if(src.mind.name in SStranscore.backed_up)
		var/datum/transhuman/mind_record/record = SStranscore.backed_up[src.mind.name]
		if(!(record.dead_state == MR_DEAD))
			to_chat(src, "<span class='warning'>Your backup is not past-due yet.</span>")
		else if((world.time - record.last_notification) < 10 MINUTES)
			to_chat(src, "<span class='warning'>Too little time has passed since your last notification.</span>")
		else
			SStranscore.notify(record.mindname, TRUE)
			record.last_notification = world.time
			to_chat(src, "<span class='notice'>New notification has been sent.</span>")
	else
		to_chat(src, "<span class='warning'>No mind record found!</span>")
