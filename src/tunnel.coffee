sqRotation = 0.0
deltaTime = 0.1

#
# initBuffers
#
# Initialize the buffers we'll need. For this demo, we just
# have one object -- a simple two-dimensional square.
#

initBuffers = (gl) ->
	faceColors = [
		[1.0, 0.5, 0.0, 1.0],			# Front: WHITE
		[1.0, 0.0, 0.0, 1.0],			# Back: RED
		[0.0, 1.0, 0.0, 1.0],			# Top: GREEN
		[0.0, 0.0, 1.0, 1.0],			# Bottom: BLUE
		[1.0, 1.0, 0.0, 1.0],    	# Right face: YELLOW
		[1.0, 0.0, 1.0, 1.0],    	# Left face: PURPLE
		[1.0, 0.5, 1.0, 1.0],    	# Left face: PURPLE
		[0.0, 1.0, 0.7, 1.0],    	# Left face: PURPLE
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
		0,  1,  2,      0,  2,  3,    # 1
		4,  5,  6,      4,  6,  7,    # 2
		8,  9,  10,     8,  10, 11,   # 3
		12, 13, 14,     12, 14, 15,   # 4
		16, 17, 18,     16, 18, 19,   # 5
		20, 21, 22,     20, 22, 23,   # 6
		24, 25, 26,     24, 26, 27,   # 7
		28, 29, 30,     28, 30, 31,   # 8
	]

	gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indices), gl.STATIC_DRAW

	# Create a buffer for the square's positions.
	positionBuffer = gl.createBuffer()
	# Select the positionBuffer as the one to apply buffer
	# operations to from here out.
	gl.bindBuffer gl.ARRAY_BUFFER, positionBuffer
	# Now create an array of positions for the square.
	numVertex = 8
	angle = 2 * Math.PI / numVertex
	positions = []

	temp = [Math.cos(0), Math.sin(0), -2.0]
	positions.concat temp
	temp = [Math.cos(0), Math.sin(0), -5.0]
	positions.concat temp

	for i in [1..7]
		temp = [Math.cos(i * angle), Math.sin(i * angle), -5.0]
		positions.concat temp
		temp = [Math.cos(i * angle), Math.sin(i * angle), -2.0]
		positions.concat temp
		temp = [Math.cos(i * angle), Math.sin(i * angle), -2.0]
		positions.concat temp
		temp = [Math.cos(i * angle), Math.sin(i * angle), -5.0]
		positions.concat temp

	temp = [Math.cos(0), Math.sin(0), -5.0]
	positions.concat temp
	temp = [Math.cos(0), Math.sin(0), -2.0]
	positions.concat temp

	# Now pass the list of positions into WebGL to build the
	# shape. We do this by creating a Float32Array from the
	# JavaScript array, then use it to fill the current buffer.
	gl.bufferData gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW

	{position: positionBuffer, color: colorBuffer, indices: indexBuffer}


#
# Draw the scene.
#

drawScene = (gl, programInfo, buffers, deltaTime) ->
	# Create a perspective matrix, a special matrix that is
	# used to simulate the distortion of perspective in a camera.
	# Our field of view is 45 degrees, with a width/height
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
	mat4.translate modelViewMatrix, modelViewMatrix, [-0.0, 0.0, -8.0]
	mat4.rotate modelViewMatrix, modelViewMatrix, sqRotation, [0.0, 0.0, 1.0]
	mat4.rotate modelViewMatrix, modelViewMatrix, sqRotation, [0.0, 1.0, 0.0]
	# amount to translate
	# Tell WebGL how to pull out the positions from the position
	# buffer into the vertexPosition attribute.
	numComponents = 3
	type = gl.FLOAT
	normalize = false
	stride = 0
	offset = 0
	gl.bindBuffer gl.ARRAY_BUFFER, buffers.position
	gl.vertexAttribPointer programInfo.attribLocations.vertexPosition, numComponents, type, normalize, stride, offset
	gl.enableVertexAttribArray programInfo.attribLocations.vertexPosition



	# Use colors when drawing
	numComponents = 4
	type = gl.FLOAT
	normalize = false
	stride = 0
	offset = 0
	gl.bindBuffer gl.ARRAY_BUFFER, buffers.color
	gl.vertexAttribPointer programInfo.attribLocations.vertexColor, numComponents, type, normalize, stride, offset
	gl.enableVertexAttribArray programInfo.attribLocations.vertexColor

	gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, buffers.indices

	vertexCount = 48
	type = gl.UNSIGNED_SHORT
	offset = 0


	gl.drawElements gl.TRIANGLES, vertexCount, type, offset


	# Tell WebGL to use our program when drawing
	gl.useProgram programInfo.program
	# Set the shader uniforms
	gl.uniformMatrix4fv programInfo.uniformLocations.projectionMatrix, false, projectionMatrix
	gl.uniformMatrix4fv programInfo.uniformLocations.modelViewMatrix, false, modelViewMatrix


	offset = 0
	vertexCount = 4
	gl.drawArrays gl.TRIANGLE_STRIP, offset, vertexCount


	sqRotation += deltaTime
	return


module.exports =
	initBuffers: initBuffers
	drawScene: drawScene
