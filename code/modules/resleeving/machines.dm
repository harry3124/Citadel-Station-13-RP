////////////////////////////////
//// Machines required for body printing
//// and decanting into bodies
////////////////////////////////

/////// Grower Pod ///////
/obj/machinery/clonepod/transhuman
	name = "grower pod"
	catalogue_data = list(///datum/category_item/catalogue/information/organization/vey_med,
						/datum/category_item/catalogue/technology/resleeving)
	circuit = /obj/item/circuitboard/transhuman_clonepod

//A full version of the pod
/obj/machinery/clonepod/transhuman/full/Initialize(mapload)
	. = ..()
	for(var/i = 1 to container_limit)
		containers += new /obj/item/reagent_containers/glass/bottle/biomass(src)

/obj/machinery/clonepod/transhuman/growclone(datum/transhuman/body_record/current_project)
	//Manage machine-specific stuff.
	if(mess || attempting)
		return 0
	attempting = 1 //One at a time!!
	locked = 1
	eject_wait = 1
	spawn(30)
		eject_wait = 0

	// Remove biomass when the cloning is started, rather than when the guy pops out
	remove_biomass(CLONE_BIOMASS)

	//Get the DNA and generate a new mob
	var/datum/dna2/record/R = current_project.mydna
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)
	H.set_species(R.dna.species)
	H.dna.base_species = R.dna.base_species //! Hacky way to get the DNA to work.
	if(current_project.locked)
		H.resleeve_lock = current_project.ckey

	//Fix the external organs
	for(var/part in current_project.limb_data)

		var/status = current_project.limb_data[part]
		if(status == null) continue //Species doesn't have limb? Child of amputated limb?

		var/obj/item/organ/external/O = H.organs_by_name[part]
		if(!O) continue //Not an organ. Perhaps another amputation removed it already.

		if(status == 1) //Normal limbs
			continue
		else if(status == 0) //Missing limbs
			O.remove_rejuv()
		else if(status) //Anything else is a manufacturer
			O.remove_rejuv() //Don't robotize them, leave them removed so robotics can attach a part.

	//Look, this machine can do this because [reasons] okay?!
	for(var/part in current_project.organ_data)

		var/status = current_project.organ_data[part]
		if(status == null) continue //Species doesn't have organ? Child of missing part?

		var/obj/item/organ/I = H.internal_organs_by_name[part]
		if(!I) continue//Not an organ. Perhaps external conversion changed it already?

		if(status == 0) //Normal organ
			continue
		else if(status == 1) //Assisted organ
			I.mechassist()
		else if(status == 2) //Mechanical organ
			I.robotize()
		else if(status == 3) //Digital organ
			I.digitize()

	occupant = H

	//Set the name or generate one
	if(!R.dna.real_name)
		R.dna.real_name = "clone ([rand(0,999)])"
	H.real_name = R.dna.real_name

	//Apply DNA
	H.dna = R.dna.Clone()
	for(var/trait in H.dna.species_traits)
		if(!all_traits[trait])
			continue
		var/datum/trait/T = all_traits[trait]
		T.apply(H.species, H)
	H.original_player = current_project.ckey

	//Apply genetic modifiers
	for(var/modifier_type in R.genetic_modifiers)
		H.add_modifier(modifier_type)

	//Apply damage
	H.adjustCloneLoss((H.getMaxHealth() - H.getMinHealth())*-0.75)
	H.afflict_unconscious(20 * 4)
	H.update_health()

	//Grower specific mutations
	if(heal_level < 60)
		randmutb(H)
		H.dna.UpdateSE()
		H.dna.UpdateUI()

	//Update appearance, remake icons
	H.UpdateAppearance()
	H.sync_organ_dna()
	H.regenerate_icons()

	H.ooc_notes = current_project.body_oocnotes
	H.flavor_texts = current_project.mydna.flavor.Copy()
	H.resize(current_project.sizemult, FALSE)
	H.appearance_flags = current_project.aflags
	H.weight = current_project.weight
	if(current_project.speciesname)
		H.custom_species = current_project.speciesname

	//Suiciding var
	H.suiciding = 0

	//Making double-sure this is not set
	H.mind = null

	//Machine specific stuff at the end
	update_icon()
	attempting = 0
	return 1

/obj/machinery/clonepod/transhuman/process(delta_time)
	if(machine_stat & NOPOWER)
		if(occupant)
			locked = 0
			go_out()
		return

	if((occupant) && (occupant.loc == src))
		if(occupant.stat == DEAD)
			locked = 0
			go_out()
			connected_message("Clone Rejected: Deceased.")
			return

		else if(occupant.health < heal_level && occupant.getCloneLoss() > 0)

			 //Slowly get that clone healed and finished.
			occupant.adjustCloneLoss(-2 * heal_rate)

			//Premature clones may have brain damage.
			occupant.adjustBrainLoss(-(CEILING((0.5*heal_rate), 1)))

			//So clones don't die of oxyloss in a running pod.
			if(occupant.reagents.get_reagent_amount("inaprovaline") < 30)
				occupant.reagents.add_reagent("inaprovaline", 60)

			//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
			occupant.adjustOxyLoss(-4)

			use_power(7500) //This might need tweaking.
			return

		else if(((occupant.health >= heal_level) || (occupant.health == occupant.maxHealth)) && (!eject_wait))
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			audible_message("\The [src] signals that the growing process is complete.")
			connected_message("Growing Process Complete.")
			locked = 0
			go_out()
			return

	else if((!occupant) || (occupant.loc != src))
		occupant = null
		if(locked)
			locked = 0
		return

	return

//Synthetic version
/obj/machinery/transhuman/synthprinter
	name = "SynthFab 3000"
	desc = "A rapid fabricator for synthetic bodies."
	catalogue_data = list(///datum/category_item/catalogue/information/organization/vey_med,
						/datum/category_item/catalogue/technology/resleeving)
	icon = 'icons/obj/machines/synthpod.dmi'
	icon_state = "pod_0"
	circuit = /obj/item/circuitboard/transhuman_synthprinter
	density = 1
	anchored = 1

	var/list/stored_material =  list(MAT_STEEL = 30000, MAT_GLASS = 30000)
	var/connected      //What console it's done up with
	var/busy = 0       //Busy cloning
	var/body_cost = 15000  //Cost of a cloned body (metal and glass ea.)
	var/max_res_amount = 30000 //Max the thing can hold
	var/datum/transhuman/body_record/current_project
	var/broken = 0
	var/burn_value = 45
	var/brute_value = 60

/obj/machinery/transhuman/synthprinter/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/transhuman/synthprinter/RefreshParts()

	//Scanning modules reduce burn rating by 15 each
	var/burn_rating = initial(burn_value)
	for(var/obj/item/stock_parts/scanning_module/SM in component_parts)
		burn_rating = burn_rating - (SM.rating*15)
	burn_value = burn_rating

	//Manipulators reduce brute by 10 each
	var/brute_rating = initial(burn_value)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		brute_rating = brute_rating - (M.rating*10)
	brute_value = brute_rating

	//Matter bins multiply the storage amount by their rating.
	var/store_rating = initial(max_res_amount)
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		store_rating = store_rating * MB.rating
	max_res_amount = store_rating

/obj/machinery/transhuman/synthprinter/process(delta_time)
	if(machine_stat & NOPOWER)
		if(busy)
			busy = 0
			current_project = null
		update_icon()
		return

	if(busy > 0 && busy <= 95)
		busy += 5

	if(busy >= 100)
		make_body()

	return

/obj/machinery/transhuman/synthprinter/proc/print(var/datum/transhuman/body_record/BR)
	if(!istype(BR) || busy)
		return 0

	if(stored_material[MAT_STEEL] < body_cost || stored_material["glass"] < body_cost)
		return 0

	current_project = BR
	busy = 5
	update_icon()

	return 1

/obj/machinery/transhuman/synthprinter/proc/make_body()
	//Manage machine-specific stuff
	if(!current_project)
		busy = 0
		update_icon()
		return

	//Get the DNA and generate a new mob
	var/datum/dna2/record/R = current_project.mydna
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species)
	if(current_project.locked)
		H.resleeve_lock = current_project.ckey

	//Fix the external organs
	for(var/part in current_project.limb_data)

		var/status = current_project.limb_data[part]
		if(status == null) continue //Species doesn't have limb? Child of amputated limb?

		var/obj/item/organ/external/O = H.organs_by_name[part]
		if(!O) continue //Not an organ. Perhaps another amputation removed it already.

		if(status == 1) //Normal limbs
			continue
		else if(status == 0) //Missing limbs
			O.remove_rejuv()
		else if(status) //Anything else is a manufacturer
			O.robotize(status)

	//Then the internal organs
	for(var/part in current_project.organ_data)

		var/status = current_project.organ_data[part]
		if(status == null) continue //Species doesn't have organ? Child of missing part?

		var/obj/item/organ/I = H.internal_organs_by_name[part]
		if(!I) continue//Not an organ. Perhaps external conversion changed it already?

		if(status == 0) //Normal organ
			continue
		else if(status == 1) //Assisted organ
			I.mechassist()
		else if(status == 2) //Mechanical organ
			I.robotize()
		else if(status == 3) //Digital organ
			I.digitize()

	//Set the name or generate one
	if(!R.dna.real_name)
		R.dna.real_name = "synth ([rand(0,999)])"
	H.real_name = R.dna.real_name

	//Apply DNA
	H.dna = R.dna.Clone()
	H.original_player = current_project.ckey

	//Apply damage
	H.adjustBruteLoss(brute_value)
	H.adjustFireLoss(burn_value)
	H.update_health()

	//Update appearance, remake icons
	H.UpdateAppearance()
	H.sync_organ_dna()
	H.regenerate_icons()

	H.ooc_notes = current_project.body_oocnotes
	H.flavor_texts = current_project.mydna.flavor.Copy()
	H.resize(current_project.sizemult)
	H.appearance_flags = current_project.aflags
	H.weight = current_project.weight
	if(current_project.speciesname)
		H.custom_species = current_project.speciesname

	//Suiciding var
	H.suiciding = 0

	//Making double-sure this is not set
	H.mind = null

	//Plonk them here.
	H.regenerate_icons()
	H.loc = get_turf(src)

	//Machine specific stuff at the end
	stored_material[MAT_STEEL] -= body_cost
	stored_material["glass"] -= body_cost
	busy = 0
	update_icon()

	return 1

/obj/machinery/transhuman/synthprinter/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if((busy == 0) || (machine_stat & NOPOWER))
		return
	to_chat(user, "Current print cycle is [busy]% complete.")
	return

/obj/machinery/transhuman/synthprinter/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)
	if(busy)
		to_chat(user, "<span class='notice'>\The [src] is busy. Please wait for completion of previous operation.</span>")
		return
	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_deconstruction_crowbar(user, W))
		return
	if(default_part_replacement(user, W))
		return
	if(panel_open)
		to_chat(user, "<span class='notice'>You can't load \the [src] while it's opened.</span>")
		return
	if(!istype(W, /obj/item/stack/material))
		to_chat(user, "<span class='notice'>You cannot insert this item into \the [src]!</span>")
		return

	var/obj/item/stack/material/S = W
	if(!(S.material.name in stored_material))
		to_chat(user, "<span class='warning'>\the [src] doesn't accept [S.material]!</span>")
		return

	var/amnt = S.perunit
	if(stored_material[S.material.name] + amnt <= max_res_amount)
		if(S && S.amount >= 1)
			var/count = 0
			while(stored_material[S.material.name] + amnt <= max_res_amount && S.amount >= 1)
				stored_material[S.material.name] += amnt
				S.use(1)
				count++
			to_chat(user, "You insert [count] [S.name] into \the [src].")
	else
		to_chat(user, "\the [src] cannot hold more [S.name].")

	updateUsrDialog()
	return

/obj/machinery/transhuman/synthprinter/update_icon()
	..()
	icon_state = "pod_0"
	if(busy && !(machine_stat & NOPOWER))
		icon_state = "pod_1"
	else if(broken)
		icon_state = "pod_g"

/////// Resleever Pod ///////
/obj/machinery/transhuman/resleever
	name = "resleeving pod"
	desc = "Used to combine mind and body into one unit."
	catalogue_data = list(
		// /datum/category_item/catalogue/information/organization/vey_med,
		/datum/category_item/catalogue/technology/resleeving,
	)
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	circuit = /obj/item/circuitboard/transhuman_resleever
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	var/blur_amount
	var/confuse_amount

	var/mob/living/carbon/human/occupant = null
	var/connected = null

	var/sleevecards = 2

/obj/machinery/transhuman/resleever/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/transhuman/resleever/RefreshParts()
	var/scan_rating = 0
	for(var/obj/item/stock_parts/scanning_module/SM in component_parts)
		scan_rating += SM.rating
	confuse_amount = (48 - scan_rating * 8)

	var/manip_rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		manip_rating += M.rating
	blur_amount = (48 - manip_rating * 8)

/obj/machinery/transhuman/resleever/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	user.set_machine(src)
	var/health_text = ""
	var/mind_text = ""
	if(src.occupant)
		if(src.occupant.stat >= DEAD)
			health_text = "<FONT color=red>DEAD</FONT>"
		else if(src.occupant.health < 0)
			health_text = "<FONT color=red>[round(src.occupant.health,0.1)]</FONT>"
		else
			health_text = "[round(src.occupant.health,0.1)]"

		if(src.occupant.mind)
			mind_text = "Mind present: [occupant.mind.name]"
		else
			mind_text = "Mind absent."

	var/dat ="<B>Resleever Status</B><BR>"
	dat +="<B>Current occupant:</B> [src.occupant ? "<BR>Name: [src.occupant]<BR>Health: [health_text]<BR>" : "<FONT color=red>None</FONT>"]<BR>"
	dat +="<B>Mind status:</B> [mind_text]<BR>"
	user.set_machine(src)
	user << browse(HTML_SKELETON(dat), "window=resleever")
	onclose(user, "resleever")

/obj/machinery/transhuman/resleever/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)
	if(default_deconstruction_screwdriver(user, W))
		return
	if(default_deconstruction_crowbar(user, W))
		return
	if(default_part_replacement(user, W))
		return
	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(!ismob(G.affecting))
			return
/*
		for(var/mob/living/carbon/slime/M in range(1, G.affecting))
			if(M.Victim == G.affecting)
				to_chat(usr, "[G.affecting:name] will not fit into the [src.name] because they have a slime latched onto their head.")
				return
*/
		var/mob/M = G.affecting
		if(put_mob(M))
			qdel(G)
			src.updateUsrDialog()
			return //Don't call up else we'll get attack messsages
	if(istype(W, /obj/item/sleevecard))
		var/obj/item/sleevecard/C = W
		if(!user.attempt_consume_item_for_construction(C))
			return
		C.removePersonality()
		sleevecards++
		to_chat(user, SPAN_NOTICE("You store \the [C] in \the [src]."))

/obj/machinery/transhuman/resleever/MouseDroppedOnLegacy(mob/living/carbon/O, mob/user)
	if(!istype(O))
		return FALSE //not a mob
	if(user.incapacitated())
		return FALSE //user shouldn't be doing things
	if(O.anchored)
		return FALSE //mob is anchored???
	if(get_dist(user, src) > 1 || get_dist(user, O) > 1)
		return FALSE //doesn't use adjacent() to allow for non-GLOB.cardinal (fuck my life)
	if(!ishuman(user) && !isrobot(user))
		return FALSE //not a borg or human
	if(panel_open)
		to_chat(user, SPAN_NOTICE("Close the maintenance panel first."))
		return FALSE //panel open

	if(O.buckled)
		return FALSE
	if(O.has_buckled_mobs())
		to_chat(user, SPAN_WARNING( "\The [O] has other entities attached to it. Remove them first."))
		return

	if(put_mob(O))
		if(O == user)
			src.updateUsrDialog()
			visible_message("[user] climbs into \the [src].")
		else
			src.updateUsrDialog()
			visible_message("[user] puts [O] into \the [src].")

	add_fingerprint(user)

/obj/machinery/transhuman/resleever/MouseDroppedOnLegacy(mob/target, mob/user) //Allows borgs to put people into resleeving without external assistance
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user)|| !ishuman(target))
		return
	put_mob(target)

/obj/machinery/transhuman/resleever/proc/putmind(datum/transhuman/mind_record/MR, mode = 1, mob/living/carbon/human/override = null)
	if((!occupant || !istype(occupant) || occupant.stat >= DEAD) && mode == 1)
		return 0

	if(mode == 2 && sleevecards) //Card sleeving
		var/obj/item/sleevecard/card = new /obj/item/sleevecard(get_turf(src))
		card.sleeveInto(MR)
		sleevecards--
		return 1

	//If we're sleeving a subtarget, briefly swap them to not need to duplicate tons of code.
	var/mob/living/carbon/human/original_occupant
	if(override)
		original_occupant = occupant
		occupant = override

	//In case they already had a mind!
	if(occupant && occupant.mind)
		to_chat(occupant, SPAN_WARNING("You feel your mind being overwritten..."))
		log_and_message_admins("was resleeve-wiped from their body.",occupant.mind)
		occupant.ghostize()

	//Attach as much stuff as possible to the mob.
	for(var/datum/prototype/language/L in MR.languages)
		occupant.add_language(L.name)
	MR.mind_ref.active = 1 //Well, it's about to be.
	MR.mind_ref.transfer(occupant) //Does mind+ckey+client.
	occupant.identifying_gender = MR.id_gender
	occupant.ooc_notes = MR.mind_oocnotes
	occupant.apply_vore_prefs() //Cheap hack for now to give them SOME bellies.
	if(MR.one_time)
		var/how_long = round((world.time - MR.last_update)/10/60)
		to_chat(occupant,SPAN_DANGER("Your mind backup was a 'one-time' backup. \
		You will not be able to remember anything since the backup, [how_long] minutes ago."))

	//Re-supply a NIF if one was backed up with them.
	if(MR.nif_path)
		var/obj/item/nif/nif = new MR.nif_path(occupant,null,MR.nif_savedata)
		for(var/path in MR.nif_software)
			new path(nif)
		nif.durability = MR.nif_durability //Restore backed up durability after restoring the softs.

	// If it was a custom sleeve (not owned by anyone), update namification sequences
	if(!occupant.original_player)
		occupant.real_name = occupant.mind.name
		occupant.name = occupant.real_name
		occupant.dna.real_name = occupant.real_name

	//Give them a mirror
	var/obj/item/implant/mirror/new_imp = new()
	if(new_imp.handle_implant(occupant, BP_TORSO))
		new_imp.post_implant(occupant)

	//Inform them and make them a little dizzy.
	if(confuse_amount + blur_amount <= 16)
		to_chat(occupant, SPAN_NOTICE("You feel a small pain in your back as you're given a new mirror implant. Oh, and a new body. Your brain will struggle for some time to relearn its neurological pathways, and you may feel disorientation, moments of confusion, and random pain or spasms. You also feel a constant disconnect, and your body feels foreign. You can't shake the final thoughts and feelings of your past life, and they linger at the forefront of your memory. "))
	else
		to_chat(occupant, SPAN_WARNING("You feel a small pain in your back as you're given a new mirror implant. Oh, and a new body. Your brain will struggle for some time to relearn its neurological pathways, and you may feel disorientation, moments of confusion, and random pain or spasms. You also feel a constant disconnect, and your body feels foreign. You can't shake the final thoughts and feelings of your past life, and they linger at the forefront of your memory.  "))

	occupant.confused   = max(occupant.confused, confuse_amount)
	occupant.eye_blurry = max(occupant.eye_blurry, blur_amount)

	if(occupant.mind && occupant.original_player && occupant.mind.ckey != occupant.original_player)
		log_and_message_admins("is now a cross-sleeved character. Body originally belonged to [occupant.real_name]. Mind is now [occupant.mind.name].",occupant)

	if(original_occupant)
		occupant = original_occupant

	playsound(src, 'sound/machines/medbayscanner1.ogg', 100, TRUE) // Play our sound at the end of the mind injection!
	return 1

/obj/machinery/transhuman/resleever/proc/go_out(mob/M)
	if(!occupant)
		return
	occupant.forceMove(loc)
	occupant.update_perspective()
	occupant = null
	icon_state = "implantchair"
	return

/obj/machinery/transhuman/resleever/proc/put_mob(mob/living/carbon/human/M as mob)
	if(!ishuman(M))
		to_chat(usr, SPAN_WARNING("\The [src] cannot hold this!"))
		return
	if(occupant)
		to_chat(usr, SPAN_WARNING("\The [src] is already occupied!"))
		return
	M.stop_pulling()
	M.forceMove(src)
	M.update_perspective()
	occupant = M
	add_fingerprint(usr)
	icon_state = "implantchair_on"
	return TRUE

/obj/machinery/transhuman/resleever/verb/get_out()
	set name = "EJECT Occupant"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)
	if(usr.stat != CONSCIOUS)
		return
	src.go_out(usr)
	add_fingerprint(usr)
	return

/obj/machinery/transhuman/resleever/verb/move_inside()
	set name = "Move INSIDE"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)
	if(usr.stat != CONSCIOUS || machine_stat & (NOPOWER|BROKEN))
		return
	put_mob(usr)
	return
