#pragma language glsl3

flat varying int light_id;

#ifdef VERTEX
// perinstance attributes
attribute vec4 lpos;

vec4 position( mat4 transform_projection, vec4 vertex_position ){
	light_id = gl_InstanceID;
	if (vertex_position.z > 0.) {
		vertex_position.xy += normalize(vertex_position.xy-lpos.xy)*99999999999.;
	}
		vertex_position.z = float(gl_InstanceID)/100.;
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
void effect(){
	vec2 shadow_id[2];
	shadow_id[0] = vec2(0.);
	shadow_id[1] = vec2(0.);
	int light_bit = light_id;
	shadow_id[light_id/32][(light_id/16)&1] = float(1<<(light_id%16)) / 65535.;

	love_Canvases[0] = vec4(shadow_id[0], 0., 1.);
	love_Canvases[1] = vec4(shadow_id[1], 0., 1.);
}
#endif
