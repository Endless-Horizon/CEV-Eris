/*
all vars and procs starting with _ are meant to be used only internally
see external_procs.dm for usable procs and documentation on how to use them

each element can only be seen by 1 client
element identifiers are used to manage different hud parts for clients, f.e. there can be only one "storage" identifier element displayed for a client
*/


/HUD_element
	parent_type = /atom/movable

	layer = HUD_LAYER
	plane = HUD_PLANE
	//mouse_opacity = 2

	var/list/HUD_element/_elements //child elements
	var/HUD_element/_parent //parent element
	var/client/_observer //each element is shown to at most 1 client
	var/_identifier //unique identitifier for this element, if such element is already seen by a client, it is closed first

	var/debugMode = FALSE
	var/debugColor = COLOR_WHITE

	var/_screenBottomLeftX = 1 //in screen_loc tiles
	var/_screenBottomLeftY = 1

	var/_scaleWidth = 1 //mutliplier of width
	var/_scaleHeight = 1

	var/_relativePositionX = 0 //in pixels, relative to parent
	var/_relativePositionY = 0

	var/_absolutePositionX = 0 //in pixels, actual map view coordinates
	var/_absolutePositionY = 0

	var/_iconWidth = 0 //in pixels
	var/_iconHeight = 0

	var/_width = 0 //in pixels
	var/_height = 0

	var/_currentAlignmentVertical = 0 //alignment within parent element
	var/_currentAlignmentHorizontal = 0

	var/_alignmentOffsetX = 0 //in pixels
	var/_alignmentOffsetY = 0

	var/_hideParentOnClick = FALSE
	var/_deleteOnHide = FALSE
	var/_hideParentOnHide = FALSE
	var/_passClickToParent = FALSE

	var/_clickProc //called when element is clicked
	var/_holder	//object that used with called proc
	var/list/_procArguments	//arguments that can be passed to proc

	var/list/_data //internal storage that can be utilized by _clickProc

	var/list/_iconOverlaysData = list()
	var/list/_iconUnderlaysData = list()
	var/list/_iconsBuffer = list()

	/*
	settings for animation that occur on mouse interactions
	*/
	var/_onClickedInteraction = FALSE
	var/_onClickedHighlightDuration
	var/_onClickedState = FALSE

	var/_onHoveredInteraction = FALSE
	var/_onHoveredState = FALSE

	var/_onToggledInteraction = FALSE
	var/_onToggledState = FALSE

/HUD_element/New(var/identifier)
	_elements = new
	_identifier = identifier
	updateIconInformation()

/HUD_element/Destroy()
	hide()

	if (_data)
		_data.Cut()

	var/list/HUD_element/elements = getElements()
	for(var/HUD_element/E in elements)
		elements -= E
		qdel(E)

	var/HUD_element/parent = getParent()
	if (parent)
		var/list/HUD_element/elementRemove = parent.getElements()
		elementRemove.Remove(src)
		_setParent()

	for(var/name in _iconsBuffer)
		qdel(_iconsBuffer[name])

	..()
	return QDEL_HINT_QUEUE

/HUD_element/Click(location,control,params)
	if (_clickProc)
		if(_holder)
			call(_holder, _clickProc)(arglist(_procArguments))
		else
			call(_clickProc)(src, usr, location, control, params)


	if (_passClickToParent)
		var/HUD_element/parent = getParent()
		if (parent)
			parent = parent.Click(location, control, params)
			if (!parent) //parent deleted
				return

	if (_hideParentOnClick)
		var/HUD_element/parent = getParent()
		if (parent)
			parent = parent.hide()
			if (!parent) //parent deleted
				return

// override if needed
/HUD_element/DblClick(var/location, var/control, var/params)
	return

/HUD_element/update_plane()
	return

/HUD_element/set_plane(var/np)
	plane = np

