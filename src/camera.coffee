class Camera
	constructor: ->
		@cameraMatrix	= mat4.create()

	translate: (newPos) =>
		newPos[0] *= -1
		newPos[1] *= -1
		newPos[2] *= -1
		mat4.translate @cameraMatrix, @cameraMatrix, newPos
		# mat4.invert @viewmatrix, @cameraMatrix

	rotate: (angle, axis) =>
		mat4.rotate @cameraMatrix, @cameraMatrix, angle, axis
		# mat4.invert @viewmatrix, @cameraMatrix

	getViewMatrix: =>
		@cameraMatrix


module.exports = Camera
