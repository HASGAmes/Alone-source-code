shader_type canvas_item;

uniform vec4 find_color : source_color;
uniform usampler2D index_as_r;
uniform vec4 target_color: source_color;
void fragment() {
	// Place fragment code here.
	vec2 uv = UV;
	vec4 pixel_color = texture(TEXTURE,UV);
	if (length(pixel_color.rgb - find_color.rgb) < 0.01){
		COLOR = find_color;
	}
}
