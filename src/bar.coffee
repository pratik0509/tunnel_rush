utils		= require './utils.js'

#
# initBuffers
#
# Initialize the buffers we'll need. For this demo, we just
# have one object -- a simple two-dimensional square.
#
class Bar
	constructor: ->
		@sqRotation = (45.0 / 2.0) * Math.PI / 180.0 + Math.random() * 2
		@deltaFactor = -0.4 - Math.random()
		@translateCoord = [-0.0, 0.0, -15.0]
		@width = 3
		@buffers = undefined

	initBuffers: (gl) =>


		# Create a buffer for the square's positions.
		positionBuffer = gl.createBuffer()
		# Select the positionBuffer as the one to apply buffer
		# operations to from here out.
		gl.bindBuffer gl.ARRAY_BUFFER, positionBuffer

		# Now create an array of positions for the octagon.
		twidth = 0.10
		height = 1.0
		thick = 0.01

		positions = [
			# // Front face
			-twidth, -height,  thick,
			twidth, -height,  thick,
			twidth,  height,  thick,
			-twidth,  height,  thick,

			# // Back face
			-twidth, -height, -thick,
			-twidth,  height, -thick,
			twidth,  height, -thick,
			twidth, -height, -thick,

			# // Top face
			-twidth,  height, -thick,
			-twidth,  height,  thick,
			twidth,  height,  thick,
			twidth,  height, -thick,

			# // Bottom face
			-twidth, -height, -thick,
			twidth, -height, -thick,
			twidth, -height,  thick,
			-twidth, -height,  thick,

			# // Right face
			twidth, -height, -thick,
			twidth,  height, -thick,
			twidth,  height,  thick,
			twidth, -height,  thick,

			# // Left face
			-twidth, -height, -thick,
			-twidth, -height,  thick,
			-twidth,  height,  thick,
			-twidth,  height, -thick,
		]

		# Now pass the list of positions into WebGL to build the
		# shape. We do this by creating a Float32Array from the
		# JavaScript array, then use it to fill the current buffer.
		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW

		faceColors = [
			[1.0, 1.0, 1.0, 1.0],			# Front: WHITE
			[1.0, 0.0, 0.0, 1.0],			# Back: RED
			[0.0, 1.0, 0.0, 1.0],			# Top: GREEN
			[0.0, 0.0, 1.0, 1.0],			# Bottom: BLUE
			[1.0, 1.0, 0.0, 1.0],    	# Right face: YELLOW
			[1.0, 0.0, 1.0, 1.0],    	# Left face: PURPLE
		]

		colors = []
		for i in faceColors
			colors = colors.concat i, i, i, i

		colorBuffer = gl.createBuffer()
		gl.bindBuffer gl.ARRAY_BUFFER, colorBuffer
		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW

		indexBuffer = gl.createBuffer()
		gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, indexBuffer

		indices = [
			0,  1,  2,      0,  2,  3,    # front
			4,  5,  6,      4,  6,  7,    # back
			8,  9,  10,     8,  10, 11,   # top
			12, 13, 14,     12, 14, 15,   # bottom
			16, 17, 18,     16, 18, 19,   # right
			20, 21, 22,     20, 22, 23,   # left
		]

		gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indices), gl.STATIC_DRAW

		textureCoordBuffer = gl.createBuffer()
		gl.bindBuffer gl.ARRAY_BUFFER, textureCoordBuffer


		textureCoordinates = [
			 # Front
			0.0,  0.0,
			1.0,  0.0,
			1.0,  1.0,
			0.0,  1.0,
			 # Back
			0.0,  0.0,
			1.0,  0.0,
			1.0,  1.0,
			0.0,  1.0,
			 # Top
			0.0,  0.0,
			1.0,  0.0,
			1.0,  1.0,
			0.0,  1.0,
			# // Bottom
			0.0,  0.0,
			1.0,  0.0,
			1.0,  1.0,
			0.0,  1.0,
			# // Right
			0.0,  0.0,
			1.0,  0.0,
			1.0,  1.0,
			0.0,  1.0,
			# // Left
			0.0,  0.0,
			1.0,  0.0,
			1.0,  1.0,
			0.0,  1.0,
		]

		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(textureCoordinates), gl.STATIC_DRAW

		@buffers =
			position: positionBuffer
			color: colorBuffer
			indices: indexBuffer
			textureCoord: textureCoordBuffer

		@buffers
		# {position: positionBuffer, color: colorBuffer, indices: indexBuffer}


	#
	# Draw the scene.
	#

	drawScene: (gl, programInfo, texture, deltaTime, cam) =>
		utils.initDrawScene gl

		# Create a perspective matrix, a special matrix that is
		# used to simulate the distortion of perspective in a camera.
		# Our field of view is 45 degrees, with a @width/height
		# ratio that matches the display size of the canvas
		# and we only want to see objects between 0.1 units
		# and 100 units away from the camera.
		fieldOfView = 45 * Math.PI / 180
		# in radians
		aspect = gl.canvas.clientWidth / gl.canvas.clientHeight
		zNear = 0.1
		zFar = 100.0
		projectionMatrix = mat4.create()
		# note: glmatrix.js always has the first argument
		# as the destination to receive the result.
		mat4.perspective projectionMatrix, fieldOfView, aspect, zNear, zFar
		# Set the drawing position to the "identity" point, which is
		# the center of the scene.
		modelViewMatrix = mat4.create()
		# Now move the drawing position a bit to where we want to
		# start drawing the square.
		mat4.translate modelViewMatrix, modelViewMatrix, @translateCoord
		mat4.rotate modelViewMatrix, modelViewMatrix, @sqRotation, [0.0, 0.0, 1.0]
		mat4.multiply modelViewMatrix, cam.getViewMatrix(), modelViewMatrix

		# Tell WebGL to use our program when drawing
		# Set the shader uniforms
		gl.useProgram programInfo.program
		gl.uniformMatrix4fv programInfo.uniformLocations.projectionMatrix, false, projectionMatrix
		gl.uniformMatrix4fv programInfo.uniformLocations.modelViewMatrix, false, modelViewMatrix

		# mat4.rotate modelViewMatrix, modelViewMatrix, @sqRotation, [0.0, 1.0, 0.0]
		# amount to translate
		# Tell WebGL how to pull out the positions from the position
		# buffer into the vertexPosition attribute.
		numComponents = 3
		type = gl.FLOAT
		normalize = false
		stride = 0
		offset = 0
		gl.bindBuffer gl.ARRAY_BUFFER, @buffers.position
		gl.vertexAttribPointer programInfo.attribLocations.vertexPosition, numComponents, type, normalize, stride, offset
		gl.enableVertexAttribArray programInfo.attribLocations.vertexPosition

		# Use colors when drawing
		numComponents = 4
		type = gl.FLOAT
		normalize = false
		stride = 0
		offset = 0
		gl.bindBuffer gl.ARRAY_BUFFER, @buffers.color
		gl.vertexAttribPointer programInfo.attribLocations.vertexColor, numComponents, type, normalize, stride, offset
		# Disable for only those which have texture only
		if texture
			gl.disableVertexAttribArray programInfo.attribLocations.vertexColor
			gl.vertexAttrib4f programInfo.attribLocations.vertexColor, 1, 1, 1, 1
		else
			gl.enableVertexAttribArray programInfo.attribLocations.vertexColor

		num = 2
		type = gl.FLOAT
		normalize = false
		stride = 0
		offset = 0
		gl.bindBuffer gl.ARRAY_BUFFER, @buffers.textureCoord
		gl.vertexAttribPointer programInfo.attribLocations.textureCoord, num, type, normalize, stride, offset
		gl.enableVertexAttribArray programInfo.attribLocations.textureCoord

		gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, @buffers.indices

		vertexCount = 36
		type = gl.UNSIGNED_SHORT
		offset = 0

		# Activate texture
		# Tell WebGL we want to affect texture unit 0
		gl.activeTexture gl.TEXTURE0

		# Bind the texture to texture unit 0
		gl.bindTexture gl.TEXTURE_2D, texture

		# Tell the shader we bound the texture to texture unit 0
		gl.uniform1i programInfo.uniformLocations.uSampler, 0

		gl.drawElements gl.TRIANGLES, vertexCount, type, offset

		@sqRotation += deltaTime * @deltaFactor
		return


	setPosition: (pos) =>
		if pos.length != 3
			return
		@translateCoord = pos

	getPosition: =>
		@translateCoord

	getWidth: =>
		@width

module.exports = Bar
