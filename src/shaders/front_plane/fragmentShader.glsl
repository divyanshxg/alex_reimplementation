#version 300 es
#define BORDER_RADIUS 0.08
#define CUTOFF_OFFSET 0.46
// this cutoff offset is the same as the position of the notch

precision mediump float;

//Uniform
uniform sampler2D uTexture;
uniform vec2 uImage;
uniform vec2 uPlane;
uniform float uProgress;

//Varying 
in vec2 vUv;
in vec3 vPos;

// Output
out vec4 fragColor;


// Includes function for blur and sdRoundedBox
#include ../utils/utils.glsl

void main() {

  // Normalized UV coordinates to [-1, 1] with aspect ratio correction
  vec2 normalized_uv = vUv;
  normalized_uv = normalized_uv * 2.0 - 1.0; // Remap [0, 1] to [-1, 1]

  float aspect = uPlane.x / uPlane.y;

  normalized_uv.x *= aspect;


  // Border Radius

  float uRadius = BORDER_RADIUS;
  vec2 p = vUv - 0.5;
  // Scale to plane dimensions
  vec2 b = uPlane * 0.5;
  // Use same radius for all corners
  vec4 r = vec4(uRadius, uRadius, uRadius, uRadius);
  
  // Calculate SDF
  float d = sdRoundedBox(p * uPlane, b, r);
  
  // Discard fragments outside the rounded box
  if (d > 0.0) {
      discard;
  }


  //Implementing Object Cover for the image
  vec2 ratio = vec2(
        min((uPlane.x / uPlane.y) / (uImage.x / uImage.y), 1.0),
        min((uPlane.y / uPlane.x) / (uImage.y / uImage.x), 1.0)
    );

vec2 uv = vec2(
        vUv.x * ratio.x + (1.0 - ratio.x) * 0.5,
        vUv.y * ratio.y + (1.0 - ratio.y) * 0.5
    );


// Scaling the texture
  float scaleFactor = mix(1.0, 2.0, uProgress); // Scales from 1x to 2x
  vec2 scaledUv = uv;
  scaledUv.y = uv.y/mix(1.0 , scaleFactor , (vUv.y + (uProgress+0.5)*0.4  ) );

  vec3 tex = texture(uTexture , scaledUv ).rgb;

  // This if statement prevents the clipping at the start when no transition is there
  if(uProgress > 0.5){
    if(vPos.y > (CUTOFF_OFFSET) ){
      discard;
    }

  }

  fragColor =  vec4(tex, 1.0); 
}


