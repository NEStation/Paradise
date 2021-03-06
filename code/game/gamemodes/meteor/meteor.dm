/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/const/initialmeteordelay = 3000
	var/nometeors = 1
	required_players = 0

	uplink_welcome = "EVIL METEOR Uplink Console:"
	uplink_uses = 10


/datum/game_mode/meteor/announce()
	world << "<B>The current game mode is - Meteor!</B>"
	world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"


/datum/game_mode/meteor/post_setup()
	defer_powernet_rebuild = 2//Might help with the lag
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	spawn(initialmeteordelay)
		nometeors = 0
	..()


/datum/game_mode/meteor/process()
	if(nometeors) return
	sendmeteors()


/datum/game_mode/meteor/proc/sendmeteors()
	nometeors = 1
	var/waveduration = world.timeofday + rand(3000,9000)
	var/waitduration = rand(3000,9000)
	while(waveduration - world.timeofday > 0)
		sleep(20)
		spawn() spawn_meteors(6)
	spawn(waitduration)
		nometeors = 0

/datum/game_mode/meteor/declare_completion()
	var/text
	var/survivors = 0
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)	continue
			switch(location.loc.type)
				if( /area/shuttle/escape/centcom )
					text += "<br><b><font size=2>[player.real_name] escaped on the emergency shuttle</font></b>"
				if( /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom )
					text += "<br><font size=2>[player.real_name] escaped in a life pod.</font>"
				else
					text += "<br><font size=1>[player.real_name] survived but is stranded without any hope of rescue.</font>"
			survivors++

	if(survivors)
		world << "\blue <B>The following survived the meteor storm</B>:[text]"
	else
		world << "\blue <B>Nobody survived the meteor storm!</B>"

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors)

	..()
	return 1
