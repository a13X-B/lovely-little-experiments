#pragma language glsl3
#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position ){
	int v_id = gl_VertexID%2;
	vertex_position.z = (vertex_position.y-32.*float(v_id))/4320.;
	return transform_projection * vertex_position;
}
#endif
#ifdef PIXEL
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords){
	vec4 texturecolor = Texel(tex, texture_coords);
	if (texturecolor.a < 1.) discard;
	return texturecolor * color;
}
#endif