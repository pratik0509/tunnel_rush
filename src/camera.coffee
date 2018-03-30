class Camera
	constructor: ->
		@camMatrix		= mat4.create()
		@cameraMatrix	= mat4.create()
		@radius 		= 0.4
		@angle			= Math.PI / 2

	translate: (newRad) =>

		mat4.translate @cameraMatrix, @camMatrix, [0, @radius, 0]
		# mat4.invert @viewmatrix, @cameraMatrix

	rotate: (angle) =>
		if angle < 0
			if @angle < 0
				angle = 0
		if angle > 0
			if @angle > Math.PI
				angle = 0
		@angle += angle
		mat4.translate @cameraMatrix, @camMatrix, [@radius * Math.cos(@angle), @radius * Math.sin(@angle), 0]
		# mat4.invert @viewmatrix, @cameraMatrix

	getViewMatrix: =>
		@cameraMatrix


module.exports = Camera
