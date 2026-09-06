shader_type canvas_item;

uniform sampler2D noise_img;

void fragment():
	COLOR = texture(noise_img, UV):