/obj/item/clothing/suit/storage/toggle/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat"
	icon = 'icons/clothing/suit/coats/labcoats.dmi'
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "labcoat", SLOT_ID_LEFT_HAND = "labcoat")
	blood_overlay_type = "coat"
	body_cover_flags = UPPER_TORSO|ARMS
	inv_hide_flags = HIDEHOLSTER
	allowed = list(/obj/item/atmos_analyzer,/obj/item/stack/medical,/obj/item/dnainjector,/obj/item/reagent_containers/dropper,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/hypospray,/obj/item/healthanalyzer,/obj/item/flashlight/pen,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/pill,/obj/item/storage/pill_bottle,/obj/item/paper)
	armor_type = /datum/armor/suit/labcoat
	worn_render_flags = WORN_RENDER_SLOT_ONE_FOR_ALL

/obj/item/clothing/suit/storage/toggle/labcoat/green
	name = "green labcoat"
	desc = "A suit that protects against minor chemical spills. This one is green."
	icon_state = "labgreen"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "green_labcoat", SLOT_ID_LEFT_HAND = "green_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "cmo_labcoat", SLOT_ID_LEFT_HAND = "cmo_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/cmoalt
	name = "chief medical officer labcoat"
	desc = "A labcoat with command blue highlights."
	icon_state = "labcoat_cmoalt"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "cmo_labcoat", SLOT_ID_LEFT_HAND = "cmo_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/mad
	name = "The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labgreen"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "green_labcoat", SLOT_ID_LEFT_HAND = "green_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/mad/classic
	name = "The Mad's labcoat (Classic)"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space. It looks old-fashioned."
	icon_state = "labgreenclassic"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "green_labcoat", SLOT_ID_LEFT_HAND = "green_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/genetics
	name = "Geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_gen"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "genetics_labcoat", SLOT_ID_LEFT_HAND = "genetics_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/genetics/classic
	name = "Geneticist labcoat (Classic)"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder. It looks old-fashioned."
	icon_state = "labcoat_genclassic"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "genetics_labcoat", SLOT_ID_LEFT_HAND = "genetics_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/chemist
	name = "Chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_chem"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "chemist_labcoat", SLOT_ID_LEFT_HAND = "chemist_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/chemist/classic
	name = "Chemist labcoat (Classic)"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder. It looks old-fashioned."
	icon_state = "labcoat_chemclassic"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "chemist_labcoat", SLOT_ID_LEFT_HAND = "chemist_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/virologist
	name = "Virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	icon_state = "labcoat_vir"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "virologist_labcoat", SLOT_ID_LEFT_HAND = "virologist_labcoat")
	armor_type = /datum/armor/suit/labcoat/viro

/obj/item/clothing/suit/storage/toggle/labcoat/virologist/classic
	name = "Virologist labcoat (Classic)"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder. It looks old-fashioned."
	icon_state = "labcoat_virclassic"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "virologist_labcoat", SLOT_ID_LEFT_HAND = "virologist_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/science
	name = "Scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_sci"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "science_labcoat", SLOT_ID_LEFT_HAND = "science_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/science/classic
	name = "Scientist labcoat (Classic)"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder. It looks old-fashioned."
	icon_state = "labcoat_sciclassic"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "science_labcoat", SLOT_ID_LEFT_HAND = "science_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/emt
	name = "EMT's labcoat"
	desc = "A dark blue labcoat with reflective strips for emergency medical technicians."
	icon_state = "labcoat_emt"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "emt_labcoat", SLOT_ID_LEFT_HAND = "emt_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/rd
	name = "Research Director's labcoat"
	desc = "A flashy labcoat with purple markings. It belongs to the Research Director."
	icon_state = "labcoat_rd"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "science_labcoat", SLOT_ID_LEFT_HAND = "science_labcoat")

/obj/item/clothing/suit/storage/toggle/labcoat/robotics
	name = "Roboticist labcoat"
	desc = "A suit that protects against oil, acid, and burn hazards. Has a red stripe on the shoulder."
	icon_state = "labcoat_robo"

/obj/item/clothing/suit/storage/toggle/labcoat/robotics/classic
	name = "Roboticist labcoat (Classic)"
	desc = "A suit that protects against oil, acid, and burn hazards. Has a red stripe on the shoulder. It looks old-fashioned."
	icon_state = "labcoat_roboclassic"

/obj/item/clothing/suit/storage/toggle/labcoat/blue
	name = "blue-edged labcoat"
	desc = "A suit that protects against minor chemical spills. This one has blue trim."
	icon_state = "labcoat_gen"

/obj/item/clothing/suit/storage/toggle/labcoat/ossnecro
	name = "OSS&NECRO Labcoat"
	desc = "A flashy labcoat with cyan markings. This one is often provided to OSS&NECRO employees as standard equipement. Isn't it similar to the one that the Research Director has?"
	icon_state = "labcoat_ossnecro"

/obj/item/clothing/suit/storage/toggle/labcoat/pmd
	name = "PMD labcoat"
	desc = "A suit that protects against minor chemical hazards. This one has black trim and a PMD insignia on the back."
	icon_state = "labcoat_pmd"
