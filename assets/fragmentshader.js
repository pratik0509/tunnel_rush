 // Fragment shader program

fsSource = `
	varying lowp vec4 vColor;
	varying highp vec2 vTextureCoord;

	uniform sampler2D uSampler;

	void main() {
		gl_FragColor = texture2D(uSampler, vTextureCoord) * vColor;
		// gl_FragColor = vColor;
	}`;

module.exports = fsSource;