#version 300 es
#define BORDER_RADIUS 0.08
precision mediump float;

uniform sampler2D uTexture;
uniform vec2 uImage;
uniform vec2 uPlane;
uniform float unblur_p;
uniform float uGlowWave; 
uniform float uGlowRadius;
uniform float uRippleWave;
uniform float uTextureStretch;
////////////////////
uniform float p2;
uniform float p3;
uniform float p4;

uniform float pn1;
uniform float pn2;
uniform float pn3;
uniform float pn4;
/////////////////////

// to be removed (since they are from GUI) after tweaking and place these values at appropriate places
uniform float uDistortion; // 0.09 (value from gui)
uniform float uBottomRingSmoothness; // 0.02 (value from gui)
uniform float uTopRingSmoothness; // 0.1 (value from gui)
uniform float uShockwaveSpeed;

in vec2 vUv;
out vec4 fragColor;


// Includes function for blur and sdRoundedBox
#include ../utils/utils.glsl



float sdParabola( in vec2 pos, in float k )
{
    pos.x = abs(pos.x);
    
    float ik = 1.0/k;
    float p = ik*(pos.y - 0.5*ik)/3.0;
    float q = 0.25*ik*ik*pos.x;
    
    float h = q*q - p*p*p;
    float r = sqrt(abs(h));

    float x = (h>0.0) ? 
        // 1 root
        pow(q+r,1.0/3.0) + pow(abs(q-r),1.0/3.0)*sign(p) :
        // 3 roots
        2.0*cos(atan(r,q)/3.0)*sqrt(p);
    
    float d = length(pos-vec2(x,k*x*x));
    
    return (pos.x<x)? -d : d;
}


float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

void main() {

  // Normalized UV coordinates to [-1, 1] with aspect ratio correction
  vec2 normalized_uv = vUv;
  normalized_uv = normalized_uv * 2.0 - 1.0; // Remap [0, 1] to [-1, 1]
  
  vec2 p_n = normalized_uv;

  float aspect = uPlane.x / uPlane.y;

  normalized_uv.x *= aspect;


  // Border Radius
  float uRadius = BORDER_RADIUS;
  vec2 p = vUv - 0.5;
  vec2 b = uPlane * 0.5;
  vec4 r = vec4(uRadius, uRadius, uRadius, uRadius);
  
  // Calculate SDF
  float sdf_round_box = sdRoundedBox(p * uPlane, b, r);
  
  // Discard fragments outside the rounded box
  if (sdf_round_box > 0.0) {
      discard;
  }


  //Texture and normalizing its UV
  vec2 a_ratio = vec2(
        min((uPlane.x / uPlane.y) / (uImage.x / uImage.y), 1.0),
        min((uPlane.y / uPlane.x) / (uImage.y / uImage.x), 1.0)
    );

  // Cover UV behaviour for image
vec2 uv = vec2(
        vUv.x * a_ratio.x + (1.0 - a_ratio.x) * 0.5,
        vUv.y * a_ratio.y + (1.0 - a_ratio.y) * 0.5
    );

  vec3 glow_c = vec3(1.0, 0.82, 0.7);

    // Y TEXTURE SCALE
    float scaleFactor = mix(1.0, 1.11, p3);
    vec2 scaledUv = uv;
    scaledUv.y = uv.y/mix(1.0, scaleFactor, (uv.y + (p3+0.001)*((p3+0.001)+0.5)*0.4/(p3+0.001) ) );



    vec4 color = texture(uTexture,scaledUv);

    float ratio = uPlane.x/uPlane.y;

    // float circ = sdCircle( normalized_uv , 0.2);
float circ = length( ( vec2(normalized_uv.x, normalized_uv.y) * vec2(1.) - vec2(0.0, 0.925) ) * vec2(1.0 + 0.6 * pn2, 1.0) );

float t1 = pn1;
float off = t1 * 1.9;
float off1 = (t1  - 0.1 - 0.4*pn3)* 2.;
float ripple = 1.0 - smoothstep(-0.06 + off , 0.0 + off+ 0.05, circ);
ripple *= smoothstep(-0.06 + off1   , 0.0 + off1 + 1.*pn3 , circ);
// ripple *= smoothstep(1.0 ,0.8 , pn2);





float circleBottomY = -(0.9 - circ) ; // since origin is at top (0.9 is the ripple center Y)

// Create upward falloff: starts from `circleBottomY` and fades upward
float falloffHeight = 2.; // adjust this
float verticalFalloff = smoothstep(circleBottomY - falloffHeight, circleBottomY, normalized_uv.y);

// Apply falloff
float d = ripple;
    float debb = d;

    fragColor= color;


    vec3 blured = blur(scaledUv ,uTexture , 0.05).xyz;

    fragColor.xyz = mix(blured , color.xyz , unblur_p);



    // Top Glow
    float scaleX = 0.3;

    vec2 glow_position = vec2(0., 0.925);

    float glow_l = length(vec2(normalized_uv.x*0.6 , normalized_uv.y ) - glow_position);

    float glow = (0.001 + 0.08*p4)/glow_l;

    // glow = pow(glow , 1. + 1.*smoothstep(0.7 , 1.0 , p4) );
    glow = pow(glow ,0.9);


    // glow = 1.0 - exp( -glow);
    
    glow *= smoothstep(1.0 , 0.8 , p4);
    glow += ripple*smoothstep(1.0 , 0.0, pn4);

    fragColor.xyz += glow * glow_c;



    fragColor.a = 1.0;
  


    // fragColor = vec4(vec3(debb) , 1.0);

}

