#pragma language glsl3

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ){
	float c = Texel(tex, texture_coords).r;
	ivec2 sc = ivec2(screen_coords*0.2);

	c = float( (((sc.x^sc.y) & 1) | int(c > .45)) & int(c > 0.));
	return vec4(c, 0., 0., 1.) * color;
}
