uniform mat4x4 transform;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position ){
	return transform * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ){
	vec4 texcolor = Texel(tex, texture_coords);
	return texcolor * color;
}
#endif