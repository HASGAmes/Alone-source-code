shader_type canvas_item;

uniform vec4 primary_color:source_color;
uniform vec4 secondary_color:source_color;
uniform vec4 og_primary_color:source_color;
uniform vec4 og_secondary_color:source_color;

void fragment() {
    vec4 current_pixel = texture(TEXTURE, UV);

    if (current_pixel == og_primary_color)
        COLOR = primary_color;
    else
		if (current_pixel == og_secondary_color)
	        COLOR = secondary_color;
	    else
	        COLOR = current_pixel;
}