shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 6.0) = 0.0;

void fragment() {
	vec2 texel = TEXTURE_PIXEL_SIZE * blur_strength;
	vec4 col = vec4(0.0);

	col += texture(TEXTURE, UV + vec2(-texel.x, 0.0));
	col += texture(TEXTURE, UV + vec2(texel.x, 0.0));
	col += texture(TEXTURE, UV + vec2(0.0, -texel.y));
	col += texture(TEXTURE, UV + vec2(0.0, texel.y));

	COLOR = col * 0.25;
}
