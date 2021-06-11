#pragma language glsl3

attribute vec2 normal;
attribute float curvature;
varying vec2 uv;

vec4 position(mat4 transform_projection, vec4 vertex_position){
	float upper = float(gl_VertexID%2);
	vec2 offset = mix(-normal, normal, upper);
	uv = vec2(VertexTexCoord.x, upper);

	vertex_position += vec4(20.*offset - 3.*curvature*normal, 0., 0.);
	return transform_projection * vertex_position;
}
