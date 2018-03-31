utils		= require './utils.js'
vsSource	= require '../assets/vertexshader.js'
fsSource	= require '../assets/fragmentshader.js'
cube		= require '../lib/cube.js'
Tunnel		= require '../lib/tunnel.js'
Bar			= require '../lib/bar.js'
Coin		= require '../lib/coin.js'
Camera		= require '../lib/camera.js'

DEL_ANG = 0.015
SCORE = 0.0
LEVEL = 1
cam = new Camera()
cam.translate -0.4

oct = ['tun1.jpg', 'tun2.png', 'tun3.jpg', 'tun4.jpg', 'tun5.jpg', 'tun6.jpg', 'tun7.jpg', 'tun8.jpg']
br = ['bar1.jpg', 'bar2.jpg', 'bar3.jpg', 'bar4.jpg', 'bar5.jpg', 'bar6.jpg', 'bar7.jpg', 'bar8.jpg']
num = oct.length

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
			light: gl.getUniformLocation shaderProgram, 'uLight'
			flash: gl.getUniformLocation shaderProgram, 'uFlash'

	color = 1
	flash = 1.0
	gl.uniform1i programInfo.uniformLocations.light, color
	gl.uniform1f programInfo.uniformLocations.flash, flash

	Mousetrap.bind 't', () ->
		color = 1 - color
		gl.uniform1i programInfo.uniformLocations.light, color
		return

	# Here's where we call the routine that builds all the
	# objects we'll be drawing.
	# tunnel = new Tunnel()
	# buffersTunnel = tunnel.initBuffers gl

	tunnels = []
	tunnels.push new Tunnel()
	tunnels[0].initBuffers gl

	bars = []
	bars.push new Bar(LEVEL)
	bars[0].initBuffers gl

	coins = []
	# coins.push new Coin()
	# coins[0].initBuffers gl

	i = 0
	textureGold= utils.loadTexture gl, './assets/gold.jpg'
	textureOct = utils.loadTexture gl, './assets/none'
	textureBar = utils.loadTexture gl, './assets/none'
	func = ->
		textureOct = utils.loadTexture gl, './assets/' + oct[i % num]
		textureBar = utils.loadTexture gl, './assets/' + br[i % num]
		++i
		++LEVEL
		return

	establishChange = ->
		i = 0
		textureOct = utils.loadTexture gl, './assets/' + oct[i % num]
		textureBar = utils.loadTexture gl, './assets/' + br[i % num]
		++i
		setInterval func, 25 * 1000

	setTimeout establishChange, 3 * 1000

	# Change to get flash effect
	periodicFlash = ->
		flash += 0.00
		if flash > 1.5
			flash = 1.0
		gl.uniform1f programInfo.uniformLocations.flash, flash
		return

	setInterval periodicFlash, 200

	addTunnelTrigger = 0
	addWallTrigger = 0
	addCoinTrigger = 0
	# Draw the scene

	prev = 0
	render = (now) ->
		now *= 0.001
		delTime = now - prev
		prev = now
		initScene gl
		SCORE += LEVEL
		document.getElementById("level").innerHTML = "LEVEL:  " + LEVEL;
		document.getElementById("score").innerHTML = "SCORE:  " + SCORE;
		cam.jump()
		shift = 0
		i = 0
		while i < bars.length
			pos = bars[i].getPosition()
			if pos[2] > 3
				++shift
			bars[i].drawScene gl, programInfo, textureBar, delTime * LEVEL, cam
			if utils.detectCollision cam, bars[i]
				console.log 'Game Over!'
				exit()
			newPos = bars[i].getPosition()
			bars[i].translateCoord[2] += 0.03
				# while true
				# 	j = 0
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
		i = 0
		while i < coins.length
			if !coins[i].used && utils.detectCoin cam, coins[i]
				!coins[i].used = true
				SCORE += coins[i].points
			pos = coins[i].getPosition()
			if pos[2] > 5
				++shift
			coins[i].drawScene gl, programInfo, textureGold, delTime, cam
			newPos = coins[i].getPosition()
			coins[i].translateCoord[2] += 0.03
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
			bars.push new Bar(LEVEL)
			bars[bars.length - 1].initBuffers gl
			addWallTrigger = 0

		if addCoinTrigger == 500
			coins.push new Coin()
			coins[coins.length - 1].initBuffers gl
			addCoinTrigger = 0

		++addTunnelTrigger
		++addWallTrigger
		++addCoinTrigger

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

Mousetrap.bind 'a', () ->
	cam.rotate -DEL_ANG
	return

Mousetrap.bind 'd', () ->
	cam.rotate +DEL_ANG
	return

Mousetrap.bind 'w', () ->
	if !cam.isJumping
		cam.isJumping = true
	return


window.onload = ->
	main()
