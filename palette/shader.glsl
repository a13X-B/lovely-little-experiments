uniform sampler2D pal;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords){
    vec4 c = Texel(tex, texture_coords);
    if(c.x == c.y && c.x == c.z){
      float id = c.x * 255. / 32.;
      c = Texel(pal, vec2(id, 0.));
    }
    return c * color;
}