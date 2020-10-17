/obj/structure/alien
	name = "alien thing"
	desc = "There's something alien about this."
	icon = 'icons/mob/alien.dmi'
	var/health = 50

/obj/structure/alien/proc/healthcheck()
	if(health <=0)
		density = FALSE
		qdel(src)
	return

/obj/structure/alien/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.get_structure_damage()
	..()
	healthcheck()
	return

/obj/structure/alien/ex_act(severity)
	switch(severity)
		if(1)
			health-=50
		if(2)
			health-=50
		if(3)
			if (prob(50))
				health-=50
			else
				health-=25
	healthcheck()
	return

/obj/structure/alien/hitby(AM as mob|obj)
	..()
	visible_message(SPAN_DANGER("\The [src] was hit by \the [AM]."))
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health = max(0, health - tforce)
	healthcheck()
	..()
	return

/obj/structure/alien/attack_generic()
	attack_hand(usr)

/obj/structure/alien/attackby(var/obj/item/weapon/W, var/mob/user)
	health = max(0, health - W.force)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	..()
	return

/obj/structure/alien/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density