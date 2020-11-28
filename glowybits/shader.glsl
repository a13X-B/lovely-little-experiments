uniform float scale;

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ){
	float c = Texel(tex, texture_coords).r;
	vec2 sc = floor(screen_coords*scale);

	c = (mod(sc.x+sc.y, 2.) + float(c > .45)) * float(c > 0.);
	return vec4(clamp(c, 0., 1.), 0., 0., 1.) * color;
}
