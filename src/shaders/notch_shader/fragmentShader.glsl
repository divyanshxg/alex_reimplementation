// Fragment Shader
#version 300 es
precision highp float;

out vec4 color;
in vec2 vUv;
uniform vec2 uPlane;


#include ../utils/utils.glsl

void main() {
  vec2 normalized_uv = vUv;
  normalized_uv -= 0.5;
  normalized_uv *= 2.0;

  normalized_uv.x *= uPlane.x/uPlane.y;
  

  float d = length(normalized_uv);
  d = sdRoundedBox(normalized_uv , vec2(uPlane.x/uPlane.y,1.) , vec4( 1.0 ));

  d =1.0 - step(0.0,d);

  if(d <= 0.0){
    discard;
  }
    color = vec4(0.0, 0.0, 0.0, 1.0); // Black color
}
