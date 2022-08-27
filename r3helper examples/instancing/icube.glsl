#ifdef VERTEX
attribute vec3 pos;

vec4 position( mat4 transform_projection, vec4 vertex_position ){
	vertex_position.xyz += pos;
	return transform_projection * vertex_position;
}
#endif
