varying vec4 world_pos;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position ){
	world_pos = TransformMatrix * vertex_position;
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
uniform ArrayImage MainTex;
void effect(){
	vec4 n = Texel(MainTex, vec3(VaryingTexCoord.xy, 1.));
	vec4 c = Texel(MainTex, vec3(VaryingTexCoord.xy, 0.));
	if(c.a == 0.) discard;
	love_Canvases[0] = c;
	love_Canvases[1] = n;
}
#endif