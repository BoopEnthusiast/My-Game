shader_type spatial;

uniform sampler2D noise: source_color;
uniform float amplitude: hint_range(0.0, 10.0, 0.1) = 5.0;

uniform sampler2D color_gradient: source_color;

void vertex() {
	if (VERTEX.y > 0.0) {
		vec2 uv = (TIME * 0.1) + UV;
		vec4 textur = texture(noise, uv) * amplitude;
		VERTEX = vec3(VERTEX.x, (textur * VERTEX.y).y, VERTEX.z);
	}
}

void fragment() {
	ALBEDO = texture(color_gradient, UV.yx).xyz;
	EMISSION = vec3(0.3);
}