#pragma language glsl4
#extension GL_ARB_sample_shading : enable
#ifdef VERTEX
uniform float depth_scale;
uniform float depth_offset;
vec4 position( mat4 transform_projection, vec4 vertex_position ){
	int v_id = 1-(gl_VertexID%2);
	vertex_position.z = (vertex_position.y+depth_offset*float(v_id))/depth_scale;
	return transform_projection * vertex_position;
}
#endif
#ifdef PIXEL
float hash( vec2 v ) {
	return fract( 1.0e4 * sin( 17.0*v.x + 0.1*v.y ) * ( 0.1 + abs( sin( 13.0*v.y + v.x ))));
}

uniform sampler2D lut;
uniform float mask_offset;
vec4 effect (vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	vec4 col = Texel(tex, texture_coords)*color;
	float alpha = col.a;
	alpha += .1*(hash(gl_FragCoord.xy+vec2(mask_offset, 0.)) -.5);
	if (alpha < 1./9.) discard;

	alpha -= 1./9.;
	alpha /=.7/.9;

	int mask = int(255.*Texel(lut, vec2(hash(vec2(mask_offset,gl_FragCoord.z)), alpha)).r);
	if (alpha > 1.)
		mask = 0xff;
	gl_SampleMask[0] = mask;
	return vec4(col.xyz, 1.);
}
#endif
