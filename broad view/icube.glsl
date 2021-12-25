#ifdef VERTEX
attribute vec3 pos;

vec4 position( mat4 transform_projection, vec4 vertex_position ){
	vertex_position.xyz += pos;
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ){
	vec4 texcolor = Texel(tex, texture_coords);
	return texcolor * vec4(vec3(1.)-color.xyz, color.w);
}
#endif

