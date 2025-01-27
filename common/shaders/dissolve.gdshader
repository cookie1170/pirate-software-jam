shader_type spatial;

uniform sampler2D dissolve_noise_texture;
uniform float dissolve_amount : hint_range(0.0, 1.0, 0.05);
uniform float dissolve_color_range : hint_range(0.0, 1.0, 0.05);
uniform vec3 dissolve_color : source_color;

void fragment() {
	if (texture(dissolve_noise_texture, UV).r < dissolve_amount){
		ALPHA = 0.0;
	}
	if (texture(dissolve_noise_texture, UV).r < dissolve_amount + dissolve_color_range
		&& dissolve_amount > 0.0) {
			ALBEDO = dissolve_color.rgb;
		}
}
