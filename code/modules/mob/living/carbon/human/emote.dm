// todo: fucking refactor saycode
/mob/proc/emote_nosleep(var/act,var/m_type=1,var/message = null)
	set waitfor = FALSE
	emote(arglist(args))

/mob/living/carbon/human/emote(var/act,var/m_type=1,var/message = null)
	var/param = null
	var/datum/gender/T = GLOB.gender_datums[get_visible_gender()]
	if(istype(src, /mob/living/carbon/human/dummy))
		return
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	//if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
	//	act = copytext(act,1,length(act))

	var/muzzled = is_muzzled()
	//var/m_type = 1

	for(var/obj/item/organ/O in src.organs)
		for (var/obj/item/implant/I in O)
			if (I.implanted)
				I.trigger(act, src)

	if(src.stat == 2.0 && (act != "deathgasp"))
		return
	if(attempt_vr(src,"handle_emote_vr",list(act,m_type,message)))
		return // Custom Emote Handler
	switch(act)

		if ("airguitar")
			if (!src.restrained())
				message = "is strumming the air and headbanging like a safari chimp."
				m_type = 1

		//Machine-only emotes
		if("beep", "buzz", "buzz2", "chime", "die", "dwoop", "error", "honk", "no", "ping", "rcough", "rsneeze", "scary", "shutdown","startup", "warn", "ye", "yes")

			var/obj/item/organ/o = internal_organs_by_name[O_VOICE]
			if(!isSynthetic() && (!o || !(o.robotic >= ORGAN_ASSISTED)))
				to_chat(src, "<span class='warning'>You are not a synthetic.</span>")
				return

			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			var/display_msg = "beeps"
			var/use_sound = 'sound/machines/twobeep.ogg'
			if(act == "buzz")
				display_msg = "buzzes"
				use_sound = 'sound/machines/buzz-sigh.ogg'
			else if(act == "chime")
				display_msg = "chimes"
				use_sound = 'sound/machines/chime.ogg'
			else if(act == "buzz2")
				display_msg = "buzzes twice"
				use_sound = 'sound/machines/buzz-two.ogg'
			else if(act == "warn")
				display_msg = "blares an alarm"
				use_sound = 'sound/machines/warning-buzzer.ogg'
			else if(act == "honk")
				display_msg = "honks"
				use_sound = 'sound/items/bikehorn.ogg'
			else if(act == "ping")
				display_msg = "pings"
				use_sound = 'sound/machines/ping.ogg'
			else if(act == "yes" || act == "ye")
				display_msg = "emits an affirmative blip"
				use_sound = 'sound/machines/synth_yes.ogg'
			else if(act == "no")
				display_msg = "emits a negative blip"
				use_sound = 'sound/machines/synth_no.ogg'
			else if(act == "dwoop")
				display_msg = "chirps happily"
				use_sound = 'sound/machines/dwoop.ogg'
			else if(act == "scary")
				display_msg = "emits a disconcerting tone"
				use_sound = 'sound/machines/synth_scary.ogg'
			else if(act == "startup")
				display_msg = "chimes to life"
				use_sound = 'sound/machines/synth_startup.ogg'
			else if(act == "shutdown")
				display_msg = "emits a nostalgic tone as they fall silent"
				use_sound = 'sound/machines/synth_shutdown.ogg'
			else if(act == "error")
				display_msg = "experiences a system error"
				use_sound = 'sound/machines/synth_error.ogg'
			else if(act == "die")
				display_msg = "crumples, their chassis colder and more lifeless than usual"
				use_sound = 'sound/machines/synth_gameover.ogg'
			else if(act == "rcough")
				display_msg = "emits a robotic cough"
				if(get_gender() == FEMALE)
					use_sound = pick('sound/effects/mob_effects/f_machine_cougha.ogg','sound/effects/mob_effects/f_machine_coughb.ogg')
				else
					use_sound = pick('sound/effects/mob_effects/m_machine_cougha.ogg','sound/effects/mob_effects/m_machine_coughb.ogg', 'sound/effects/mob_effects/m_machine_coughc.ogg')
			else if(act == "rsneeze")
				display_msg = "emits a robotic sneeze"
				if(get_gender() == FEMALE)
					use_sound = 'sound/effects/mob_effects/machine_sneeze.ogg'
				else
					use_sound = 'sound/effects/mob_effects/f_machine_sneeze.ogg'

			if (param)
				message = "[display_msg] at [param]."
			else
				message = "[display_msg]."
			playsound(src.loc, use_sound, 50, 0)
			m_type = 1

		//Promethean-only emotes
		if("squish")
			if(species.bump_flag != SLIME) //This should definitely do it.
				to_chat(src, "<span class='warning'>You are not a slime thing!</span>")
				return
			playsound(src.loc, 'sound/effects/slime_squish.ogg', 50, 0) //Credit to DrMinky (freesound.org) for the sound.
			message = "squishes."
			m_type = 1

		// SHRIEK VOXXY ONLY
		if ("shriekloud")
			if(src.species.get_species_id() != SPECIES_ID_VOX)
				to_chat(src, "<span class='warning'>You aren't ear piercingly vocal enough!</span>")
				return
			playsound(src.loc, 'sound/voice/shrieksneeze.ogg', 50, 0)
			message = "gives a short sharp shriek!"
			m_type = 1

		if ("shriekshort")
			if(src.species.get_species_id() != SPECIES_ID_VOX)
				to_chat(src, "<span class='warning'>You aren't noisy enough!</span>")
				return
			playsound(src.loc, 'sound/voice/shriekcough.ogg', 50, 0)
			message = "gives a short, quieter shriek!"
			m_type = 1

		// SQUID GAMES
		if ("achime")
			if(src.species.get_species_id() != SPECIES_ID_ADHERENT)
				to_chat(src, "<span class='warning'>You aren't floaty enough!</span>")
				return
			playsound(src.loc, 'sound/machines/achime.ogg', 50, 0)
			message = "chimes!"
			m_type = 1

		//Xenomorph Hybrid
		if("xhiss")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/alien_hiss3.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xroar")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/alien_roar1.ogg', 50, 0)
			message = "roars!"
			m_type = 2

		if("xhiss2")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xhiss2.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xhiss3")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xhiss3.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xhiss4")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xhiss4.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xhiss5")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xhiss5.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xhiss6")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xhiss6.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xroar1")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xroar1.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xroar2")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xroar2.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xroar3")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xroar3.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xtalk1")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xtalk1.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xtalk2")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xtalk2.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xtalk3")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/xtalk3.ogg', 50, 0)
			message = "hisses!"
			m_type = 2

		if("xroar")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/alien_roar1.ogg', 50, 0)
			message = "roars!"
			m_type = 2

		if("xgrowl")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			playsound(src.loc, 'sound/voice/xenos/alien_growl1.ogg', 50, 0)
			message = "growls!"
			m_type = 2

		if("xkiss")
			if(src.species.get_species_id() != SPECIES_ID_XENOHYBRID)
				to_chat(src, "<span class='warning'>You aren't alien enough!</span>")
				return
			var/M = null
			if (param)
				for (var/mob/A in view(1,src.loc))
					if (param == A.name)
						M = A
						break
				if (!M)
					param = null

				if (param)
					message = "extends their inner jaw outwards giving [param] a kiss."
			m_type = 1

		if("kiss")
			var/next_to_target = FALSE
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						if(src.Adjacent(A))
							next_to_target = TRUE
						break
				if (!M)
					param = null

				if (param)
					var/distance_verb = next_to_target ? "kisses" : "blows a kiss at"
					message = "[distance_verb] [param]."
			else
				message = "makes a kissing mouth."
			m_type = 1

		if("smooch")
			if (param)
				var/M = null
				for (var/mob/A in view(1,src.loc))
					if (param == A.name)
						M = A
						break
				if (!M)
					param = null

				if (param)
					message = "smooches [param]."
			m_type = 1

		if ("blink")
			message = "blinks."
			m_type = 1

		if ("blink_r")
			message = "blinks rapidly."
			m_type = 1

		if ("bow")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "bows to [param]."
				else
					message = "bows."
			m_type = 1

		if ("custom")
			var/input = sanitize(input("Choose an emote to display.") as text|null)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = 1
			else if (input2 == "Hearable")
				if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
					return
				m_type = 2
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			return custom_emote(m_type, message)

		if ("me")

			//if(silent && silent > 0 && findtext(message,"\"",1, null) > 0)
			//	return //This check does not work and I have no idea why, I'm leaving it in for reference.

			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<font color='red'>You cannot send IC messages (muted).</font>")
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if ("salute")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "salutes to [param]."
				else
					message = "salutes."
			m_type = 1

		if ("fullsalute")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "salutes to [param]."
				else
					message = "salutes."

				playsound(src.loc, 'sound/misc/salute.ogg', 30, 0)
			m_type = 1


		if ("choke")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "clutches [T.his] throat desperately!"
				m_type = 1
			else
				if (!muzzled)
					message = "chokes!"
					m_type = 2
				else
					message = "makes a strong noise."
					m_type = 2

		if ("clap")
			if (!src.restrained())
				message = "claps."
				var/use_sound
				use_sound = pick('sound/misc/clapping.ogg','sound/voice/clap2.ogg','sound/voice/clap3.ogg','sound/voice/clap4.ogg')
				playsound(src.loc, use_sound, 50, 0)

		if("golfclap")
			if (!src.restrained())
				message = "claps very slowly."
				playsound(src.loc, 'sound/voice/golfclap.ogg', 50, 0)

		if ("flap")
			if (!src.restrained())
				message = "flaps [T.his] wings."
				m_type = 2
				if(HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT))
					m_type = 1

		if ("aflap")
			if (!src.restrained())
				message = "flaps [T.his] wings ANGRILY!"
				m_type = 2
				if(HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT))
					m_type = 1

		if("ara")
			message = "aras."
			var/use_sound
			use_sound = pick('sound/voice/ara_ara1.ogg','sound/voice/ara_ara2.ogg')
			playsound(src.loc, use_sound, 50, 0)

		if("uwu")
			message = "lets out a devious noise."
			playsound(src.loc, 'sound/voice/uwu.ogg', 50, 0)

		if ("drool")
			message = "drools."
			m_type = 1

		if ("eyebrow")
			message = "raises an eyebrow."
			m_type = 1

		if ("chuckle")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "appears to chuckle."
				m_type = 1
			else
				if (!muzzled)
					message = "chuckles."
					m_type = 2
				else
					message = "makes a noise."
					m_type = 2

		if ("twitch")
			message = "twitches."
			m_type = 1

		if ("twitch_v")
			message = "twitches violently."
			m_type = 1

		if ("faint")
			message = "faints."
			if(!IS_CONSCIOUS(src))
				return //Can't faint while asleep
			afflict_sleeping(20 * 10) //Short-short nap
			m_type = 1

		if("cough", "coughs")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "appears to cough!"
				m_type = 1
			else
				if(!muzzled)
					var/robotic = 0
					m_type = 2
					if(should_have_organ(O_LUNGS))
						var/obj/item/organ/internal/lungs/L = internal_organs_by_name[O_LUNGS]
						if(L && L.robotic == 2)	//Hard-coded to 2, incase we add lifelike robotic lungs
							robotic = 1
					if(!robotic)
						message = "coughs!"
						if(get_gender() == FEMALE)
							if(species.female_cough_sounds)
								playsound(src, pick(species.female_cough_sounds), 120)
						else
							if(species.male_cough_sounds)
								playsound(src, pick(species.male_cough_sounds), 120)
					else
						message = "emits a robotic cough"
						var/use_sound
						if(get_gender() == FEMALE)
							use_sound = pick('sound/effects/mob_effects/f_machine_cougha.ogg','sound/effects/mob_effects/f_machine_coughb.ogg')
						else
							use_sound = pick('sound/effects/mob_effects/m_machine_cougha.ogg','sound/effects/mob_effects/m_machine_coughb.ogg', 'sound/effects/mob_effects/m_machine_coughc.ogg')
						playsound(src.loc, use_sound, 50, 0)
				else
					message = "makes a strong noise."
					m_type = 2

		if("bcough")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "appears to cough up blood!"
				m_type = 1
			else
				if(!muzzled)
					var/robotic = 0
					m_type = 2
					if(should_have_organ(O_LUNGS))
						var/obj/item/organ/internal/lungs/L = internal_organs_by_name[O_LUNGS]
						if(L && L.robotic == 2)	//Hard-coded to 2, incase we add lifelike robotic lungs
							robotic = 1
					if(!robotic)
						message = "coughs up a small amount of blood!"
						//! disabled for shitcode reasons
						// BloodyMouth()
						if(get_gender() == FEMALE)
							if(species.female_cough_sounds)
								playsound(src, pick(species.female_cough_sounds), 120)
						else
							if(species.male_cough_sounds)
								playsound(src, pick(species.male_cough_sounds), 120)

		if ("frown")
			message = "frowns."
			m_type = 1

		if ("nod")
			message = "nods."
			m_type = 1

		if ("blush")
			message = "blushes."
			m_type = 1

		if ("wave")
			message = "waves."
			m_type = 1

		if ("gasp")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "appears to be gasping!"
				m_type = 1
			else
				if (!muzzled)
					message = "gasps!"
					m_type = 2
				else
					message = "makes a weak noise."
					m_type = 2

		if ("deathgasp")
			message = "[species.get_death_message()]"
			m_type = 1

		if ("giggle")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "giggles silently!"
				m_type = 1
			else
				if (!muzzled)
					message = "giggles."
					m_type = 2
				else
					message = "makes a noise."
					m_type = 2

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "glares at [param]."
			else
				message = "glares."

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "stares at [param]."
			else
				message = "stares."

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break

			if (!M)
				param = null

			if (param)
				message = "looks at [param]."
			else
				message = "looks."
			m_type = 1

		if ("grin")
			message = "grins."
			m_type = 1

		if ("cry")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "cries."
				m_type = 1
			else
				if (!muzzled)
					message = "cries."
					m_type = 2
				else
					message = "makes a weak noise. [T.he] [get_visible_gender() == NEUTER ? "frown" : "frowns"]." // no good, non-unwieldy alternative to this ternary at the moment
					m_type = 2

		if ("sigh")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "sighs."
				m_type = 1
			else
				if (!muzzled)
					message = "sighs."
					m_type = 2
				else
					message = "makes a weak noise."
					m_type = 2

		if ("laugh")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "acts out a laugh."
				m_type = 1
			else
				if (!muzzled)
					var/list/laughs = list("lets out a chuckle.", "laughs.", "chuckles.", "cracks up.", "erupts into laughter.", "cackles.")
					message = "[pick(laughs)]"
					if(!spam_flag)
						if(get_gender() == MALE)
							var/list/laughsounds = list('sound/voice/laughs/masclaugh1.ogg', 'sound/voice/laughs/masclaugh2.ogg')
							playsound(loc, pick(laughsounds), 50, 1, -1)
							spam_flag = TRUE
							addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)
						else
							playsound(loc, 'sound/voice/laughs/femlaugh.ogg', 50, 1, -1)
							spam_flag = TRUE
							addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)
					m_type = 2
				else
					message = "makes a noise."
					m_type = 2

		if ("mumble")
			message = "mumbles!"
			m_type = 2
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				m_type = 1

		if ("grumble")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "grumbles!"
				m_type = 1
			if (!muzzled)
				message = "grumbles!"
				m_type = 2
			else
				message = "makes a noise."
				m_type = 2

		if ("groan")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "appears to groan!"
				m_type = 1
			else
				if (!muzzled)
					message = "groans!"
					m_type = 2
				else
					message = "makes a loud noise."
					m_type = 2

		if ("moan")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "appears to moan!"
				m_type = 1
			else
				message = "moans!"
				m_type = 2

		if ("johnny")
			var/M
			if (param)
				M = param
			if (!M)
				param = null
			else
				if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
					message = "takes a drag from a cigarette and blows \"[M]\" out in smoke."
					m_type = 1
				else
					message = "says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows his name out in smoke."
					m_type = 2

		if ("point")
			if (!src.restrained())
				var/mob/M = null
				if (param)
					for (var/atom/A as mob|obj|turf|area in view(null, null))
						if (param == A.name)
							M = A
							break

				if (!M)
					message = "points."
				else
					pointed(M)

				if (M)
					message = "points to [M]."
				else
			m_type = 1

		if("crack")
			if(!restrained())
				message = "cracks [T.his] knuckles."
				playsound(src, 'sound/voice/knuckles.ogg', 50, 1,)
				m_type = 1

		if ("raise")
			if (!src.restrained())
				message = "raises a hand."
			m_type = 1

		if("shake")
			message = "shakes [T.his] head."
			m_type = 1

		if ("shrug")
			message = "shrugs."
			m_type = 1

		if ("signal")
			if (!src.restrained())
				var/t1 = round(text2num(param))
				if (isnum(t1) && t1 <= (count_empty_hands() * 5))
					message = "raises [t1] finger\s."
			m_type = 1

		if ("smile")
			message = "smiles."
			m_type = 1

		if ("shiver")
			message = "shivers."
			m_type = 2
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				m_type = 1

		if ("pale")
			message = "goes pale for a second."
			m_type = 1

		if ("tremble")
			message = "trembles in fear!"
			m_type = 1

		if("sneeze", "sneezes")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "sneezes."
				m_type = 1
			else
				if(!muzzled)
					var/robotic = 0
					m_type = 2
					if(should_have_organ(O_LUNGS))
						var/obj/item/organ/internal/lungs/L = internal_organs_by_name[O_LUNGS]
						if(L && L.robotic == 2)	//Hard-coded to 2, incase we add lifelike robotic lungs
							robotic = 1
					if(!robotic)
						message = "sneezes."
						if(get_gender() == FEMALE)
							playsound(src, species.female_sneeze_sound, 70)
						else
							playsound(src, species.male_sneeze_sound, 70)
						m_type = 2
					else
						message = "emits a robotic sneeze"
						var/use_sound
						if(get_gender() == FEMALE)
							use_sound = 'sound/effects/mob_effects/machine_sneeze.ogg'
						else
							use_sound = 'sound/effects/mob_effects/f_machine_sneeze.ogg'
						playsound(src.loc, use_sound, 50, 0)
				else
					message = "makes a strange noise."
					m_type = 2

		if ("sniff")
			message = "sniffs."
			m_type = 2
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				m_type = 1

		if ("snore")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "sleeps soundly."
				m_type = 1
			else
				if (!muzzled)
					message = "snores."
					m_type = 2
				else
					message = "makes a noise."
					m_type = 2

		if ("whimper")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "appears hurt."
				m_type = 1
			else
				if (!muzzled)
					message = "whimpers."
					m_type = 2
				else
					message = "makes a weak noise."
					m_type = 2

		if ("wink")
			message = "winks."
			m_type = 1

		if ("yawn")
			if (!muzzled)
				message = "yawns."
				m_type = 2
				if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
					m_type = 1

		if ("collapse")
			afflict_unconscious(20 * 2)
			message = "collapses!"
			m_type = 2
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				m_type = 1

		if("hug")
			m_type = 1
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					message = "hugs [M]."
				else
					message = "hugs [T.himself]."

		if ("handshake")
			m_type = 1
			if (!restrained() && !are_usable_hands_full())
				var/mob/living/M = null
				if (param)
					for (var/mob/living/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if (CHECK_MOBILITY(M, MOBILITY_CAN_USE))
						message = "shakes hands with [M]."
					else
						message = "holds out [T.his] hand to [M]."

		if("dap")
			m_type = 1
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M)
					message = "gives daps to [M]."
				else
					message = "sadly can't find anybody to give daps to, and daps [T.himself]. Shameful."

		if("slap", "slaps")
			m_type = 1
			if(!restrained())
				var/M = null
				if(param)
					for(var/mob/A in view(1, null))
						if(param == A.name)
							M = A
							break
				if(M)
					message = "<span class='danger'>slaps [M] across the face. Ouch!</span>"
					playsound(src, 'sound/effects/snap.ogg', 50, 1)
					if(ishuman(M)) //Snowflakey!
						var/mob/living/carbon/human/H = M
						if(istype(H.wear_mask,/obj/item/clothing/mask/smokable))
							H.drop_item_to_ground(H.wear_mask)
				else
					message = "<span class='danger'>slaps [T.himself]!</span>"
					playsound(loc, 'sound/effects/snap.ogg', 50, 1)

//Citadel changes starts here
		if ("fguns")
			message = "points some fingerguns."
			m_type = 1

		if("aslap", "aslaps")
			m_type = 1
			var/mob/living/carbon/human/H = src
			var/obj/item/organ/external/L = H.get_organ("l_hand")
			var/obj/item/organ/external/R = H.get_organ("r_hand")
			var/left_hand_good = 0
			var/right_hand_good = 0
			if(L && (!(L.status & ORGAN_DESTROYED)) && (!(L.splinted)) && (!(L.status & ORGAN_BROKEN)))
				left_hand_good = 1
			if(R && (!(R.status & ORGAN_DESTROYED)) && (!(R.splinted)) && (!(R.status & ORGAN_BROKEN)))
				right_hand_good = 1

			if(!left_hand_good && !right_hand_good)
				to_chat(usr, "You need at least one hand in good working order to slap someone.")
				return
			if(!restrained())
				var/M = null
				if(param)
					for(var/mob/A in view(1, null))
						if(param == A.name)
							M = A
							break
				if(M)
					message = "<span class='danger'>slaps [M]'s butt.</span>"
					playsound(loc, 'sound/effects/snap.ogg', 50, 1)
					add_attack_logs(src,M,"Buttslap")
				else
					message = "<span class='danger'>slaps [T.his] own butt!</span>"
					playsound(loc, 'sound/effects/snap.ogg', 50, 1)
					add_attack_logs(src,src,"Slapped own butt")
					//adding damage for aslaps to stop the spam

		if("scream", "screams")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "acts out a scream!"
				m_type = 1
			else
				if(!muzzled)
					message = "[species.scream_verb]!"
					m_type = 2
					if(get_gender() == FEMALE)
						if(!spam_flag)
							playsound(loc, "[pick(species.female_scream_sound)]", 80, 1)
							spam_flag = TRUE
							addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)

					else
						if(!spam_flag)
							playsound(loc, "[pick(species.male_scream_sound)]", 80, 1) //default to male screams if no gender is present.
							spam_flag = TRUE
							addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)
				else
					message = "makes a very loud noise."
					m_type = 2
		if("squeak","squeaks")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "acts out a soft squeak."
				m_type = 1
			else
				if(!muzzled)
					message = "squeaks!"
					m_type = 2
					playsound(loc, "sound/effects/mouse_squeak.ogg", 50, 1)

		if("meow", "meows")
			if HAS_TRAIT_FROM(src, TRAIT_MUTE, MIME_TRAIT)
				message = "acts out a soft mrowl."
				m_type = 1
			else
				if(!muzzled)
					message = "mrowls!"
					m_type = 2
					playsound(loc, 'sound/voice/meow1.ogg', 50, 1)

		if("snap", "snaps")
			m_type = 2
			var/mob/living/carbon/human/H = src
			var/obj/item/organ/external/L = H.get_organ("l_hand")
			var/obj/item/organ/external/R = H.get_organ("r_hand")
			var/left_hand_good = 0
			var/right_hand_good = 0
			if(L && (!(L.status & ORGAN_DESTROYED)) && (!(L.splinted)) && (!(L.status & ORGAN_BROKEN)))
				left_hand_good = 1
			if(R && (!(R.status & ORGAN_DESTROYED)) && (!(R.splinted)) && (!(R.status & ORGAN_BROKEN)))
				right_hand_good = 1

			if(!left_hand_good && !right_hand_good)
				to_chat(usr, "You need at least one hand in good working order to snap your fingers.")
				return

			message = "snaps [T.his] fingers."
			playsound(loc, 'sound/effects/fingersnap.ogg', 50, 1, -3)

		if("swish")
			src.animate_tail_once()

		if("wag", "sway")
			src.toggle_tail_vr()
			// src.animate_tail_start()

		if("qwag", "fastsway")
			src.toggle_tail_vr()
			// src.animate_tail_fast()

		if("swag", "stopsway")
			src.animate_tail_stop()

		if("vomit")
			if(isSynthetic())
				to_chat(src, "<span class='warning'>You are unable to vomit.</span>")
				return
			vomit()
			return

		if("whistle", "whistles")
			if(!muzzled)
				message = "whistles a tune."
				playsound(loc, 'sound/misc/longwhistle.ogg') //praying this doesn't get abused
			else
				message = "makes a light spitting noise, a poor attempt at a whistle."

		if("qwhistle")
			if(!muzzled)
				message = "whistles quietly."
				playsound(loc, 'sound/misc/shortwhistle.ogg')
			else
				message = "makes a light spitting noise, a poor attempt at a whistle."

		if ("roll")
			var/usage = "To use this emote specify what die you want to roll in the first line. Prefix it with a \"D\". You may add a bonus to your roll, simply add a \"+\" and your number after your chosen die. If you want to incorporate a difficulty check, add a \"-DC\". You may use a bonus, a difficulty check or both.<br>Here is an example: roll-D20+5-DC15. This will roll a twenty-sided die, add five and compare it against a difficulty check of 15."
			if(!param)
				to_chat(src, usage)
				return

			var/t1 = findtext(param, "+", 1, null)
			var/t2 = findtext(param, "-", 1, null)
			var/die = copytext(param, 1, t1)
			var/bonus = copytext(param, t1 + 1, t2)
			var/dc = copytext(param, t2 + 1, length(param) + 1 )
			if (!t1)
				bonus = null
			if (!t2)
				dc = null
			var/die_number = text2num(copytext(die, 2, length(die) + 1))
			var/bonus_number = text2num(bonus)
			var/dc_number = text2num(copytext(dc, 3, length(dc) + 1))

			var/die_result = rand(die_number - 1) + 1
			var/die_total = die_result + bonus_number

			if (die_number && bonus_number && dc_number)
				if (die_total >= dc_number)
					message = SPAN_GREEN("tries something. They succeed, beating a difficulty check of [dc_number] with a roll of [die_result] + [bonus_number] for a total of [die_total] out of a possible [die_number + bonus_number]!")
				if (die_total < dc_number)
					message = SPAN_RED("tries something. They fail, losing to a difficulty check of [dc_number] with a roll of [die_result] + [bonus_number] for a total of [die_total] out of a possible [die_number + bonus_number]!")

			else if (die_number && dc_number)
				if (die_result >= dc_number)
					message = SPAN_GREEN("tries something. They succeed, beating a difficulty check of [dc_number] with a roll of [die_total] out of [die_number]!")
				if (die_result < dc_number)
					message = SPAN_RED("tries something. They fail, losing to a difficulty check of [dc_number] with a roll of [die_total] out of [die_number]!")

			else if (die_number && bonus_number)
				message = "tries something. They roll a [die_result] + [bonus_number] for a total of [die_total] out of a possible [die_number + bonus_number]!"

			else if (die_number)
				message = "tries something. They roll a [die_result] out of [die_number]!"

			else if (!message)
				to_chat(src, usage)
				return

		if ("help")
			to_chat(src, "ara, awoo, bark, bleat, blink, blink_r, blush, bow-(none)/mob, burp, chirp, choke, chuckle, clap, collapse, cough, cry, custom, deathgasp, drool, echoping, eyebrow, fastsway/qwag, \
					flip, frown, gasp, giggle, glare-(none)/mob, grin, groan, grumble, growl, handshake, hiss, howl, hug-(none)/mob, laugh, look-(none)/mob, mar, merp, moan, mrrp, mumble, nod, nya, nyaha, pale, peep, point-atom, prbt, \
					raise, roll, salute, fullsalute, scream, sneeze, shake, shiver, shrug, sigh, signal-#1-10, slap-(none)/mob, smile, sneeze, sniff, snore, stare-(none)/mob, stopsway/swag, squeak, sway/wag, swish, tremble, twitch, \
					twitch_v, uwu, vomit, weh, whimper, wink, yawn, ycackle. Moth: mchitter, mlaugh, mscream, msqueak. Synthetics: airhorn, beep, buzz, buzz2, chime, die, dwoop, error, honk, no, ping, rcough, rsneeze, scary, \
					shutdown, startup, steam, warn, ye, yes. Vox: shriekshort, shriekloud")

		else
			to_chat(src, "<font color=#4F49AF>Unusable emote '[act]'. Say *help for a list.</font>")
			return

	if (message)
		custom_emote(m_type,message)



/mob/living/carbon/human/proc/set_pose(new_pose)
	pose = sanitize(new_pose)

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = VERB_CATEGORY_IC

	var/datum/gender/T = GLOB.gender_datums[get_visible_gender()]

	var/old_pose = pose

	var/new_pose =  input(usr, "This is [src]. [T.He]...", "Pose", null)  as text|null

	set_pose(new_pose)

	if (length(pose)>0 && pose != old_pose)
		visible_emote("adjusts [T.his] posture. [T.He] [pose]")

/mob/living/carbon/human/verb/timed_pose()
	set name = "Set Pose (Temporary)"
	set desc = "Sets a description which will be shown when someone examines you, expiring after a given number of seconds."
	set category = VERB_CATEGORY_IC
	var/datum/gender/T = GLOB.gender_datums[get_visible_gender()]

	var/old_pose = pose

	var/new_pose =  input(usr, "This is [src]. [T.He]...", "Pose", null)  as text|null

	var/time = input(usr, "How long should the pose be visible (in seconds)?","Pose",60) as num|null

	set_pose(new_pose)

	if (length(pose)>0 && pose != old_pose)
		visible_emote("adjusts [T.his] posture. [T.He] [pose]")
		addtimer(CALLBACK(src,PROC_REF(set_pose),""),time SECONDS)


/mob/living/carbon/human/verb/silent_pose()
	set name = "Set Pose (Stealth)"
	set desc = "Sets a description which will be shown when someone examines you, without showing an adjustment message."
	set category = VERB_CATEGORY_IC
	var/datum/gender/T = GLOB.gender_datums[get_visible_gender()]

	var/new_pose=input(usr, "This is [src]. [T.he]...", "Pose", null)  as text|null
	set_pose(new_pose)



/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = VERB_CATEGORY_IC

	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Update Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=general'>General:</a> "
	HTML += TextPreview(flavor_texts["general"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=head'>Head:</a> "
	HTML += TextPreview(flavor_texts["head"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=face'>Face:</a> "
	HTML += TextPreview(flavor_texts["face"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=eyes'>Eyes:</a> "
	HTML += TextPreview(flavor_texts["eyes"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=torso'>Body:</a> "
	HTML += TextPreview(flavor_texts["torso"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=arms'>Arms:</a> "
	HTML += TextPreview(flavor_texts["arms"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=hands'>Hands:</a> "
	HTML += TextPreview(flavor_texts["hands"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=legs'>Legs:</a> "
	HTML += TextPreview(flavor_texts["legs"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=feet'>Feet:</a> "
	HTML += TextPreview(flavor_texts["feet"])
	HTML += "<br>"
	HTML += "<hr />"
	HTML +="<a href='?src=\ref[src];flavor_change=done'>\[Done\]</a>"
	HTML += "<tt>"
	src << browse(HTML, "window=flavor_changes;size=430x300")

/mob/living/carbon/human/proc/handle_emote_vr(var/act,var/m_type=1,var/message = null)

	switch(act)
		if ("vwag")
			if(toggle_tail_vr(message = 1))
				m_type = 1
				message = "[get_sprite_accessory_variation(SPRITE_ACCESSORY_SLOT_TAIL, SPRITE_ACCESSORY_VARIATION_WAGGING) ? "starts" : "stops"] wagging their tail."
			else
				return 1
		if ("vflap")
			if(toggle_wing_vr(message = 1))
				m_type = 1
				message = "[get_sprite_accessory_variation(SPRITE_ACCESSORY_SLOT_WINGS, SPRITE_ACCESSORY_VARIATION_FLAPPING) ? "starts" : "stops"] flapping their wings."
			else
				return 1
		if ("vspread")
			if(toggle_wing_spread(message = 1))
				m_type = 1
				message = "[get_sprite_accessory_variation(SPRITE_ACCESSORY_SLOT_WINGS, SPRITE_ACCESSORY_VARIATION_SPREAD) ? "extends" : "retracts"] their wings."
			else
				return 1
		if ("mlem")
			message = "mlems [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] tongue up over [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] nose. Mlem."
			m_type = 1
///////////////////////// EMOTES PORTED FROM MAIN START
		if ("awoo")
			m_type = 2
			message = "lets out an awoo."
			playsound(loc, 'sound/voice/awoo.ogg', 50, 1, -1)
		if ("nya")
			message = "lets out a nya."
			m_type = 2
			var/use_sound
			use_sound = pick('sound/voice/nya.ogg')
			playsound(src.loc, use_sound, 50, 0)
		if ("nyaha")
			if(!spam_flag)
				var/list/catlaugh = list('sound/voice/catpeople/nyaha.ogg', 'sound/voice/catpeople/nyahaha1.ogg', 'sound/voice/catpeople/nyahaha2.ogg', 'sound/voice/catpeople/nyahehe.ogg')
				playsound(loc, pick(catlaugh), 50, 1, -1)
				spam_flag = TRUE
				addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)
			var/list/laughs = list("laughs deviously.", "lets out a catty laugh.", "nya ha ha's.")
			message = "[pick(laughs)]"
			m_type = 2
		if ("peep")
			message = "peeps like a bird."
			m_type = 2
			playsound(loc, 'sound/voice/peep.ogg', 50, 1, -1)
		if("chirp")
			message = "chirps!"
			playsound(src.loc, 'sound/misc/nymphchirp.ogg', 50, 0)
			m_type = 2
		if("prbt")
			message = "prbts."
			playsound(src.loc, 'sound/misc/prbt.ogg', 50, 1, -1)
			m_type = 2
		if ("mrrp")
			message = "mrrps."
			m_type = 2
			playsound(src.loc, "sound/voice/mrrp.ogg", 50, 1, -1)
		if ("weh")
			message = "lets out a weh."
			m_type = 2
			playsound(loc, 'sound/voice/weh.ogg', 50, 1, -1)
		if ("merp")
			message = "lets out a merp."
			m_type = 2
			playsound(loc, 'sound/voice/merp.ogg', 50, 1, -1)
		if ("bleat")
			message = "bleats!"
			m_type = 2
			playsound(loc, pick(list('sound/voice/baa.ogg','sound/voice/baa2.ogg')), 50, 1, -1)
		if ("bark")
			message = "lets out a bark."
			m_type = 2
			playsound(loc, 'sound/voice/bark2.ogg', 50, 1, -1)
		if ("hiss")
			message = "lets out a hiss."
			m_type = 2
			playsound(loc, 'sound/voice/hiss.ogg', 50, 1, -1)
		if ("squeak")
			message = "lets out a squeak."
			m_type = 2
			playsound(loc, 'sound/effects/mouse_squeak.ogg', 50, 1, -1)
		if("mar")
			message = "lets out a mar."
			m_type = 2
			playsound(loc, 'sound/voice/mar.ogg', 50, 1, -1)
		if ("nsay")
			nsay()
			return TRUE
		if ("nme")
			nme()
			return TRUE
		if ("mchitter")
			message = "chitters."
			m_type = 2
			playsound(loc, 'sound/voice/moth/mothchitter.ogg', 50, 1, -1)
		if ("mlaugh")
			message = "laughs."
			m_type = 2
			playsound(loc, 'sound/voice/moth/mothlaugh.ogg', 50, 1, -1)
		if ("mscream")
			message = "screams!"
			m_type = 2
			playsound(loc, 'sound/voice/moth/scream_moth.ogg', 50, 1, -1)
		if ("msqueak")
			message = "lets out a squeak."
			m_type = 2
			playsound(loc, 'sound/voice/moth/mothsqueak.ogg', 50, 1, -1)
		if ("flip")
			var/list/involved_parts = list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)
			//Check if they are physically capable
			if(!CHECK_MOBILITY(src, MOBILITY_CAN_MOVE) || involved_parts.len < 2)
				to_chat(src, "<span class='warning'>You can't *flip in your current state!</span>")
				return 1
			else
				m_type = 1
				if(!spam_flag)
					src.SpinAnimation(7,1)
					message = "does a flip!"
					spam_flag = TRUE
					addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)
				else
					if(prob(30)) // Little known fact: HRP is /tg/ + 10
						src.afflict_paralyze(20 * 2)
						if(prob(50))
							src.adjustBruteLoss(1)
							message = "attempts to do a flip and falls on their face. Ouch!"
						else
							message = "attempts to do a flip and falls over, what a doofus!"
					else
						src.SpinAnimation(7,1)
						message = "lands another flip. Smooth!"
						spam_flag = TRUE
						addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)

// New emotes below this line
		if ("purr")
			message = "purrs softly."
			m_type = 2
			playsound(loc, 'sound/voice/purr.ogg', 50, 1, -1)
		if ("clak")
			if(!spam_flag)
				var/msg = list("<font color='grey' size='2'>CLAKS!</font>", "claks!")
				message = "[pick(msg)]"
				playsound(loc, 'sound/spooky/boneclak.ogg', 50, 1, 1)
				spam_flag = TRUE
				addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)
			m_type = 2
		if ("ycackle")
			message = "cackles maniacally!"
			m_type = 2
			playsound(loc, pick(list('sound/voice/YeenCackle.ogg','sound/voice/YeenCackle2.ogg','sound/voice/YeenCackle3.ogg')), 50, 1, -1)
		if ("growl")
			message = "growls!"
			m_type = 2
			playsound(loc, pick(list('sound/voice/growl1.ogg','sound/voice/growl2.ogg','sound/voice/growl3.ogg')), 10, 1, -1)
		if ("howl")
			message = "howls!"
			m_type = 2
			playsound(loc, pick(list('sound/voice/howl1.ogg','sound/voice/howl2.ogg','sound/voice/howl3.ogg')), 30, 1, -1)
			spam_flag = TRUE
			addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)
		if ("echoping")
			message = "emits a strange noise that echos throughout the place..."
			m_type = 2
			playsound(loc, pick(list('sound/voice/echoping1.ogg','sound/voice/echoping2.ogg','sound/voice/echoping3.ogg')), 40, 1, -1)
			spam_flag = TRUE
			addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)
		if ("airhorn")
			var/obj/item/organ/o = internal_organs_by_name[O_VOICE]
			if(!isSynthetic() && (!o || !(o.robotic >= ORGAN_ASSISTED)))
				to_chat(src, "<span class='warning'>You are not a synthetic.</span>")
				return
			message = "blares a horn!"
			m_type = 2
			playsound(loc, 'sound/items/airhorn2.ogg', 20, 1, 1)
			spam_flag = TRUE
			addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)
		if ("steam")
			var/obj/item/organ/o = internal_organs_by_name[O_VOICE]
			if(!isSynthetic() && (!o || !(o.robotic >= ORGAN_ASSISTED)))
				to_chat(src, "<span class='warning'>You are not a synthetic.</span>")
				return
			message = "lets off some steam."
			m_type = 2
			playsound(loc, 'sound/machines/clockcult/steam_whoosh.ogg', 30, 1, 1)
			spam_flag = TRUE
			addtimer(CALLBACK(src, PROC_REF(spam_flag_false)), 18)

	if (message)
		custom_emote(m_type,message)
		return 1

	return 0

/mob/living/carbon/human/proc/spam_flag_false() //used for addtimer
	spam_flag = FALSE

/mob/living/carbon/human/verb/toggle_gender_identity_vr()
	set name = "Set Gender Identity"
	set desc = "Sets the pronouns when examined and performing an emote."
	set category = VERB_CATEGORY_IC
	var/new_gender_identity = input("Please select a gender Identity.") as null|anything in list(FEMALE, MALE, NEUTER, PLURAL, HERM)
	if(!new_gender_identity)
		return 0
	change_gender_identity(new_gender_identity)
	return 1
