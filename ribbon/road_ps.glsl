#pragma language glsl3

varying vec2 uv;

vec4 effect(vec4 color, Image tex, vec2 adfadfa, vec2 sc)
{
	vec4 texturecolor = Texel(tex, uv);
	color.xy = uv;
	color.z = 0.;
	return texturecolor * color;
}
