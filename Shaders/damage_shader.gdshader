shader_type canvas_item;

uniform bool active = false;
uniform vec3 color = vec3(1.0, 1.0, 1.0);
uniform float alpha_value = 1;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 new_color = vec4(color, alpha_value);
	
	if (active == false)
	{
		new_color = previous_color;
	}
	else
	{
		if (previous_color.a > 0.0)
		{
			new_color = (1.0 - alpha_value) * previous_color + alpha_value * new_color;
		}
		else
		{
			new_color.a = 0.0;
		}
	}
	
	COLOR = new_color;
}