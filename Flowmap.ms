(
	local obj, meshVerts, prevMousePos

	fn gammaCorrect clr gamma =
		[clr.x^gamma, clr.y^gamma, clr.z^gamma]

	fn mouseVec dir =
		normalize [dir.x, dir.y, 0]

	fn getColor dir strength:0.2 =
		gammaCorrect ([.5,.5,0] - .5 * strength * mouseVec dir) 1.0

	fn setMeshVertColor vert color strength =
		meshop.setMapVert obj 0 vert (strength * color + (1 - strength) * meshop.getMapVert obj 0 vert)

	fn startStroke =
		thePainterInterface.undoStart()

	fn paintStroke localHit:[0,0,0] localNormal:[0,0,0] worldHit:[0,0,0] worldNormal:[0,0,0] radius:0 strength:0 =
	(
		local mousePos = mouse.pos
		local isHit = thePainterInterface.getIsHit 0
		local verts = thePainterInterface.getPointGatherHits obj
		thePainterInterface.getHitPointData &localHit &localNormal &worldHit &worldNormal &radius &strength 0

		if isKindOf prevMousePos Point2 and isHit do
		(
			if distance mousePos prevMousePos >= 1 then 
			(
				local color = getColor (mousePos - prevMousePos)

				for vert in verts where distance worldHit meshVerts[vert] < radius do
					setMeshVertColor vert color (thePainterInterface.getPointGatherStr obj vert) 

				update obj
			)
			else mousePos = prevMousePos
		)
		prevMousePos = mousePos 
	)

	fn endStroke =
		thePainterInterface.undoAccept()

	fn cancelStroke =
		thePainterInterface.undoCancel()

	fn systemEnd =
		thePainterInterface.endPaintSession()

	if selection.count == 1 and isKindOf $ Editable_mesh then
	(
		max select
		setRefCoordsys #world
		obj = selection[1]
		meshVerts = meshop.getVerts obj #all
		baseColor = gammaCorrect [0.5,0.5,0] 1.0

		obj.showVertexColors = on
		defaultVCFaces obj
		for vert = 1 to obj.numVerts do meshop.setMapVert obj 0 vert baseColor
		update obj		

		thePainterInterface.scriptFunctions startStroke paintStroke endStroke cancelStroke systemEnd
		thePainterInterface.initializeNodes 0 #(obj)
		thePainterInterface.offMeshHitType = 2
		thePainterInterface.pointGatherEnable = on
		thePainterInterface.startPaintSession()
	)
	else messageBox "No Editable mesh selected"
)