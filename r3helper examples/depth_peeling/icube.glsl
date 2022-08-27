#ifdef VERTEX
attribute vec3 pos;

vec4 position( mat4 transform_projection, vec4 vertex_position ){
	vertex_position.xyz += pos;
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
uniform sampler2D d;

vec4 effect( vec4 color, Image tex, vec2 uv, vec2 sc){
	float depth = Texel(d, sc/love_ScreenSize.xy).x;
	if(depth >= gl_FragCoord.z) discard;
	vec4 texcolor = Texel(tex, uv);
	return texcolor * color;
}
#endif

