shader_type spatial;

void vertex() {
	vec2 uv = (TIME * 0.1) + UV;
}

void fragment() {
	// Called for every pixel the material is visible on.
}