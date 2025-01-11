shader_type spatial;
render_mode unshaded;

// vertex parameters
uniform sampler2D noise: source_color;
uniform float amplitude: hint_range(0.0, 10.0, 0.1) = 5.0;
uniform sampler2D curve;

// fragment parameters
uniform sampler2D albedo: source_color; // should be the same noise as noise, and a different color gradient

void vertex() {
	vec2 uv = (TIME * 0.01) + UV; // scroll the texture
	vec4 textur = texture(noise, uv) * amplitude * texture(curve, uv.yx).r; // make the texture, increase how high it is by amplitude, and increase how high it is around the edges
	VERTEX = vec3(VERTEX.x, (textur * VERTEX.y).y, VERTEX.z); // apply the texture to only the y coordinate
}

void fragment() {
	vec2 uv = (TIME * 0.01) + UV; // scroll the texture
	ALBEDO = texture(albedo, uv).xyz; // set the albedo
	EMISSION = vec3(0.3); // add some emission
}