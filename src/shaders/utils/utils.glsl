vec3 draw(sampler2D image, vec2 uv) {
  return texture(image,vec2(uv.x, uv.y)).rgb;   
}

float rand(vec2 co){
  return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

/*
  inspired by https://www.shadertoy.com/view/4tSyzy
  @anastadunbar
*/
vec3 blur(vec2 uv, sampler2D image, float blurAmount){
  vec3 blurredImage = vec3(0.);
  float d = 1.0;
  #define repeats 40.
  for (float i = 0.; i < repeats; i++) { 
    vec2 q = vec2(cos(degrees((i / repeats) * 360.)), sin(degrees((i / repeats) * 360.))) * (rand(vec2(i, uv.x + uv.y)) + blurAmount); 
    vec2 uv2 = uv + (q * blurAmount * d);
    blurredImage += draw(image, uv2) / 2.;
    q = vec2(cos(degrees((i / repeats) * 360.)), sin(degrees((i / repeats) * 360.))) * (rand(vec2(i + 2., uv.x + uv.y + 24.)) + blurAmount); 
    uv2 = uv + (q * blurAmount * d);
    blurredImage += draw(image, uv2) / 2.;
  }
  return blurredImage / repeats;
}

 // Signed Distance Function for Rounded Box
float sdRoundedBox(in vec2 p, in vec2 b, in vec4 r) {
    r.xy = (p.x > 0.0) ? r.xy : r.zw;
    r.x = (p.y > 0.0) ? r.x : r.y;
    vec2 q = abs(p) - b + r.x;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r.x;
}

