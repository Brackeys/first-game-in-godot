shader_type canvas_item;

// Intensidad del flash blanco (0 = normal, 1 = completamente blanco)
uniform float flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	// Mezclamos el color del sprite hacia blanco según la intensidad del flash
	tex.rgb = mix(tex.rgb, vec3(1.0), flash);
	COLOR = tex;
}
