#pragma language glsl3
varying float n;
varying vec3 col;
uniform vec2 size;
uniform sampler2D vb;
uniform float dt;

//iq noise function
float hash(vec2 p){  // replace this by something better
  p  = 50.0*fract( p*0.3183099 + vec2(0.71,0.113));
  return -1.0+2.0*fract( p.x*p.y*(p.x+p.y) );
}
float noise( in vec2 p ){
  vec2 i = floor( p );
  vec2 f = fract( p );
	vec2 u = f*f*(3.0-2.0*f);
  return mix( mix( hash( i + vec2(0.0,0.0) ), 
                   hash( i + vec2(1.0,0.0) ), u.x),
              mix( hash( i + vec2(0.0,1.0) ), 
                   hash( i + vec2(1.0,1.0) ), u.x), u.y);
}
vec3 hsv(float h,float s,float v) {
	return mix(vec3(1.),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v;
}
#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position ){
  n = noise(vec2(gl_InstanceID*0.23156464)); //there is definitely a better way to get random number, this one is just a drop in solution
  float h = 0.857*n-7.295;
  float d = dt/17.;
  ivec2 id = ivec2(gl_VertexID%2, gl_VertexID/2);
  vec2 p[8];
  float l[7];
  for(int i=0; i<8; i++) p[i] = vec2(mod(1.7*gl_InstanceID+n, size.x) + abs(n)*n*(i*2), h*i + size.y*0.69 - 1.); //initial grass blade position
  for(int i=0; i<7; i++) l[i] = length(p[i+1]-p[i]);
  for(int j=0; j<5; j++){ //five iterations of our verlet-like solver
    for(int i=1; i<8; i++){ //root stays at the same place hence starting with offset of 1
      vec2 vel = textureLod(vb, p[i]/size, 0).xy;
      p[i] += vel*d*i*i*(.5+n*n);
    }
    for(int i=6; i>0; i--) p[i] = p[i+1] + normalize(p[i]-p[i+1])*l[i];
    for(int i=1; i<8; i++) p[i] = p[i-1] + normalize(p[i]-p[i-1])*l[i-1];
  }
  vec2 offset = id.y!=0 ? normalize(p[id.y-1]-p[id.y]) : vec2(.0, 1.);
  offset = vec2(-offset.y, offset.x);
  col = vec3(.0,.5-(abs(n))*0.2,.0);
  if(id.y == 7 && mod(1.-n*n, .37) < 0.018){
    offset *= 13.+(gl_InstanceID%3+2)*(1.-n);
    col = hsv(gl_InstanceID*n,1.-abs(n),1.);
  }

  p[id.y] += offset*(1.-(id.x)*2.)/(sqrt(float(id.y))+1.);
  vertex_position.xy = p[id.y];
  return transform_projection * vertex_position;
}
#endif
 
#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ){
  color = vec4(col,1.);
  vec4 texcolor = Texel(tex, texture_coords);
  return texcolor * color;
}
#endif