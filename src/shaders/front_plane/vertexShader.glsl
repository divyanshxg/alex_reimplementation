// Renders the vertices as it is with appropriate model view projection transformations
#version 300 es
precision mediump float;
in vec2 uv;
in vec3 position;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

out vec2 vUv;
out vec3 vPos;

void main() {

  gl_Position = projectionMatrix * modelViewMatrix* vec4(position, 1.0);

  vUv = uv;
  

  // Used to clip the plane when it goes above a threshold
  vPos = (modelViewMatrix*vec4(position,1.0)).xyz;
}
