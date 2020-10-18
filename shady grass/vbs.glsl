#pragma language glsl3
//uniform float dt;

vec4 effect( vec4 color, Image tex, vec2 uv, vec2 screen_coords ){
  vec2 uvo = fwidth(uv);
  vec4 c = vec4(.0);
  for(int y = -1; y < 2; y ++)
    for(int x = -1; x < 2; x ++){
      vec2 p = vec2(x,y);
      float q = .25;
      if(x!=0) q*=.5;
      if(y!=0) q*=.5;
      c += texture(tex,uv+uvo*vec2(x,y))*q;
    }
  c*=.991;
  
  return c * color;
}