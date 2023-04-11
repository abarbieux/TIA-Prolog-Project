shader_type canvas_item;

uniform bool from_right = false;
uniform float speed = 2.0;
uniform float frequency_y = 5.0;
uniform float frequency_x = 5.0;
uniform float amplitude_y = 50.0;
uniform float amplitude_x = 25.0;
uniform float inclination = 50.0;

void vertex() {
	float uv = UV.x;
	
	if (from_right == true)
	{
		uv = UV.x - 1.0;
	}
	
	VERTEX.y += sin((UV.x - TIME * speed) * frequency_y) * amplitude_y * uv;
	VERTEX.x += cos((UV.y - TIME * speed) * frequency_x) * amplitude_x * uv;
	VERTEX.x -= UV.y * inclination;
}