GLOBAL_DATUM_INIT(shipsystem, /datum/ship_subsystems, new)


/*
	Main gamemode. Marker starts aboard ishimura
*/
/datum/game_mode/marker/containment
	name = "Containment"
	round_description = "The USG Ishimura has brough aboard a strange artifact and is tasked with discovering what its purpose is."
	extended_round_description = "The crew must holdout until help arrives"
	config_tag = "containment"
	votable = TRUE

/datum/game_mode/marker/containment/get_marker_location()
	return pick(SSnecromorph.marker_spawns_ishimura)


/*
	Alternate Gamemode: Marker starts on aegis, unitologists start with a shard
*/

/datum/game_mode/marker/enemy_within
	name = "Enemy Within"
	round_description = "The USG Ishimura has discovered a strange artifact on Aegis VII, but it is not whole. Some piece of it has been broken off and smuggled aboard"
	extended_round_description = "The crew must holdout until help arrives"
	config_tag = "enemy_within"
	votable = TRUE
	antag_tags = list(MODE_UNITOLOGIST_SHARD)

/datum/game_mode/marker/enemy_within/get_marker_location()
	return pick(SSnecromorph.marker_spawns_aegis)



/datum/game_mode/marker
	name = "unnamed"
	round_description = "The USG Ishimura has unearthed a strange artifact and is tasked with discovering what its purpose is."
	extended_round_description = "The crew must holdout until help arrives"
	config_tag = "unnamed"
	required_players = 0
	required_enemies = 0
	end_on_antag_death = 0
	round_autoantag = TRUE
	auto_recall_shuttle = FALSE
	antag_tags = list(MODE_UNITOLOGIST)
	latejoin_antag_tags = list(MODE_UNITOLOGIST)
	antag_templates = list(/datum/antagonist/unitologist)
	require_all_templates = FALSE
	votable = FALSE
	var/marker_setup_time = 45 MINUTES

/datum/game_mode/marker/post_setup() //Mr Gaeta. Start the clock.
	. = ..()
	//Alright lets spawn the marker
	spawn_marker()

	if(!SSnecromorph.marker)
		message_admins("There are no markers on this map!")
		return
	command_announcement.Announce("Delivery of alien artifact successful at [get_area(SSnecromorph.marker)].","Ishimura Deliveries Subsystem") //Placeholder
	addtimer(CALLBACK(src, .proc/activate_marker), rand_between(0.85, 1.15)*marker_setup_time) //We have to spawn the marker quite late, so guess we'd best wait :)


/datum/game_mode/marker/proc/spawn_marker()
	var/turf/T = get_marker_location()
	if (T)
		return new /obj/machinery/marker(T)


/datum/game_mode/marker/proc/get_marker_location()
	return null

/datum/game_mode/marker/proc/pick_marker_player()
	if (SSnecromorph.marker.player)
		return	//There's already a marker player

	var/mob/M
	if(!SSnecromorph.signals.len) //No signals? We can't pick one
		message_admins("No signals, unable to pick a marker player! The marker is now active and awaiting anyone who wishes to control it")
		return FALSE

	var/list/marker_candidates = SSnecromorph.signals.Copy()
	while (marker_candidates.len)
		M = pick_n_take(marker_candidates)
		if (!M.client)
			continue


		//Alright pick them!
		to_chat(M, "<span class='warning'>You have been selected to become the marker!</span>")
		SSnecromorph.marker.become_master_signal(M)
		return M

	message_admins("No signals, unable to pick a marker player! The marker is now active and awaiting anyone who wishes to control it")
	return FALSE

/datum/game_mode/marker/proc/activate_marker()
	last_pointgain = world.timeofday
	evacuation_controller.add_can_call_predicate(new /datum/evacuation_predicate/travel_points)	//This handles preventing evac until we have enough points
	charge_evac_points()
	SSnecromorph.marker.make_active() //Allow controlling
	pick_marker_player()
	return TRUE

