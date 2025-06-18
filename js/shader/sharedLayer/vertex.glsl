uniform float time;
uniform float p;
uniform float p2;
uniform float p3;
uniform vec2 resolution;

varying vec2 vUv;   


float easeInOutQuad(float x) {
  return x < 0.5 ? 2. * x * x : 1. - pow(-2. * x + 2., 2.) / 2.;
}

  void main() {
  vUv = uv;
  vec3 pos = position;

  float ratio = resolution.x/resolution.y;

  // SQUEEZE
  float squeeze = easeInOutQuad(min(1., (distance(vec2(0.5*ratio, 1.52), vec2(uv.x*ratio, uv.y)) * 4. * p) + p));
  pos.x *= squeeze + 0.35 * (1.-squeeze);
  pos.y *= squeeze + 0.82 * (1.-squeeze);

  // MOVE THE MESH UP
  pos.y += .91 * p2;
  pos.y += 0.62 * (1.-p3);

  // SCALE THE MESH DOWN ON Y
  pos.y *= 1. - ((1.-p) * 0.55);

  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}


