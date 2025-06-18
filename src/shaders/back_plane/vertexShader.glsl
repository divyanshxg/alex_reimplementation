// Renders the vertices as it is with appropriate model view projection transformations
#version 300 es
precision mediump float;
in vec2 uv;
in vec3 position;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

out vec2 vUv;


void main() {

    vUv = uv; // 0 to 1

    gl_Position = projectionMatrix * modelViewMatrix* vec4(position, 1.0);
}
