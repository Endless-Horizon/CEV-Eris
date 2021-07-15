/mob/living/silicon/robot/dust()
	//Delete the MMI first so that it won't go popping out.
	if(mmi)
		qdel(mmi)
	..()

/mob/living/silicon/robot/death(gibbed)
	if(camera)
		camera.status = 0
	if(module)
		for (var/obj/item/gripper/G in module)
			G.drop_item()
	remove_robot_verbs()

	..(gibbed,"shudders violently for a moment, then becomes motionless, its eyes slowly darkening.")
