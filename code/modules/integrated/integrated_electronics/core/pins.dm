/*
	Pins both hold data for circuits, as well move data between them.  Some also cause circuits to do their function.  DATA_CHANNEL pins are the data holding/moving kind,
where as PULSE_CHANNEL causes circuits to work() when their pulse hits them.


A visualization of how pins work is below.  Imagine the below image involves an addition circuit.
When the bottom pin, the activator, receives a pulse, all the numbers on the left (input) get added, and the answer goes on the right side (output).

Inputs      Outputs

A [2]\      /[8] result
B [1]-\|++|/
C [4]-/|++|
D [1]/  ||
        ||
     Activator



*/
/datum/integrated_io
	var/name = "input/output"
	var/obj/item/integrated_circuit/holder = null
	var/datum/weakref/data = null // This is a weakref, to reduce typecasts.  Note that oftentimes numbers and text may also occupy this.
	var/list/linked = list()
	var/io_type = DATA_CHANNEL

/datum/integrated_io/New(newloc, name, data)
	..()
	src.name = name
	src.data = data
	holder = newloc
	if(!istype(holder))
		message_admins("ERROR: An integrated_io ([src.name]) spawned without a valid holder!  This is a bug.")

/datum/integrated_io/Destroy()
	disconnect()
	data = null
	holder = null
	. = ..()

/datum/integrated_io/nano_host()
	return holder.nano_host()


/datum/integrated_io/proc/data_as_type(as_type)
	if(!isweakref(data))
		return
	var/datum/weakref/w = data
	var/output = w.resolve()
	return istype(output, as_type) ? output : null

/datum/integrated_io/proc/display_data()
	if(isnull(data))
		return "(null)" // Empty data means nothing to show.
	if(istext(data))
		return "(\"[data]\")" // Wraps the 'string' in escaped quotes, so that people know it's a 'string'.
	if(isweakref(data))
		var/datum/weakref/w = data
		var/atom/A = w.resolve()
		//return A ? "([A.name] \[Ref\])" : "(null)" // For refs, we want just the name displayed.
		return A ? "(\ref[A] \[Ref\])" : "(null)"
	return "([data])" // Nothing special needed for numbers or other stuff.

/datum/integrated_io/activate/display_data()
	return "(\[pulse\])"

/datum/integrated_io/proc/display_pin_type()
	return IC_FORMAT_ANY

/datum/integrated_io/activate/display_pin_type()
	return IC_FORMAT_PULSE

/datum/integrated_io/proc/scramble()
	if(isnull(data))
		return
	if(isnum(data))
		write_data_to_pin(rand(-10000, 10000))
	if(istext(data))
		write_data_to_pin("ERROR")
	push_data()

/datum/integrated_io/activate/scramble()
	push_data()

/datum/integrated_io/proc/write_data_to_pin(var/new_data)
	if(isnull(new_data) || isnum(new_data) || istext(new_data) || isweakref(new_data)) // Anything else is a type we don't want.
		data = new_data
		holder.on_data_written()

/datum/integrated_io/proc/push_data()
	for(var/datum/integrated_io/io in linked)
		io.write_data_to_pin(data)

/datum/integrated_io/activate/push_data()
	for(var/datum/integrated_io/io in linked)
		io.holder.check_then_do_work()

/datum/integrated_io/proc/pull_data()
	for(var/datum/integrated_io/io in linked)
		write_data_to_pin(io.data)

/datum/integrated_io/proc/get_linked_to_desc()
	if(linked.len)
		return "the [english_list(linked)]"
	return "nothing"

/datum/integrated_io/proc/disconnect()
	//First we iterate over everything we are linked to.
	for(var/datum/integrated_io/their_io in linked)
		//While doing that, we iterate them as well, and disconnect ourselves from them.
		for(var/datum/integrated_io/their_linked_io in their_io.linked)
			if(their_linked_io == src)
				their_io.linked.Remove(src)
			else
				continue
		//Now that we're removed from them, we gotta remove them from us.
		src.linked.Remove(their_io)

/datum/integrated_io/input
	name = "input pin"

/datum/integrated_io/output
	name = "output pin"

/datum/integrated_io/activate
	name = "activation pin"
	io_type = PULSE_CHANNEL

/datum/integrated_io/list
	name = "list pin"

/datum/integrated_io/list/write_data_to_pin(var/new_data)
	if(islist(new_data))
		data = new_data
		holder.on_data_written()

/datum/integrated_io/list/display_pin_type()
	return IC_FORMAT_LIST
