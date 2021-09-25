varying vec2 ndc_p;  // normalized display coordinate light position
varying vec3 w_p;    // world position
varying float scale; // lightsource size
varying vec3 diff;   // diffuse color
varying vec3 dir;    // light direction
varying float angle; // cosine of light cone angle

#ifdef VERTEX
// perinstance attributes
attribute vec4 lpos;
attribute vec4 ldir;
attribute vec3 diffuse;

vec4 position( mat4 transform_projection, vec4 vertex_position ){
	vec2 lp = (transform_projection * vec4(lpos.xyz, 1.)).xy; // light position to screenspace
	ndc_p = vec2(lp.x, -lp.y); // screenspace to ndc
	
	// pass all the other stuff to pixel shader
	scale = lpos.w;
	diff = diffuse;
	dir = normalize(ldir.xyz);
	angle = ldir.w;
	w_p = lpos.xyz;

	// transform light vertex for rendering
	return transform_projection * (vec4(vertex_position.xyz*lpos.w, vertex_position.w) + vec4(lpos.xy, 0., 0.));
}
#endif

#ifdef PIXEL
uniform Image cb;
uniform Image nb;

vec4 effect(vec4 col, Image tex, vec2 uv, vec2 sc){
	sc /= love_ScreenSize.xy;
	vec2 ndc = (sc - vec2(.5)) * 2.; // ndc of a current pixel

	// color and normal of a to be lit pixel
	vec3 c = Texel(cb, sc).xyz;
	vec3 n = normalize(Texel(nb, sc).xyz - vec3(.5));
	n.y = -n.y;

	vec3 tl = vec3(normalize(ndc_p-ndc) * col.x, w_p.z / scale); //vector towards the light
	float ld = length(tl);
	vec3 l = normalize(tl);

	// discard if pixel is beyond the bounding sphere or cone
	if((length(tl)/scale > 1.) || (dot(-l, dir) < angle)) discard;

	// compute lambertian term, distance dissipation, and multiply by diffuse
	c = c * dot(n,l) * max(1.-ld*ld, 0.) * diff;
	return vec4(c, 1.);
}
#endif