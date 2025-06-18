  uniform float time;
  uniform float p;
  uniform float p2;
  uniform vec2 resolution;

  varying vec2 vUv;   


float ripple(float p, vec2 dir){
   float d = length(dir) - 1.1 * p;
    d *= 1. - smoothstep(0.,0.25, abs(d));
    d *= smoothstep(0.,0.1, p);
    d *= 1. - smoothstep(0.9,1., p);

    return d;
}


void main() {
  vUv = uv;
  vec3 pos = position;

  float ratio = resolution.x/resolution.y;
  vec2 center = vec2(0.5*ratio, 1.1);
  vec2 dir = center - vec2(uv.x*ratio, uv.y);
  float rD = ripple(p, dir);
  dir = normalize(dir);

  // pos.xy +=  1. * dir * (rD) * .5;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);

}
