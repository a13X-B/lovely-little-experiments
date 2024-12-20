#pragma language glsl4
#extension GL_ARB_sample_shading : enable
#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position ){
	int v_id = 1-((gl_VertexID%4)/2); // make things overlap procedurally
	vertex_position.z = float(v_id);
	return transform_projection * vertex_position;
}
#endif
#ifdef PIXEL
float hash( vec2 v ) {
	return fract( 1.0e4 * sin( 17.0*v.x + 0.1*v.y ) * ( 0.1 + abs( sin( 13.0*v.y + v.x ))));
}

uniform sampler2D lut;
uniform float alpha_offset;
vec4 effect (vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	vec4 col = Texel(tex, texture_coords)*color;
	float alpha = col.a;
	alpha += .1*(hash(gl_FragCoord.xy)-.5); // this could be better for lower alpha values

	// here we add that random alpha offset to get a different bitmask each time
	vec2 mask_sample=vec2(hash(vec2(gl_FragCoord.z, alpha_offset)),alpha);
	int mask = int(255.*Texel(lut, mask_sample).r);

	gl_SampleMask[0] = mask;
	return vec4(col.xyz, 1.);
}
#endif
