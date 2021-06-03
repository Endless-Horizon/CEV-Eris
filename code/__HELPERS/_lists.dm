/*
 * Holds procs to help with list operations
 * Contains groups:
 *			Misc
 *			Sorting
 */

/*
 * Misc
 */

#define listequal(A, B) (A.len == B.len && !length(A^B))

#define LAZYINITLIST(L) if (!L) L = list()

#define LAZYLEN(L) length(L)
#define UNSETEMPTY(L) if (L && !LAZYLEN(L)) L = null
#define LAZYREMOVE(L, I) if(L) { L -= I; if(!LAZYLEN(L)) { L = null; } }
#define LAZYADD(L, I) if(!L) { L = list(); } L += I;
#define LAZYINSERT(L, I, X) if(!L) { L = list(); } L.Insert(X, I);
#define LAZYDISTINCTADD(L, I) if(!L) { L = list(); } L |= I;
#define LAZYOR(L, I) if(!L) { L = list(); } L |= I;
#define LAZYFIND(L, V) L ? L.Find(V) : 0
#define LAZYISIN(L, I) (L ? (I in L) : FALSE)
#define LAZYACCESS(L, I) (islist(L) ? (isnum(I) ? (I > 0 && I <= LAZYLEN(L) ? L[I] : null) : L[I]) : null)
#define LAZYCLEARLIST(L) if(L) L.Cut()
#define SANITIZE_LIST(L) ( islist(L) ? L : list() )
#define reverseList(L) reverseRange(L.Copy())

//Sets the value of a key in an assoc list
#define LAZYSET(L,K,V) if(!L) { L = list(); } L[K] = V;

//Adds value to the existing value of a key
#define LAZYAPLUS(L,K,V) if(!L) { L = list(); } if (!L[K]) { L[K] = 0; } L[K] += V;

//Subtracts value from the existing value of a key
#define LAZYAMINUS(L,K,V) if(L && L[K]) { L[K] -= V; if(!LAZYLEN(L[K])) { L -= K } }

// Insert an object A into a sorted list using cmp_proc (/code/_helpers/cmp.dm) for comparison.
#define ADD_SORTED(list, A, cmp_proc) if(!list.len) {list.Add(A)} else {list.Insert(FindElementIndex(A, list, cmp_proc), A)}

/// Passed into BINARY_INSERT to compare keys
#define COMPARE_KEY __BIN_LIST[__BIN_MID]
/// Passed into BINARY_INSERT to compare values
#define COMPARE_VALUE __BIN_LIST[__BIN_LIST[__BIN_MID]]

/****
	* Binary search sorted insert
	* INPUT: Object to be inserted
	* LIST: List to insert object into
	* TYPECONT: The typepath of the contents of the list
	* COMPARE: The object to compare against, usualy the same as INPUT
	* COMPARISON: The variable on the objects to compare
	* COMPTYPE: How should the values be compared? Either COMPARE_KEY or COMPARE_VALUE.
	*/
#define BINARY_INSERT(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			var ##TYPECONT/__BIN_ITEM;\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(__BIN_ITEM.##COMPARISON <= COMPARE.##COMPARISON) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = __BIN_ITEM.##COMPARISON > COMPARE.##COMPARISON ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

//Returns a list in plain english as a string
/proc/english_list(list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = input.len
	if (!total)
		return "[nothing_text]"
	else if (total == 1)
		return "[input[1]]"
	else if (total == 2)
		return "[input[1]][and_text][input[2]]"
	else
		var/output = ""
		var/index = 1
		while (index < total)
			if (index == total - 1)
				comma_text = final_comma_text

			output += "[input[index]][comma_text]"
			index++

		return "[output][and_text][input[index]]"

//Returns list element or null. Should prevent "index out of bounds" error.
/proc/listgetindex(list/L, index)
	if(LAZYLEN(L))
		if(isnum(index) && ISINTEGER(index))
			if(ISINRANGE(index,1,L.len))
				return L[index]
		else if(index in L)
			return L[index]
	return

//Return either pick(list) or null if list is not of type /list or is empty
/proc/safepick(list/L)
	if(LAZYLEN(L))
		return pick(L)

//Checks if the list is empty
/proc/isemptylist(list/L)
	if(!L.len)
		return TRUE
	return FALSE

//Checks for specific types in a list
/proc/is_type_in_list(atom/A, list/L)
	if(!LAZYLEN(L) || !A)
		return FALSE
	for(var/type in L)
		if(istype(A, type))
			return TRUE
	return FALSE

/proc/instances_of_type_in_list(var/atom/A, var/list/L)
	var/instances = 0
	for(var/type in L)
		if(istype(A, type))
			instances++
	return instances

//Checks for specific types in specifically structured (Assoc "type" = TRUE) lists ('typecaches')
#define is_type_in_typecache(A, L) (A && length(L) && L[(ispath(A) ? A : A:type)])

//Checks for a string in a list
/proc/is_string_in_list(string, list/L)
	if(!LAZYLEN(L) || !string)
		return
	for(var/V in L)
		if(string == V)
			return TRUE
	return

//Removes a string from a list
/proc/remove_strings_from_list(string, list/L)
	if(!LAZYLEN(L) || !string)
		return
	for(var/V in L)
		if(V == string)
			L -= V //No return here so that it removes all strings of that type
	return

//returns a new list with only atoms that are in typecache L
/proc/typecache_filter_list(list/atoms, list/typecache)
	. = list()
	for(var/thing in atoms)
		var/atom/A = thing
		if (typecache[A.type])
			. += A

/proc/typecache_filter_list_reverse(list/atoms, list/typecache)
	. = list()
	for(var/thing in atoms)
		var/atom/A = thing
		if(!typecache[A.type])
			. += A


/proc/typecache_filter_multi_list_exclusion(list/atoms, list/typecache_include, list/typecache_exclude)
	. = list()
	for(var/thing in atoms)
		var/atom/A = thing
		if(typecache_include[A.type] && !typecache_exclude[A.type])
			. += A

//Like typesof() or subtypesof(), but returns a typecache instead of a list
/proc/typecacheof(path, ignore_root_path, only_root_path = FALSE)
	if(ispath(path))
		var/list/types = list()
		if(only_root_path)
			types = list(path)
		else
			types = ignore_root_path ? subtypesof(path) : typesof(path)
		var/list/L = list()
		for(var/T in types)
			L[T] = TRUE
		return L
	else if(islist(path))
		var/list/pathlist = path
		var/list/L = list()
		if(ignore_root_path)
			for(var/P in pathlist)
				for(var/T in subtypesof(P))
					L[T] = TRUE
		else
			for(var/P in pathlist)
				if(only_root_path)
					L[P] = TRUE
				else
					for(var/T in typesof(P))
						L[T] = TRUE
		return L

//Empties the list by setting the length to 0. Hopefully the elements get garbage collected
/proc/clearlist(list/list)
	if(istype(list))
		list.len = 0

//Removes any null entries from the list
//Returns TRUE if the list had nulls, FALSE otherwise
/proc/listclearnulls(list/L)
	var/start_len = L.len
	var/list/N = new(start_len)
	L -= N
	return L.len < start_len

/*
 * Returns list containing all the entries from first list that are not present in second.
 * If skiprep = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/difflist(list/first, list/second, skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = new
	if(skiprep)
		for(var/e in first)
			if(!(e in result) && !(e in second))
				result += e
	else
		result = first - second
	return result

/*
 * Returns list containing entries that are in either list but not both.
 * If skipref = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/uniquemergelist(list/first, list/second, skiprep = FALSE)
	if(!islist(first) || !islist(second))
		return
	var/list/result = new
	if(skiprep)
		result = difflist(first, second, skiprep)+difflist(second, first, skiprep)
	else
		result = first ^ second
	return result

//Picks a random element from a list based on a weighting system:
//1. Adds up the total of weights for each element
//2. Gets the total from 0% to 100% of previous total value.
//3. For each element in the list, subtracts its weighting from that number
//4. If that makes the number 0 or less, return that element.
/proc/pickweight(list/L, base_weight = 1)
	var/total = 0
	var/item
	for (item in L)
		if (!L[item])
			L[item] = base_weight
		total += L[item]

	total = rand() * total
	for (item in L)
		total -= L[item]
		if (total <= 0)
			return item

//Picks a number of elements from a list based on weight.
//This is highly optimised and good for things like grabbing 200 items from a list of 40,000
//Much more efficient than many pickweight calls
/proc/pickweight_mult(list/L, quantity, base_weight = 1)
	//First we total the list as normal
	var/total = 0
	var/item
	for (item in L)
		if (!L[item])
			L[item] = base_weight
		total += L[item]

	//Next we will make a list of randomly generated numbers, called Requests
	//It is critical that this list be sorted in ascending order, so we will build it in that order
	//First one is free, so we start counting at 2
	var/list/requests = list(rand(1, total))
	for (var/i in 2 to quantity)
		//Each time we generate the next request
		var/newreq = rand()* total
		//We will loop through all existing requests
		for (var/j in 1 to requests.len)
			//We keep going through the list until we find an element which is bigger than the one we want to add
			if (requests[j] > newreq)
				//And then we insert the newqreq at that point, pushing everything else forward
				requests.Insert(j, newreq)
				break



	//Now when we get here, we have a list of random numbers sorted in ascending order.
	//The length of that list is equal to Quantity passed into this function
	//Next we make a list to store results
	var/list/results = list()

	//Zero the total, we'll reuse it
	total = 0

	//Now we will iterate forward through the items list, adding each weight to the total
	for (item in L)
		total += L[item]

		//After each item we do a while loop
		while (requests.len && total >= requests[1])
			//If the total is higher than the value of the first request
			results += item //We add this item to the results list
			requests.Cut(1,2) //And we cut off the top of the requests list

			//This while loop will repeat until the next request is higher than the total.
			//The current item might be added to the results list many times, in this process

	//By the time we get here:
		//Requests will be empty
		//Results will have a length of quality
	return results


//Pick a random element from the list and remove it from the list.
/proc/pick_n_take(list/L)
	if(L.len)
		var/picked = rand(1,L.len)
		. = L[picked]
		L.Cut(picked,picked+1)			//Cut is far more efficient that Remove()

//Pick a random element from the list by weight and remove it from the list.
//Result is returned as a list in the format list(key, value)
/proc/pickweight_n_take(list/L)
	if (L.len)
		. = pickweight(L)
		L.Remove(.)

//Returns the top(last) element from the list and removes it from the list (typical stack function)
/proc/pop(list/L)
	if(L.len)
		. = L[L.len]
		L.len--

/proc/popleft(list/L)
	if(L.len)
		. = L[1]
		L.Cut(1,2)

/proc/sorted_insert(list/L, thing, comparator)
	var/pos = L.len
	while(pos > 0 && call(comparator)(thing, L[pos]) > 0)
		pos--
	L.Insert(pos+1, thing)

// Returns the next item in a list
/proc/next_list_item(item, list/L)
	var/i = L.Find(item)
	if(i == L.len)
		i = 1
	else
		i++
	return L[i]

// Returns the previous item in a list
/proc/previous_list_item(item, list/L)
	var/i = L.Find(item)
	if(i == 1)
		i = L.len
	else
		i--
	return L[i]

/*
 * Sorting
 */

/proc/reverseRange(list/L, start=1, end=0)
	if(L.len)
		start = start % L.len
		end = end % (L.len+1)
		if(start <= 0)
			start += L.len
		if(end <= 0)
			end += L.len + 1

		--end
		while(start < end)
			L.Swap(start++,end--)

	return L

//Randomize: Return the list in a random order
/proc/shuffle(list/L)
	if(!L)
		return
	L = L.Copy()

	for(var/i in 1 to L.len)
		L.Swap(i,rand(i,L.len))

	return L

//same, but returns nothing and acts on list in place
/proc/shuffle_inplace(list/L)
	if(!L)
		return

	for(var/i=1, i<L.len, ++i)
		L.Swap(i,rand(i,L.len))

//Return a list with no duplicate entries
/proc/uniquelist(list/L)
	. = list()
	for(var/i in L)
		. |= i

//same, but returns nothing and acts on list in place (also handles associated values properly)
/proc/uniquelist_inplace(list/L)
	var/temp = L.Copy()
	L.len = 0
	for(var/key in temp)
		if (isnum(key))
			L |= key
		else
			L[key] = temp[key]

// Return a list of the values in an assoc list (including null)
/proc/list_values(list/L)
	. = list()
	for(var/e in L)
		. += L[e]

/proc/filter_list(list/L, type)
	. = list()
	for(var/entry in L)
		if(istype(entry, type))
			. += entry

//for sorting clients or mobs by ckey
/proc/sortKey(list/L, order=1)
	return sortTim(L, order >= 0 ? /proc/cmp_ckey_asc : /proc/cmp_ckey_dsc)

//Specifically for record datums in a list.
/proc/sortRecord(list/L, field = "name", order = 1)
	GLOB.cmp_field = field
	return sortTim(L, order >= 0 ? /proc/cmp_records_asc : /proc/cmp_records_dsc)

//any value in a list
/proc/sortList(list/L, cmp=/proc/cmp_text_asc)
	return sortTim(L.Copy(), cmp)

//uses sortList() but uses the var's name specifically. This should probably be using mergeAtom() instead
/proc/sortNames(list/L, order=1)
	return sortTim(L, order >= 0 ? /proc/cmp_name_asc : /proc/cmp_name_dsc)

//for sorting entries by their associated values, rather than keys.
/proc/sortAssoc(list/L, order=1)
	return sortTim(L, order >= 0 ? /proc/cmp_text_asc : /proc/cmp_text_dsc, TRUE) //third argument for fetching L[L[i]] instead of L[i]

// Returns the key based on the index
#define KEYBYINDEX(L, index) (((index <= length(L)) && (index > 0)) ? L[index] : null)

//returns an unsorted list of nearest map objects from a given list to sourceLocation using get_dist, acceptableDistance sets tolerance for distance
//result is intended to be used with pick()
/proc/nearestObjectsInList(list/L, sourceLocation, acceptableDistance = 0)
	if (L.len == 1)
		return L.Copy()

	var/list/nearestObjects = new
	var/shortestDistance = INFINITY
	for (var/object in L)
		var/distance = get_dist(sourceLocation,object)

		if (distance <= acceptableDistance)
			if (shortestDistance > acceptableDistance)
				shortestDistance = acceptableDistance
				nearestObjects.Cut()
			nearestObjects += object

		else if (shortestDistance > acceptableDistance)
			if (distance < shortestDistance)
				shortestDistance = distance
				nearestObjects.Cut()
				nearestObjects += object

			else if (distance == shortestDistance)
				nearestObjects += object

	return nearestObjects

// Macros to test for bits in a bitfield. Note, that this is for use with indexes, not bit-masks!
#define BITTEST(bitfield, index)  ((bitfield)  &   (1 << (index)))
#define BITSET(bitfield, index)   (bitfield)  |=  (1 << (index))
#define BITRESET(bitfield, index) (bitfield)  &= ~(1 << (index))
#define BITFLIP(bitfield, index)  (bitfield)  ^=  (1 << (index))

//Converts a bitfield to a list of numbers (or words if a wordlist is provided)
/proc/bitfield2list(bitfield = 0, list/wordlist)
	var/list/r = list()
	if(islist(wordlist))
		var/max = min(wordlist.len,16)
		var/bit = 1
		for(var/i in 1 to max)
			if(bitfield & bit)
				r += wordlist[i]
			bit = bit << 1
	else
		for(var/bit=1, bit<=65535, bit = bit << 1)
			if(bitfield & bit)
				r += bit

	return r

// Returns the key based on the index
/proc/get_key_by_index(list/L, index)
	var/i = 1
	for(var/key in L)
		if(index == i)
			return key
		i++

// Returns the key based on the index
/proc/get_key_by_value(list/L, value)
	var/I = LAZYFIND(L, value)
	if(I)
		return L[I]

/proc/count_by_type(list/L, type)
	var/i = 0
	for(var/T in L)
		if(istype(T, type))
			i++
	return i

/proc/dd_sortedObjectList(list/L, cache=list())
	if(L.len < 2)
		return L
	var/middle = L.len / 2 + 1 // Copy is first, second-1
	return dd_mergeObjectList(dd_sortedObjectList(L.Copy(0, middle), cache), dd_sortedObjectList(L.Copy(middle), cache), cache) //second parameter null = to end of list

/proc/dd_mergeObjectList(list/L, list/R, list/cache)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= L.len && Ri <= R.len)
		var/LLi = L[Li]
		var/RRi = R[Ri]
		var/LLiV = cache[LLi]
		var/RRiV = cache[RRi]
		if(!LLiV)
			LLiV = LLi:dd_SortValue()
			cache[LLi] = LLiV
		if(!RRiV)
			RRiV = RRi:dd_SortValue()
			cache[RRi] = RRiV
		if(LLiV < RRiV)
			result += L[Li++]
		else
			result += R[Ri++]

	if(Li <= L.len)
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

// Insert an object into a sorted list, preserving sortedness
/proc/dd_insertObjectList(list/L, O)
	var/min = 1
	var/max = L.len
	var/Oval = O:dd_SortValue()

	while(1)
		var/mid = min+round((max-min)/2)

		if(mid == max)
			L.Insert(mid, O)
			return

		var/Lmid = L[mid]
		var/midval = Lmid:dd_SortValue()
		if(Oval == midval)
			L.Insert(mid, O)
			return
		else if(Oval < midval)
			max = mid
		else
			min = mid+1

/proc/dd_sortedtextlist(list/incoming, case_sensitive = 0)
	// Returns a new list with the text values sorted.
	// Use binary search to order by sortValue.
	// This works by going to the half-point of the list, seeing if the node in question is higher or lower cost,
	// then going halfway up or down the list and checking again.
	// This is a very fast way to sort an item into a list.
	var/list/sorted_text = new()
	var/low_index
	var/high_index
	var/insert_index
	var/midway_calc
	var/current_index
	var/current_item
	var/list/list_bottom
	var/sort_result

	var/current_sort_text
	for (current_sort_text in incoming)
		low_index = 1
		high_index = sorted_text.len
		while (low_index <= high_index)
			// Figure out the midpoint, rounding up for fractions.  (BYOND rounds down, so add 1 if necessary.)
			midway_calc = (low_index + high_index) / 2
			current_index = round(midway_calc)
			if (midway_calc > current_index)
				current_index++
			current_item = sorted_text[current_index]

			if (case_sensitive)
				sort_result = sorttextEx(current_sort_text, current_item)
			else
				sort_result = sorttext(current_sort_text, current_item)

			switch(sort_result)
				if (1)
					high_index = current_index - 1	// current_sort_text < current_item
				if (-1)
					low_index = current_index + 1	// current_sort_text > current_item
				if (0)
					low_index = current_index		// current_sort_text == current_item
					break

		// Insert before low_index.
		insert_index = low_index

		// Special case adding to end of list.
		if (insert_index > sorted_text.len)
			sorted_text += current_sort_text
			continue

		// Because BYOND lists don't support insert, have to do it by:
		// 1) taking out bottom of list, 2) adding item, 3) putting back bottom of list.
		list_bottom = sorted_text.Copy(insert_index)
		sorted_text.Cut(insert_index)
		sorted_text += current_sort_text
		sorted_text += list_bottom
	return sorted_text


proc/dd_sortedTextList(list/incoming)
	var/case_sensitive = 1
	return dd_sortedtextlist(incoming, case_sensitive)


/datum/proc/dd_SortValue()
	return "[src]"

/obj/machinery/dd_SortValue()
	return "[sanitize_old(name)]"

/obj/machinery/camera/dd_SortValue()
	return "[c_tag]"

/datum/alarm/dd_SortValue()
	return "[sanitize_old(last_name)]"

/proc/subtypesof(prototype)
	return (typesof(prototype) - prototype)

//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	LAZYINITLIST(L)
	for(var/path in subtypesof(prototype))
		L += new path()
	return L

//Move a single element from position fromIndex within a list, to position toIndex
//All elements in the range [1,toIndex) before the move will be before the pivot afterwards
//All elements in the range [toIndex, L.len+1) before the move will be after the pivot afterwards
//In other words, it's as if the range [fromIndex,toIndex) have been rotated using a <<< operation common to other languages.
//fromIndex and toIndex must be in the range [1,L.len+1]
//This will preserve associations ~Carnie
/proc/moveElement(list/L, fromIndex, toIndex)
	if(fromIndex == toIndex || fromIndex+1 == toIndex)	//no need to move
		return
	if(fromIndex > toIndex)
		++fromIndex	//since a null will be inserted before fromIndex, the index needs to be nudged right by one

	L.Insert(toIndex, null)
	L.Swap(fromIndex, toIndex)
	L.Cut(fromIndex, fromIndex+1)


//Move elements [fromIndex,fromIndex+len) to [toIndex-len, toIndex)
//Same as moveElement but for ranges of elements
//This will preserve associations ~Carnie
/proc/moveRange(list/L, fromIndex, toIndex, len=1)
	var/distance = abs(toIndex - fromIndex)
	if(len >= distance)	//there are more elements to be moved than the distance to be moved. Therefore the same result can be achieved (with fewer operations) by moving elements between where we are and where we are going. The result being, our range we are moving is shifted left or right by dist elements
		if(fromIndex <= toIndex)
			return	//no need to move
		fromIndex += len	//we want to shift left instead of right

		for(var/i in 1 to distance)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex+1)
	else
		if(fromIndex > toIndex)
			fromIndex += len

		for(var/i in 1 to len)
			L.Insert(toIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(fromIndex, fromIndex+1)

//Move elements from [fromIndex, fromIndex+len) to [toIndex, toIndex+len)
//Move any elements being overwritten by the move to the now-empty elements, preserving order
//Note: if the two ranges overlap, only the destination order will be preserved fully, since some elements will be within both ranges ~Carnie
/proc/swapRange(list/L, fromIndex, toIndex, len=1)
	var/distance = abs(toIndex - fromIndex)
	if(len > distance)	//there is an overlap, therefore swapping each element will require more swaps than inserting new elements
		if(fromIndex < toIndex)
			toIndex += len
		else
			fromIndex += len

		for(var/i=0, i<distance, ++i)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex+1)
	else
		if(toIndex > fromIndex)
			var/a = toIndex
			toIndex = fromIndex
			fromIndex = a

		for(var/i=0, i<len, ++i)
			L.Swap(fromIndex++, toIndex++)

/*
Checks if a list has the same entries and values as an element of big.
*/
/proc/in_as_list(list/little, list/big)
	if(!LAZYLEN(big))
		return FALSE
	for(var/element in big)
		if(compare_list(little, big[element]))
			return TRUE
	return FALSE

// Return the index using dichotomic search
/proc/FindElementIndex(atom/A, list/L, cmp)
	var/i = 1
	var/j = L.len
	var/mid

	while(i < j)
		mid = round((i+j)/2)

		if(call(cmp)(L[mid],A) < 0)
			i = mid + 1
		else
			j = mid

	if(i == 1 || i ==  L.len) // Edge cases
		return (call(cmp)(L[i],A) > 0) ? i : i+1
	else
		return i

//Checks if list is associative (example '["temperature"] = 90')
/proc/is_associative(list/L)
	for(var/key in L)
		// if the key is a list that means it's actually an array of lists (stupid Byond...)
		if(isnum(key) || istype(key, /list))
			return FALSE

		if(!isnull(L[key]))
			return TRUE

	return FALSE

/proc/group_by(list/group_list, key, value)
	var/values = group_list[key]
	if(!values)
		values = list()
		group_list[key] = values

	values += value

/proc/duplicates(list/L)
	. = list()
	var/list/checked = list()
	for(var/value in L)
		if(value in checked)
			. |= value
		else
			checked += value

//Checks for specific paths in a list
/proc/is_path_in_list(var/path, var/list/L)
	for(var/type in L)
		if(ispath(path, type))
			return 1
	return 0

/proc/parse_for_paths(list/data)
	if(!islist(data) || !data.len)
		return list()
	var/list/types = list()
	if(is_associative(data))
		for(var/tag in data)
			if(ispath(tag))
				types.Add(tag)
			else if(islist(tag))
				types.Add(parse_for_paths(tag))

			if(ispath(data[tag]))
				types.Add(data[tag])
			else if(islist(data[tag]))
				types.Add(parse_for_paths(data[tag]))
	else
		for(var/value in data)
			if(ispath(value))
				types.Add(value)
			else if(islist(value))
				types.Add(parse_for_paths(value))
	return uniquelist(types)

//return first thing in L which has var/varname == value
//this is typecaste as list/L, but you could actually feed it an atom instead.
//completely safe to use
/proc/getElementByVar(list/L, varname, value)
	varname = "[varname]"
	for(var/datum/D in L)
		if(D.vars.Find(varname))
			if(D.vars[varname] == value)
				return D
//remove all nulls from a list
/proc/removeNullsFromList(list/L)
	while(L.Remove(null))
		continue
	return L

//Copies a list, and all lists inside it recusively
//Does not copy any other reference type
/proc/deepCopyList(list/l)
	if(!islist(l))
		return l
	. = l.Copy()
	for(var/i = 1 to l.len)
		var/key = .[i]
		if(isnum(key))
			// numbers cannot ever be associative keys
			continue
		var/value = .[key]
		if(islist(value))
			value = deepCopyList(value)
			.[key] = value
		if(islist(key))
			key = deepCopyList(key)
			.[i] = key
			.[key] = value

//takes an input_key, as text, and the list of keys already used, outputting a replacement key in the format of "[input_key] ([number_of_duplicates])" if it finds a duplicate
//use this for lists of things that might have the same name, like mobs or objects, that you plan on giving to a player as input
/proc/avoid_assoc_duplicate_keys(input_key, list/used_key_list)
	if(!input_key || !istype(used_key_list))
		return
	if(used_key_list[input_key])
		used_key_list[input_key]++
		input_key = "[input_key] ([used_key_list[input_key]])"
	else
		used_key_list[input_key] = 1
	return input_key


/proc/make_associative(list/flat_list)
	. = list()
	for(var/thing in flat_list)
		.[thing] = TRUE

//Picks from the list, with some safeties, and returns the "default" arg if it fails
#define DEFAULTPICK(L, default) ((islist(L) && length(L)) ? pick(L) : default)

/* Definining a counter as a series of key -> numeric value entries
 * All these procs modify in place.
*/

/proc/counterlist_scale(list/L, scalar)
	var/list/out = list()
	for(var/key in L)
		out[key] = L[key] * scalar
	. = out

/proc/counterlist_sum(list/L)
	. = 0
	for(var/key in L)
		. += L[key]

/proc/counterlist_normalise(list/L)
	var/avg = counterlist_sum(L)
	if(avg != 0)
		. = counterlist_scale(L, 1 / avg)
	else
		. = L

/proc/counterlist_combine(list/L1, list/L2)
	for(var/key in L2)
		var/other_value = L2[key]
		if(key in L1)
			L1[key] += other_value
		else
			L1[key] = other_value

/proc/assoc_list_strip_value(list/input)
	var/list/ret = list()
	for(var/key in input)
		ret += key
	return ret

/proc/compare_list(list/l,list/d)
	if(!islist(l) || !islist(d))
		return FALSE

	if(l.len != d.len)
		return FALSE

	for(var/i in 1 to l.len)
		if(l[i] != d[i])
			return FALSE

	return TRUE

/proc/try_json_decode(t)
	. = list()
	if(istext(t))
		. = json_decode(t)
	else if(islist(t))
		. = t
	else if(t)
		. += t

/proc/recursiveLen(list/L)
	. = 0
	if(istext(L))
		L = try_json_decode(L)
	if(length(L))
		. += length(L)
		for(var/list/i in L)
			if(islist(i))
				. += recursiveLen(i)
			else if(islist(L[i]))
				. += recursiveLen(L[i])

/proc/RecursiveCut(list/L)
	for(var/list/l in L)
		if(islist(l))
			RecursiveCut(l)
		else
			var/list/b = L[l]
			if(islist(b))
				RecursiveCut(b)
	L.Cut()

/proc/matrix2d_x_sanitize(mathrix, x)
	if(!islist(mathrix))
		return
	else if(!islist(mathrix[x]))
		return
	return mathrix

/proc/get_2d_matrix_cell(mathrix, x, y)
	if(!matrix2d_x_sanitize(mathrix, x))
		return
	return mathrix[x][y]

/proc/set_2d_matrix_cell(mathrix, x, y, value)
	if(!matrix2d_x_sanitize(mathrix, x))
		return
	mathrix[x][y] = value
