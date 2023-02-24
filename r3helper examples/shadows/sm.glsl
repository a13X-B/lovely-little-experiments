#pragma language glsl3
varying vec4 worldpos;

#ifdef VERTEX
uniform mat4 proj;
vec4 position( mat4 transform_projection, vec4 vertex_position ){
	// save world position for shadow sampling later
	worldpos = TransformMatrix * vertex_position;
	return proj * worldpos;
}
#endif

#ifdef PIXEL
uniform mat4 shadow_view;
uniform sampler2DShadow sm;

vec4 effect( vec4 color, Image tex, vec2 uv, vec2 sc){
	// surface normal
	vec3 n = -normalize(cross(dFdx(worldpos.xyz), dFdy(worldpos.xyz)));
	// surface normal in lightview
	vec3 ln = normalize((shadow_view * vec4(n, 1.)).xyz);
	// shadow sample point
	vec3 ssp = (shadow_view * worldpos).xyz*vec3(.5);
	ssp.y*=-1.;
	ssp += vec3(.5);

	vec2 step = vec2(1.)/textureSize(sm, 0);

	float db = dot(vec3(.0,.0,-1.), ln);
	// sample shadow
	float s = texture(sm, ssp+vec3(step*-1.7*ln.xy,-ln.z*.001));
	// also shade anything not facing light to hide most of the artefacts
	s = min(s, float(db>.0));
	// color is simply world coordinate + light
	return vec4(vec3(s)*.9 + worldpos.xyz*.1, 1.);
}
#endif
