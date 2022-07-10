#pragma language glsl3

varying vec3 w_p;    // world position
varying float scale; // lightsource size
varying vec3 diff;   // diffuse color
flat varying int light_id;

#ifdef VERTEX
// perinstance attributes
attribute vec4 lpos;
attribute vec3 diffuse;

vec4 position( mat4 transform_projection, vec4 vertex_position ){
	// pass all the stuff to pixel shader
	scale = lpos.w;
	diff = diffuse;
	w_p = lpos.xyz;
	light_id = gl_InstanceID;

	// transform light vertex for rendering
	return transform_projection * (vec4(vertex_position.xyz*lpos.w, vertex_position.w) + vec4(lpos.xy, 0., 0.));
}
#endif

#ifdef PIXEL
uniform ArrayImage shadowmap;

vec4 effect(vec4 col, Image tex, vec2 uv, vec2 sc){
	vec2 shadow = Texel(shadowmap, vec3(sc/love_ScreenSize.xy,float(light_id/32))).xy;
	if((int(shadow[(light_id/16)&1]*65535.) & (1<<(light_id%16))) != 0) discard;
	vec3 c = diff * (1.-clamp(dot(sc - w_p.xy, sc - w_p.xy)/(scale*scale),0.,1.));
	return vec4(c, 1.);
}
#endif