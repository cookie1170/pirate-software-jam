shader_type spatial;

uniform sampler2D gradient;

void fragment() {
	ALBEDO = texture(
		gradient, vec2(clamp(abs(sin(TIME)), 0.1, 0.9))
		).rgb;
}
