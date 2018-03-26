vsSource = '
	attribute vec4 aVertexPosition;

	uniform mat4 uModelViewMatrix;
	uniform mat4 uProjectionMatrix;

	void main() {
		gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
	}'

fsSource = '
	void main() {
		gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
	}'

initShaderProgram = (gl, vsSource, fsSource) ->
	vertexShader = loadShader gl, gl.VERTEX_SHADER, vsSource
	fragmentShader = loadShader gl, gl.FRAMENT_SHADER, fsSource

	shaderProgram = gl.createProgram()

	gl.attachShader shaderProgram, vertexShader
	gl.attachShader shaderProgram, fragmentShader
	gl.linkProgram shaderProgram

	if !gl.getProgramParameter shaderProgram, gl.LINK_STATUS
		alert 'Unable to initilize shader!'
		return null

	return shaderProgram

loadShader = (gl, type, source) ->
	shader = gl.createShader type
	console.log '1'
	gl.shaderSource shader, source
	console.log '2'
	gl.compileShader shader
	console.log '3'
	if !gl.getShaderParameter shader, gl.COMPILE_STATUS
		alert 'An error in compiling shaders'
		gl.deleteShader shader
		return null

	return shader

canvas = document.querySelector '#glCanvas'
gl = canvas.getContext 'webgl'

if !gl
	alert 'Unable to initialize WebGL'
	return

shaderProgram = initShaderProgram gl, vsSource, fsSource

programInfo =
	program: shaderProgram
	attribLocations:
		vertexPosition: gl.getAttribLocation shaderProgram, 'aVertexPosition'
	uniformLocations:
		projectionMatrix: gl.getUniformLocation shaderProgram, 'uProjectionMatrix'
		modelViewMatrix: gl.getUniformLocation shaderProgram, 'uModelViewMatrix'

initBuffers = (gl) ->
	positionBuffer = gl.createBuffer()

	gl.bindBuffer gl.ARRAY_BUFFER, positionBuffer

	positions = [
		1.0, 1.0
		-1.0, 1.0
		1.0, -1.0
		-1.0, -1.0
	]

	gl.bufferData gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW

	return {
		position: positionBuffer
	}

drawScene = (gl, programInfo, buffers) ->
	gl.clearColor 0.0, 0.0, 0.0, 1.0
	gl.clearDepth 1.0
	gl.enable gl.DEPTH_TEST
	gl.depthFunc gl.LEQUAL

	gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

	fieldOfView = 45 * Math.PI / 180

	aspect = gl.canvas.clientWidth / gl.canvas.clientHeight

	zNear = 0.1
	zFar = 100.0
	projectionMatrix = mat4.create()

	mat4.perspective projectionMatrix, fieldOfView, aspect, zNear, zFar

	modelViewMatrix = mat4.create()

	mat4.translate modelViewMatrix, modelViewMatrix, [-0.0, 0.0, -6.0]

	numComponents = 2
	type = gl.FLOAT
	normalize = false
	stride = 0

	offset = 0

	gl.bindBuffer gl.ARRAY_BUFFER, buffers.position

	gl.vertexAttribPointer programInfo.attribLocations.vertexPosition, numComponents, type, normalize, stride, offset

	gl.enableVertexAttribArray programInfo.attribLocations.vertexPosition

	gl.useProgram programInfo.program

	gl.uniformMatrix4fv programInfo.uniformLocations.projectionMatrix, false, projectionMatrix
	gl.uniformMatrix4fv programInfo.uniformLocations.modelViewMatrix, false, modelViewMatrix

	offset = 0
	vertexCount = 4
	gl.drawArrays gl.TRIANGLE_STRIP, offset, vertexCount
