shader_type spatial;

uniform sampler2D uv_offset_texture : hint_black;
uniform vec2 uv_offset_scale = vec2(-0.2, -0.1);
uniform vec2 time_scale = vec2(0.3, 0.0);
uniform float face_distortion = 0.5;

uniform sampler2D tex: hint_albedo;

void fragment(){
	vec4 albedo_tex = texture(tex, UV);
	ALBEDO = vec3(1.0) * albedo_tex.rgb;
}

void vertex(){
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME*time_scale;

	float noise = texture(uv_offset_texture, base_uv_offset).r;
	// Convert from 0.0 <=> 1.0 to -1.0 <=> 1.0
	float texture_based_offset = noise * 2.0 - 1.0;
	// Apply dampening
	texture_based_offset *= UV.x;

	VERTEX.y += texture_based_offset;
	// Distort the face to give impression of conserving shape
	VERTEX.z += texture_based_offset * face_distortion;
	VERTEX.x += texture_based_offset * -face_distortion;
}