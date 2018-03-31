class Camera
	constructor: ->
		@camMatrix		= mat4.create()
		@cameraMatrix	= mat4.create()
		@constRadius	= 0.4
		@radius 		= 0.4
		@angle			= Math.PI / 2
		@isJumping		= false
		@jumpSpeed		= 0.01
		@constJumpSpeed	= 0.01
		@jumpDecc		= 0.0005

	translate: (newRad) =>
		mat4.translate @cameraMatrix, @camMatrix, [0, @radius, 0]

	rotate: (angle) =>
		if angle < 0
			if @angle < 0
				angle = 0
		if angle > 0
			if @angle > Math.PI
				angle = 0
		@angle += angle
		mat4.translate @cameraMatrix, @camMatrix, [@radius * Math.cos(@angle), @radius * Math.sin(@angle), 0]

	jump: () ->
		if !@isJumping
			return

		if Math.abs(@radius) > @constRadius + 0.01
			@radius = @constRadius
			@isJumping = false
			@jumpSpeed = @constJumpSpeed
			return

		@radius 	-= @jumpSpeed
		@jumpSpeed	-= @jumpDecc
		mat4.translate @cameraMatrix, @camMatrix, [@radius * Math.cos(@angle), @radius * Math.sin(@angle), 0]

	getViewMatrix: =>
		@cameraMatrix


module.exports = Camera
