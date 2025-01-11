shader_type spatial;

// vertex parameters
uniform sampler2D noise: source_color;
uniform float amplitude: hint_range(0.0, 10.0, 0.1) = 5.0;

// fragment parameters
uniform sampler2D color_gradient: source_color;

void vertex() {
	if (VERTEX.y > 0.0) { // check if it's the top half of the object
		vec2 uv = (TIME * 0.1) + UV; // scroll the texture
		vec4 textur = texture(noise, uv) * amplitude; // make the texture
		VERTEX = vec3(VERTEX.x, (textur * VERTEX.y).y, VERTEX.z); // apply the texture to only the y coordinate
	}
}

void fragment() {
	ALBEDO = texture(color_gradient, UV.yx).xyz;
	EMISSION = vec3(0.3);
}