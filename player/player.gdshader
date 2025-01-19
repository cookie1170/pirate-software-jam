shader_type spatial;

uniform sampler2D noise_texture;
uniform sampler2D gradient;

void fragment() {
	vec2 offset_uv_1;
	offset_uv_1 = vec2(TIME / 10.0, 0.0);
	vec2 offset_uv_2;
	offset_uv_2 = vec2(0.0, TIME / 10.0);
	vec4 mixed_texture = mix(
		texture(noise_texture, UV + offset_uv_1),
		texture(noise_texture, UV - offset_uv_2),
		0.5
	);
	vec4 mapped_texture = texture(gradient, vec2(mixed_texture.r));
	ALBEDO = mapped_texture.rgb;
}
