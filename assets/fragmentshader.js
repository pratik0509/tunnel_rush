 // Fragment shader program

fsSource = `
	varying lowp vec4 vColor;
	varying highp vec2 vTextureCoord;

	uniform sampler2D uSampler;
	uniform int uLight;

	void main() {
		if (uLight != 0) {
			gl_FragColor = texture2D(uSampler, vTextureCoord) * vColor;
		} else {
			lowp vec4 samp = texture2D(uSampler, vTextureCoord);
			lowp float gray = 0.2 * samp.r + 0.7 * samp.g + 0.07 * samp.b;
			gl_FragColor = vec4(gray, gray, gray, 1.0);
		}
		// gl_FragColor = vColor;
	}`;

module.exports = fsSource;
