/datum/unit_test/integrated_circuits/equals_1
	name = "Logic Circuits: Equals - String True"
	circuit_type = /obj/item/integrated_circuit/logic/binary/equals
	inputs_to_give = list("Test", "Test")
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/equals_2
	name = "Logic Circuits: Equals - String False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/equals
	inputs_to_give = list("Test", "Nope")
	expected_outputs = list(FALSE)

/datum/unit_test/integrated_circuits/equals_3
	name = "Logic Circuits: Equals - Number True"
	circuit_type = /obj/item/integrated_circuit/logic/binary/equals
	inputs_to_give = list(525, 525)
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/equals_4
	name = "Logic Circuits: Equals - Number False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/equals
	inputs_to_give = list(1020, -580)
	expected_outputs = list(FALSE)

/datum/unit_test/integrated_circuits/equals_5
	name = "Logic Circuits: Equals - Null True"
	circuit_type = /obj/item/integrated_circuit/logic/binary/equals
	inputs_to_give = list(null, null)
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/equals_6
	name = "Logic Circuits: Equals - Ref True"
	circuit_type = /obj/item/integrated_circuit/logic/binary/equals
	inputs_to_give = list()
	expected_outputs = list(TRUE)
	var/obj/A = null

/datum/unit_test/integrated_circuits/equals_6/arrange()
	A = new(get_standard_turf())
	inputs_to_give = list(WEAKREF(A), WEAKREF(A))
	..()

/datum/unit_test/integrated_circuits/equals_6/clean_up()
	qdel(A)
	..()

/datum/unit_test/integrated_circuits/equals_7
	name = "Logic Circuits: Equals - Ref False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/equals
	inputs_to_give = list()
	expected_outputs = list(FALSE)
	var/obj/A = null
	var/obj/B = null

/datum/unit_test/integrated_circuits/equals_7/arrange()
	A = new(get_standard_turf())
	B = new(get_standard_turf())
	inputs_to_give = list(WEAKREF(A), WEAKREF(B))
	..()

/datum/unit_test/integrated_circuits/equals_7/clean_up()
	qdel(A)
	qdel(B)
	..()



/datum/unit_test/integrated_circuits/not_equals_1
	name = "Logic Circuits: Not Equals - String True"
	circuit_type = /obj/item/integrated_circuit/logic/binary/not_equals
	inputs_to_give = list("Test", "Nope")
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/not_equals_2
	name = "Logic Circuits: Not Equals - String False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/not_equals
	inputs_to_give = list("Test", "Test")
	expected_outputs = list(FALSE)

/datum/unit_test/integrated_circuits/not_equals_3
	name = "Logic Circuits: Not Equals - Number True"
	circuit_type = /obj/item/integrated_circuit/logic/binary/not_equals
	inputs_to_give = list(150, 20)
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/not_equals_4
	name = "Logic Circuits: Not Equals - Number False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/not_equals
	inputs_to_give = list(100, 100)
	expected_outputs = list(FALSE)



/datum/unit_test/integrated_circuits/and_1
	name = "Logic Circuits: And - True"
	circuit_type = /obj/item/integrated_circuit/logic/binary/and
	inputs_to_give = list("One", "Two")
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/and_2
	name = "Logic Circuits: And - False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/and
	inputs_to_give = list("One", null)
	expected_outputs = list(FALSE)



/datum/unit_test/integrated_circuits/or_1
	name = "Logic Circuits: Or - True First"
	circuit_type = /obj/item/integrated_circuit/logic/binary/or
	inputs_to_give = list("One", null)
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/or_2
	name = "Logic Circuits: Or - True Second"
	circuit_type = /obj/item/integrated_circuit/logic/binary/or
	inputs_to_give = list(null, "Two")
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/or_3
	name = "Logic Circuits: Or - True Both"
	circuit_type = /obj/item/integrated_circuit/logic/binary/or
	inputs_to_give = list("One", "Two")
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/or_4
	name = "Logic Circuits: Or - False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/or
	inputs_to_give = list(null, null)
	expected_outputs = list(FALSE)



/datum/unit_test/integrated_circuits/less_than_1
	name = "Logic Circuits: Less Than - True"
	circuit_type = /obj/item/integrated_circuit/logic/binary/less_than
	inputs_to_give = list(50, 100)
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/less_than_2
	name = "Logic Circuits: Less Than - False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/less_than
	inputs_to_give = list(500, 50)
	expected_outputs = list(FALSE)



/datum/unit_test/integrated_circuits/less_than_or_equal_1
	name = "Logic Circuits: Less Than Or Equal - True 1"
	circuit_type = /obj/item/integrated_circuit/logic/binary/less_than_or_equal
	inputs_to_give = list(40, 50)
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/less_than_or_equal_2
	name = "Logic Circuits: Less Than Or Equal - True 2"
	circuit_type = /obj/item/integrated_circuit/logic/binary/less_than_or_equal
	inputs_to_give = list(40, 40)
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/less_than_or_equal_3
	name = "Logic Circuits: Less Than Or Equal - False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/less_than_or_equal
	inputs_to_give = list(40, 30)
	expected_outputs = list(FALSE)



/datum/unit_test/integrated_circuits/greater_than_1
	name = "Logic Circuits: Greater Than - True"
	circuit_type = /obj/item/integrated_circuit/logic/binary/greater_than
	inputs_to_give = list(100, 50)
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/greater_than_2
	name = "Logic Circuits: Greater Than - False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/greater_than
	inputs_to_give = list(25, 800)
	expected_outputs = list(FALSE)



/datum/unit_test/integrated_circuits/greater_than_or_equal_1
	name = "Logic Circuits: Greater Than Or Equal - True 1"
	circuit_type = /obj/item/integrated_circuit/logic/binary/greater_than_or_equal
	inputs_to_give = list(250, 30)
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/greater_than_or_equal_2
	name = "Logic Circuits: Greater Than Or Equal - True 2"
	circuit_type = /obj/item/integrated_circuit/logic/binary/greater_than_or_equal
	inputs_to_give = list(30, 30)
	expected_outputs = list(TRUE)

/datum/unit_test/integrated_circuits/greater_than_or_equal_3
	name = "Logic Circuits: Greater Than Or Equal - False"
	circuit_type = /obj/item/integrated_circuit/logic/binary/greater_than_or_equal
	inputs_to_give = list(-40, 100)
	expected_outputs = list(FALSE)



/datum/unit_test/integrated_circuits/not_1
	name = "Logic Circuits: Not - Invert to False"
	circuit_type = /obj/item/integrated_circuit/logic/unary/not
	inputs_to_give = list(1)
	expected_outputs = list(0)

/datum/unit_test/integrated_circuits/not_2
	name = "Logic Circuits: Not - Invert to True"
	circuit_type = /obj/item/integrated_circuit/logic/unary/not
	inputs_to_give = list(0)
	expected_outputs = list(1)
