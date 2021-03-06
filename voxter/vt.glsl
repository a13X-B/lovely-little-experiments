#pragma language glsl3
uniform vec3 pos;
uniform vec2 dir;
uniform sampler2D dm;

varying vec2 uv;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position ){
  int instance = gl_VertexID/4;
  int top = gl_VertexID%2;
  int v_id = gl_VertexID%4;
  
  float col = float(instance%400);
  float row = float(instance/400);

  uv = vec2(.5) + (pos.xy + vec2(-dir.y,dir.x)*((col-200.)/400.)*(1.+row) + dir*row) / 1024.;

  float d = textureLod(dm, uv, 0.).x;

  float x = col*2. + float(v_id/2)*2.;
  float y = (pos.z-d*255.)*400./(1.+row)+300. + float(top)*250.;
  float z = -row/1024.;
  
  vertex_position = vec4(x,y,z,1.);
  return transform_projection * vertex_position;
}
#endif
 
#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ){
  color = vec4(1.);
  vec4 texcolor = textureLod(tex, uv, 0.);
  return texcolor * color;
}
#endif
