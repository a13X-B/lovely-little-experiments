#pragma language glsl3

#ifdef VERTEX
// perinstance attributes
attribute vec4 lpos;

vec4 position( mat4 transform_projection, vec4 vertex_position ){
	if (vertex_position.z > 0.) {
		vertex_position.xy += normalize(vertex_position.xy-lpos.xy)*99999999999.;
		vertex_position.z = 0.;
	}
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 col, Image tex, vec2 uv, vec2 sc){
	return vec4(1., 0., 0., 1.);
}
#endif
