#pragma language glsl3
uniform vec2 vel;

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ){
  return vec4(vel,0.,1.);
}