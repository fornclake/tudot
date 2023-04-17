shader_type canvas_item;

uniform vec4 border_color : source_color;
uniform float border_size = 10.0;

uniform vec4 rect0;
uniform vec4 rect1;
uniform vec4 rect2;
uniform vec4 rect3;

bool encloses(vec4 rect, vec2 pixel) {
	if (pixel.x > rect.r && pixel.x < rect.r+rect.b) {
		if (pixel.y > rect.g && pixel.y < rect.g+rect.a) {
			return true;
		}
	}
	return false;
}

void fragment() {
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 current_pixel = SCREEN_UV * resolution;
	vec4 color = COLOR;
	vec4 border_rect = vec4(-border_size, -border_size, border_size*2.0, border_size*2.0);
	
	// bold border on primary rectangle
	if (encloses(rect0 + border_rect, current_pixel) ||
		encloses(rect1 + border_rect, current_pixel) ||
		encloses(rect2 + border_rect, current_pixel) ||
		encloses(rect3 + border_rect, current_pixel)) {
		color = border_color;
	}
	
	// remove dim effect from highlit rectangles
	if (encloses(rect0, current_pixel) ||
		encloses(rect1, current_pixel) ||
		encloses(rect2, current_pixel) ||
		encloses(rect3, current_pixel)) {
		color.a = 0.0;
	}
	
	COLOR = color;
}