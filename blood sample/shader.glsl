#pragma language glsl3
#define R(p,a) p=p*cos(a)+vec2(-p.y,p.x)*sin(a);

uniform float iTime;

float sphere(vec3 p, float r){
	return dot(p,p)-r;
}

float box(vec3 p, vec3 r){
	vec3 di = abs(p)-r;
	return min( max(di.x,max(di.y,di.z)), length(max(di,0.0)) );
}

float scene(vec3 p){
	float h = sphere(mod(p,0.25)-0.125,0.011);
	float a = iTime+max(abs(cos(mod(iTime,acos(-1.0)))),0.0);
	float b1 = sphere(p-vec3(0.4*cos(iTime),0.0,-0.17),0.02);
	float b2 = sphere(p-vec3(0.0,0.17*cos(iTime+1.01),-0.17),0.02);
	R(p.xy,a*1.3);
	R(p.yz,a*0.7);
	float t = sphere(mod(p,0.25)-0.125,0.005);
	float c = max(box(p,vec3(0.25)),-h);
	float m = 1.0/(b1 + 0.021) + 1.0/(b2 + 0.021) + 1.0/(c + 0.026);
	float s = 1.0/m - 0.02;
	
	return max(max(s,-s-0.0018),-t);
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc){
	vec2 pos = (sc-0.5*love_ScreenSize.xy) / min(love_ScreenSize.x,love_ScreenSize.y);
	vec3 o = vec3(0.0,0.0,-min(love_ScreenSize.x,love_ScreenSize.y)/max(love_ScreenSize.x,love_ScreenSize.y));
	vec3 d = vec3(pos,0.0)-o;
	vec3 p = o;
	float l;
	float e = 0.001;
	vec3 c = vec3(0.0005,0.0,.002);
	float t = 0.0;
	for(int i = 0; i<256; i++){
		l=scene(p);
		if(abs(l)<e){
			vec3 lg = vec3(2.0,2.0,-13.3);
			c = vec3(t,0.0,min(t,0.04))*scene(p+0.1*lg);
			break;
		}
		t += 1.0/256.0;
		p += l*d;
	}
	return pow(vec4(c,1.0),vec4(1./2.2));
}
