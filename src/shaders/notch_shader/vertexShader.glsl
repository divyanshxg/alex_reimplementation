// Renders the vertices as it is with appropriate model view projection transformations
// Vertex Shader
#version 300 es
precision highp float;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

out vec2 vUv;
in vec3 position;
in vec2 uv;

void main() {
    vUv = uv;
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
}

