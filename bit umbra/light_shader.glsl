#pragma language glsl3

varying vec3 w_p;    // world position
varying float scale; // lightsource size
varying vec3 diff;   // diffuse color

#ifdef VERTEX
// perinstance attributes
attribute vec4 lpos;
attribute vec3 diffuse;

vec4 position( mat4 transform_projection, vec4 vertex_position ){
	// pass all the stuff to pixel shader
	scale = lpos.w;
	diff = diffuse;
	w_p = lpos.xyz;

	// transform light vertex for rendering
	return transform_projection * (vec4(vertex_position.xyz*lpos.w, vertex_position.w) + vec4(lpos.xy, 0., 0.));
}
#endif

#ifdef PIXEL
//uniform Image shadowmap;

vec4 effect(vec4 col, Image tex, vec2 uv, vec2 sc){
	
	return vec4(diff, 1.);
}
#endif