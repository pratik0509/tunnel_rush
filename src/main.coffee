utils		= require './utils.js'
vsSource	= require '../assets/vertexshader.js'
fsSource	= require '../assets/fragmentshader.js'
cube		= require '../lib/cube.js'
Tunnel		= require '../lib/tunnel.js'
Bar			= require '../lib/bar.js'
Camera		= require '../lib/camera.js'

main = ->
	canvas = document.querySelector '#glCanvas'
	gl = canvas.getContext 'webgl'
	# If we don't have a GL context, give up now
	if !gl
		alert 'Unable to initialize WebGL. Your browser or machine may not support it.'
		return
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
			textureCoord: gl.getAttribLocation shaderProgram, 'aTextureCoord'
		uniformLocations:
			projectionMatrix: gl.getUniformLocation shaderProgram, 'uProjectionMatrix'
			modelViewMatrix: gl.getUniformLocation shaderProgram, 'uModelViewMatrix'
			uSampler: gl.getUniformLocation shaderProgram, 'uSampler'
	# Here's where we call the routine that builds all the
	# objects we'll be drawing.
	# tunnel = new Tunnel()
	# buffersTunnel = tunnel.initBuffers gl
	cam = new Camera()
	cam.translate [0, -0.4, 0]

	tunnels = []
	tunnels.push new Tunnel()
	tunnels[0].initBuffers gl

	bars = []
	bars.push new Bar()
	bars[0].initBuffers gl
	# buffersTunnel.push(tunnel.initBuffers(gl))
	# textureCube = utils.loadTexture gl, './assets/dark-mosaic.png'
	textureOct = utils.loadTexture gl, './assets/speckled.jpg'
	textureBar = utils.loadTexture gl, './assets/wood.jpg'
	addTunnelTrigger = 0
	addWallTrigger = 0
	# Draw the scene

	prev = 0
	render = (now) ->
		now *= 0.001
		delTime = now - prev
		prev = now
		initScene gl
		shift = 0
		i = 0
		while i < bars.length
			pos = bars[i].getPosition()
			if pos[2] > 3
				++shift
			bars[i].drawScene gl, programInfo, textureBar, delTime, cam
			newPos = bars[i].getPosition()
			bars[i].translateCoord[2] += 0.03
			++i
		i = 0
		while i < tunnels.length
			pos = tunnels[i].getPosition()
			if pos[2] > 5
				++shift
			tunnels[i].drawScene gl, programInfo, textureOct, delTime, cam
			newPos = tunnels[i].getPosition()
			tunnels[i].translateCoord[2] += 0.03
			++i
		# while shift > 0
		# 	tunnels.shift()
		# 	--shift
		if addTunnelTrigger == 50
			tunnels.push new Tunnel()
			tunnels[tunnels.length - 1].initBuffers gl
			newPos = tunnels[tunnels.length - 1].getPosition()
			newPos[2] -= tunnels[tunnels.length - 1].getWidth()
			tunnels[tunnels.length - 1].setPosition newPos
			addTunnelTrigger = 0

		if addWallTrigger == 150
			bars.push new Bar()
			bars[bars.length - 1].initBuffers gl
			addWallTrigger = 0


		++addTunnelTrigger
		++addWallTrigger

		requestAnimationFrame render

	requestAnimationFrame render

	return


#
# Initialize Scene
#

initScene = (gl) ->
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

#
# Camera Matrix
#


window.onload = ->
	main()
