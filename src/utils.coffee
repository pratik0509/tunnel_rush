initDrawScene = (gl) ->
	gl.clearColor 0.0, 0.0, 0.0, 1.0
	# Clear to black, fully opaque
	gl.clearDepth 1.0
	# Clear everything
	gl.enable gl.DEPTH_TEST
	# Enable depth testing
	gl.depthFunc gl.LEQUAL
	# gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

loadTexture = (gl, url) ->
	texture = gl.createTexture()
	gl.bindTexture gl.TEXTURE_2D, texture

	level = 0
	internalFormat = gl.RGBA
	width = 1
	height = 1
	border = 0
	srcFormat = gl.RGBA
	srcType = gl.UNSIGNED_BYTE
	pixel = new Uint8Array [255, 255, 255, 255]
	gl.texImage2D gl.TEXTURE_2D, level, internalFormat, width, height, border, srcFormat, srcType, pixel
	image = new Image()

	image.onload = ->
		gl.bindTexture gl.TEXTURE_2D, texture
		gl.texImage2D gl.TEXTURE_2D, level, internalFormat, srcFormat, srcType, image

		if isPowerOf2(image.width) && isPowerOf2(image.height)
			gl.generateMipmap gl.TEXTURE_2D

		else
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR

		return

	image.src = url

	texture

isPowerOf2 = (val) ->
	val & (val - 1) == 0


detectCollision = (cam, obstacle) ->
	temp = Math.abs(cam.angle - obstacle.sqRotation - (Math.PI / 2))
	while temp > Math.PI
		temp -= Math.PI
	(temp <= 1 && Math.abs(obstacle.translateCoord[2] - 0.01) < obstacle.width)

module.exports =
	loadTexture: loadTexture
	initDrawScene: initDrawScene
	detectCollision: detectCollision
