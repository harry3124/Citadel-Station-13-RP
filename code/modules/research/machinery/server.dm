/obj/machinery/r_n_d/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"

	var/datum/research/files
	///List of R&D consoles with upload to server access.
	var/list/id_with_upload = list()
	///List of R&D consoles with download from server access.
	var/list/id_with_download = list()
	///String versions for easy editing in map editor.
	var/id_with_upload_string = ""
	var/id_with_download_string = ""
	var/server_id = 0
	var/produces_heat = TRUE
	idle_power_usage = 800
	var/delay = 10
	var/health = 100
	req_access = list(ACCESS_SCIENCE_RD) //Only the R&D can change server settings.
	circuit = /obj/item/circuitboard/rdserver

/obj/machinery/r_n_d/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src)
		tot_rating += SP.rating
	idle_power_usage /= max(1, tot_rating)

/obj/machinery/r_n_d/server/Initialize(mapload)
	. = ..()
	if(!files)
		files = new /datum/research(src)
	var/list/temp_list
	if(!id_with_upload.len)
		temp_list = list()
		temp_list = splittext(id_with_upload_string, ";")
		for(var/N in temp_list)
			id_with_upload += text2num(N)
	if(!id_with_download.len)
		temp_list = list()
		temp_list = splittext(id_with_download_string, ";")
		for(var/N in temp_list)
			id_with_download += text2num(N)

/obj/machinery/r_n_d/server/process(delta_time)
	var/datum/gas_mixture/environment = loc.return_air()
	switch(environment.temperature)
		if(0 to T0C)
			health = min(100, health + 1)
		if(T0C to (T20C + 20))
			health = clamp( health, 0,  100)
		if((T20C + 20) to (T0C + 70))
			health = max(0, health - 1)
	if(health <= 0)
		files.known_design_ids = list()
		for(var/datum/tech/T in files.known_tech)
			if(prob(1))
				T.level--
		files.RefreshResearch()
	if(delay)
		delay--
	else
		produce_heat()
		delay = initial(delay)

/obj/machinery/r_n_d/server/proc/produce_heat()
	if(!produces_heat)
		return

	if(!use_power)
		return

	if(!(machine_stat & (NOPOWER|BROKEN))) //Blatently stolen from telecoms
		var/turf/simulated/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()

			var/transfer_moles = 0.25 * env.total_moles

			var/datum/gas_mixture/removed = env.remove(transfer_moles)

			if(removed)
				var/heat_produced = idle_power_usage	//obviously can't produce more heat than the machine draws from it's power source

				removed.adjust_thermal_energy(heat_produced)

			env.merge(removed)

/obj/machinery/r_n_d/server/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(default_deconstruction_screwdriver(user, O))
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return

/obj/machinery/r_n_d/server/centcom
	name = "Central R&D Database"
	server_id = -1

/obj/machinery/r_n_d/server/centcom/proc/update_connections()
	var/list/no_id_servers = list()
	var/list/server_ids = list()
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		switch(S.server_id)
			if(-1)
				continue
			if(0)
				no_id_servers += S
			else
				server_ids += S.server_id

	for(var/obj/machinery/r_n_d/server/S in no_id_servers)
		var/num = 1
		while(!S.server_id)
			if(num in server_ids)
				num++
			else
				S.server_id = num
				server_ids += num
		no_id_servers -= S

/obj/machinery/r_n_d/server/centcom/process(delta_time)
	return PROCESS_KILL //don't need process()

/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	icon_keyboard = "rd_key"
	icon_screen = "rdcomp"
	light_color = "#a97faa"
	circuit = /obj/item/circuitboard/rdservercontrol
	var/screen = 0
	var/obj/machinery/r_n_d/server/temp_server
	var/list/servers = list()
	var/list/consoles = list()
	var/badmin = 0

/obj/machinery/computer/rdservercontrol/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(!allowed(user) && !emagged)
		. = min(., UI_UPDATE)

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user, datum/tgui/ui, datum/tgui/parent_ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ResearchServerController", name)
		ui.open()

/obj/machinery/computer/rdservercontrol/ui_data(mob/user, datum/tgui/ui)
	var/list/data = ..()

	data["badmin"] = badmin

	var/list/server_list = list()
	data["servers"] = server_list
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		if(istype(S, /obj/machinery/r_n_d/server/centcom) && !badmin)
			continue
		var/list/tech = list()
		var/list/designs = list()
		var/list/server_data = list(
			"name" = S.name,
			"ref" = REF(S),
			"id" = S.server_id,
			"id_with_upload" = S.id_with_upload,
			"id_with_download" = S.id_with_download,
			"tech" = tech,
			"designs" = designs,
		)
		for(var/datum/tech/T in S.files.known_tech)
			tech.Add(list(list(
				"name" = T.name,
				"id" = T.id,
			)))
		for(var/datum/prototype/design/D in S.files.legacy_all_design_datums())
			designs.Add(list(list(
				"name" = D.name,
				"id" = D.id,
			)))
		server_list.Add(list(server_data))

	var/list/console_list = list()
	data["consoles"] = console_list
	for(var/obj/machinery/computer/rdconsole/C in GLOB.machines)
		if(!C.sync)
			continue
		console_list.Add(list(list(
			"name" = C.name,
			"ref" = REF(C),
			"loc" = get_area(C),
			"id" = C.id,
		)))

	return data

/obj/machinery/computer/rdservercontrol/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE

	switch(action)
		if("toggle_upload", "toggle_download")
			var/obj/machinery/r_n_d/server/S = locate(params["server"])
			if(!istype(S))
				return
			if(istype(S, /obj/machinery/r_n_d/server/centcom) && !badmin)
				return
			var/obj/machinery/computer/rdconsole/C = locate(params["console"])
			if(!istype(C) || !C.sync)
				return

			switch(action)
				if("toggle_upload")
					if(C.id in S.id_with_upload)
						S.id_with_upload -= C.id
					else
						S.id_with_upload += C.id
				if("toggle_download")
					if(C.id in S.id_with_download)
						S.id_with_download -= C.id
					else
						S.id_with_download += C.id
			return TRUE

		if("reset_tech")
			var/obj/machinery/r_n_d/server/target = locate(params["server"])
			if(!istype(target))
				return FALSE
			var/choice = alert("Technology Data Rest", "Are you sure you want to reset this technology to its default data? Data lost cannot be recovered.", "Continue", "Cancel")
			if(choice == "Continue")
				for(var/datum/tech/T in target.files.known_tech)
					if(T.id == params["tech"])
						T.level = 1
						break
			target.files.RefreshResearch()
			return TRUE

		if("reset_design")
			var/obj/machinery/r_n_d/server/target = locate(params["server"])
			if(!istype(target))
				return FALSE
			var/choice = alert("Design Data Deletion", "Are you sure you want to delete this design? If you still have the prerequisites for the design, it'll reset to its base reliability. Data lost cannot be recovered.", "Continue", "Cancel")
			if(choice == "Continue")
				target.files.known_design_ids -= params["design"]
			target.files.RefreshResearch()
			return TRUE

		if("transfer_data")
			if(!badmin)
				// no href exploits, you've been r e p o r t e d
				log_admin("Warning: [key_name(usr)] attempted to transfer R&D data from [params["server"]] to [params["target"]] via href exploit with [src] [COORD(src)]")
				message_admins("Warning: [ADMIN_FULLMONTY(usr)] attempted to transfer R&D data from [params["server"]] to [params["target"]] via href exploit with [src] [ADMIN_COORDJMP(src)]")
				return FALSE
			var/obj/machinery/r_n_d/server/from = locate(params["server"])
			if(!istype(from))
				return
			var/obj/machinery/r_n_d/server/target = locate(params["target"])
			if(!istype(target))
				return
			target.files.known_design_ids |= from.files.known_design_ids
			target.files.known_tech |= from.files.known_tech
			return TRUE

/obj/machinery/computer/rdservercontrol/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/rdservercontrol/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		playsound(src.loc, /datum/soundbyte/sparks, 75, TRUE)
		emagged = TRUE
		to_chat(user, SPAN_NOTICE("You you disable the security protocols."))
		SStgui.update_uis(src)
		return TRUE

/obj/machinery/r_n_d/server/robotics
	name = "Robotics R&D Server"
	id_with_upload_string = "1;2"
	id_with_download_string = "1;2"
	server_id = 2

/obj/machinery/r_n_d/server/core
	name = "Core R&D Server"
	id_with_upload_string = "1"
	id_with_download_string = "1"
	server_id = 1
