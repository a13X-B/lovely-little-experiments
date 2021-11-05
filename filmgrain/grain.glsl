uniform Image noise_texture;
uniform vec2 random_offset;

vec4 effect( vec4 color, Image tex, vec2 uv, vec2 sc ){
	vec4 c = Texel(tex, uv);
	// noise sampling coordinates, scale down for bigger grains
	// 128 in this case is the size of a noise texture
	vec2 nuv = sc/128.*.5 + random_offset; 
	vec3 n = Texel(noise_texture, nuv).xyz;
	float l = dot(c.xyz, vec3(.2, .7, .1)); //luma to attenuate the noise

	// mix has highest and lowest possible noise intensity
	// third parameter is a curve, can be linear with just l
	return vec4(c.xyz + n*mix(.08, .02, sqrt(l)), 1.);
}
