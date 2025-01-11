shader_type spatial;
render_mode unshaded;

// vertex parameters
uniform sampler2D noise: source_color;
uniform float amplitude: hint_range(0.0, 10.0, 0.1) = 5.0;
uniform sampler2D curve;

// fragment parameters
uniform sampler2D albedo: source_color;

void vertex() {
	vec2 uv = (TIME * 0.01) + UV; // scroll the texture
	vec4 textur = texture(noise, uv) * amplitude * texture(curve, uv.yx).r; // make the texture
	VERTEX = vec3(VERTEX.x, (textur * VERTEX.y).y, VERTEX.z); // apply the texture to only the y coordinate
}

void fragment() {
	vec2 uv = (TIME * 0.01) + UV;
	ALBEDO = texture(albedo, uv).xyz;
	EMISSION = vec3(0.3);
}