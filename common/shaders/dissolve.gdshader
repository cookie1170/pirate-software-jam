shader_type spatial;

uniform sampler2D dissolve_noise_texture;
uniform float dissolve_amount : hint_range(0.0, 1.0, 0.05);

void fragment() {
	if (texture(dissolve_noise_texture, UV).r < dissolve_amount){
		ALPHA = 0.0;
	}
}
