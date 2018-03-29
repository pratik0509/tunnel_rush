#
# Start here
#
sqRotation = 0.0
deltaTime = 0.1

main = ->
	canvas = document.querySelector '#glCanvas'
	gl = canvas.getContext 'webgl'
	# If we don't have a GL context, give up now
	if !gl
		alert 'Unable to initialize WebGL. Your browser or machine may not support it.'
		return
	# Vertex shader program
	vsSource = '
		attribute vec4 aVertexPosition;
		attribute vec4 aVertexColor;

		uniform mat4 uModelViewMatrix;
		uniform mat4 uProjectionMatrix;

		varying lowp vec4 vColor;
		void main() {
			gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
			vColor = aVertexColor;
		}'
	# Fragment shader program
	fsSource = '
		varying lowp vec4 vColor;
		void main() {
			gl_FragColor = vColor;
		}'
	# Initialize a shader program; this is where all the lighting
	# for the vertices and so forth is established.
	shaderProgram = initShaderProgram(gl, vsSource, fsSource)
	# Collect all the info needed to use the shader program.
	# Look up which attribute our shader program is using
	# for aVertexPosition and look up uniform locations.
	programInfo =
		program: shaderProgram
		attribLocations:
			vertexPosition: gl.getAttribLocation shaderProgram, 'aVertexPosition'
			vertexColor: gl.getAttribLocation shaderProgram, 'aVertexColor'
		uniformLocations:
			projectionMatrix: gl.getUniformLocation shaderProgram, 'uProjectionMatrix'
			modelViewMatrix: gl.getUniformLocation shaderProgram, 'uModelViewMatrix'
	# Here's where we call the routine that builds all the
	# objects we'll be drawing.
	buffers = initBuffers(gl)
	# Draw the scene

	prev = 0
	render = (now) ->
		now *= 0.001
		delTime = now - prev
		prev = now
		drawScene gl, programInfo, buffers, delTime
		requestAnimationFrame render

	requestAnimationFrame render

	return

#
# initBuffers
#
# Initialize the buffers we'll need. For this demo, we just
# have one object -- a simple two-dimensional square.
#

initBuffers = (gl) ->
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

	# Create a buffer for the square's positions.
	positionBuffer = gl.createBuffer()
	# Select the positionBuffer as the one to apply buffer
	# operations to from here out.
	gl.bindBuffer gl.ARRAY_BUFFER, positionBuffer
	# Now create an array of positions for the square.
	positions = [
		# // Front face
		-1.0, -1.0,  1.0,
		1.0, -1.0,  1.0,
		1.0,  1.0,  1.0,
		-1.0,  1.0,  1.0,

		# // Back face
		-1.0, -1.0, -1.0,
		-1.0,  1.0, -1.0,
		1.0,  1.0, -1.0,
		1.0, -1.0, -1.0,

		# // Top face
		-1.0,  1.0, -1.0,
		-1.0,  1.0,  1.0,
		1.0,  1.0,  1.0,
		1.0,  1.0, -1.0,

		# // Bottom face
		-1.0, -1.0, -1.0,
		1.0, -1.0, -1.0,
		1.0, -1.0,  1.0,
		-1.0, -1.0,  1.0,

		# // Right face
		1.0, -1.0, -1.0,
		1.0,  1.0, -1.0,
		1.0,  1.0,  1.0,
		1.0, -1.0,  1.0,

		# // Left face
		-1.0, -1.0, -1.0,
		-1.0, -1.0,  1.0,
		-1.0,  1.0,  1.0,
		-1.0,  1.0, -1.0,
	]

	# Now pass the list of positions into WebGL to build the
	# shape. We do this by creating a Float32Array from the
	# JavaScript array, then use it to fill the current buffer.
	gl.bufferData gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW
	{position: positionBuffer, color: colorBuffer, indices: indexBuffer}

#
# Draw the scene.
#

drawScene = (gl, programInfo, buffers, deltaTime) ->
	gl.clearColor 0.0, 0.0, 0.0, 1.0
	# Clear to black, fully opaque
	gl.clearDepth 1.0
	# Clear everything
	gl.enable gl.DEPTH_TEST
	# Enable depth testing
	gl.depthFunc gl.LEQUAL
	# Near things obscure far things
	# Clear the canvas before we start drawing on it.
	gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
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
	mat4.translate modelViewMatrix, modelViewMatrix, [-0.0, 0.0, -5.0]
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

	vertexCount = 36
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

#
# Initialize a shader program, so WebGL knows how to draw our data
#

initShaderProgram = (gl, vsSource, fsSource) ->
	vertexShader = loadShader(gl, gl.VERTEX_SHADER, vsSource)
	fragmentShader = loadShader(gl, gl.FRAGMENT_SHADER, fsSource)
	# Create the shader program
	shaderProgram = gl.createProgram()
	gl.attachShader shaderProgram, vertexShader
	gl.attachShader shaderProgram, fragmentShader
	gl.linkProgram shaderProgram
	# If creating the shader program failed, alert
	if !gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)
		alert 'Unable to initialize the shader program: ' + gl.getProgramInfoLog(shaderProgram)
		return null
	shaderProgram

#
# creates a shader of the given type, uploads the source and
# compiles it.
#

loadShader = (gl, type, source) ->
	shader = gl.createShader type
	# Send the source to the shader object
	gl.shaderSource shader, source
	# Compile the shader program
	gl.compileShader shader
	# See if it compiled successfully
	if !gl.getShaderParameter(shader, gl.COMPILE_STATUS)
		alert 'An error occurred compiling the shaders: ' + gl.getShaderInfoLog(shader)
		gl.deleteShader shader
		return null
	shader

main()
