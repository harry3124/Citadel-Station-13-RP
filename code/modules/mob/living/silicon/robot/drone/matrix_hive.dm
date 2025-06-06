var/global/list/drone_matrices = list()

/datum/drone_matrix
	var/id = null
	var/datum/weakref/matriarch
	var/list/datum/weakref/drones = list()

	var/upgrades_remaining = 3
	var/list/bought_upgrades

/datum/drone_matrix/New(var/matrix_id)
	..()
	id = matrix_id
	drone_matrices[id] = src

/datum/drone_matrix/Destroy(force)
	drone_matrices -= id
	return ..()

/datum/drone_matrix/proc/get_matriarch()
	if(matriarch)
		return matriarch.resolve()
	return null

/datum/drone_matrix/proc/get_drones()
	. = list()
	for(var/datum/weakref/drone_ref as anything in drones)
		var/mob/living/silicon/robot/drone/D = drone_ref.resolve()
		if(D)
			. += D

/datum/drone_matrix/proc/message_drones(var/msg)
	var/mob/living/silicon/robot/drone/D = null
	if(matriarch)
		D = matriarch.resolve()
		if(D)
			to_chat(D, msg)

	for(var/datum/weakref/drone_ref as anything in drones)
		D = drone_ref.resolve()
		if(D)
			to_chat(D, msg)

/datum/drone_matrix/proc/add_drone(mob/living/silicon/robot/drone/D)
	if(isMatriarchDrone(D))
		matriarch = WEAKREF(D)
		return
	drones += WEAKREF(D)

/datum/drone_matrix/proc/remove_drone(var/datum/weakref/drone_ref)
	if(drone_ref == matriarch)
		matriarch = null
		return
	drones -= drone_ref

/datum/drone_matrix/proc/handle_death(mob/living/silicon/robot/drone/D)
	if(isMatriarchDrone(D))
		message_drones(SPAN_DANGER("A cold wave washes over your circuits. The matriarch is dead!"))
	else
		message_drones(SPAN_DANGER("Your circuits spark. Drone [D.name] has died."))

/datum/drone_matrix/proc/buy_upgrade(var/upgrade_type)
	LAZYADD(bought_upgrades, upgrade_type)
	upgrades_remaining--
	message_drones(SPAN_NOTICE("A new matrix upgrade is available, visit a recharging staion to install: [upgrade_type]"))

/datum/drone_matrix/proc/apply_upgrades(mob/living/silicon/robot/drone/D)
	var/list/applied_upgrades = list()
	for(var/upgrade in bought_upgrades)
		if(!LAZYFIND(D.matrix_upgrades, upgrade))
			applied_upgrades += upgrade
			set_upgrade(D, upgrade)
	if(length(applied_upgrades))
		to_chat(D, SPAN_NOTICE("Matrix upgrades applied to chassis: [english_list(applied_upgrades)]"))

/datum/drone_matrix/proc/set_upgrade(mob/living/silicon/robot/drone/D, var/upgrade_type)
	switch(upgrade_type)
		if(MTX_UPG_SPEED)
			D.movement_base_speed += 1
			D.update_movespeed_base()
		if(MTX_UPG_CELL)
			D.cell.maxcharge *= 1.5
		if(MTX_UPG_HEALTH)
			D.maxHealth += 15
		if(MTX_UPG_MOP)
			var/obj/item/mop/current_mop = locate(/obj/item/mop) in D.module.modules
			if(!istype(current_mop, /obj/item/mop/advanced))
				D.module.modules -= current_mop
				D.module.modules += new/obj/item/mop/advanced(D.module)
				qdel(current_mop)
		if(MTX_UPG_T)
			var/obj/item/t_scanner/current_scanner = locate(/obj/item/t_scanner) in D.module.modules
			if(!istype(current_scanner, /obj/item/t_scanner/upgraded))
				D.module.modules -= current_scanner
				D.module.modules += new/obj/item/t_scanner/upgraded(D.module)
				qdel(current_scanner)
	LAZYADD(D.matrix_upgrades, upgrade_type)

/proc/assign_drone_to_matrix(mob/living/silicon/robot/drone/D, var/matrix_tag)
	var/datum/drone_matrix/DM = drone_matrices[matrix_tag]
	if(!DM)
		DM = new /datum/drone_matrix(matrix_tag)
	D.master_matrix = DM
	DM.add_drone(D)
