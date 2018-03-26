class Main
	canvas 		= document.querySelector "#glCanvas"
	gl			= canvas.getContext "webgl"
	vsSource 	= '''
		attribute vec4 aVertexPosition;
		uniform mat4 uModelViewMatrix;
		uniform mat4 uProjectionMatrix;

		void main() {
			gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
		}
	'''
	fsSource 	= '''
		void main() {
			gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
		}
	'''

	constructor: ->

		if !gl
			alert 'Unable to initialize WebGL'
			return

		gl.clearColor 0.0, 0.0, 0.0, 1.0
		gl.clear gl.COLOR_BUFFER_BIT

main = new Main()
