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

  // vec3 glow_c = vec3(1.0, 0.92, 0.8);
  vec3 glow_c = vec3(1.0, 0.82, 0.7);

    // Y TEXTURE SCALE
    float scaleFactor = mix(1.0, 1.11, p3);
    vec2 scaledUv = uv;
    // scaledUv.y = uv.y/mix(1.0, scaleFactor, (uv.y + (p3+0.001)*((p3+0.001)+0.5)*0.4/(p3+0.001) ) );
    scaledUv.y = uv.y/mix(1.0, scaleFactor, (uv.y + (p3+0.001)*((p3+0.001)+0.5)*0.4/(p3+0.001) ) );



    vec4 color = texture(uTexture,scaledUv);

    float ratio = uPlane.x/uPlane.y;

    // float circ = sdCircle( normalized_uv , 0.2);
    float circ = length( ( vec2(normalized_uv.x  , normalized_uv.y)   - vec2(0.0, 0.9) )*vec2(1.0 + 0.9*0.9*pn2 , 1.) );
    
    float d = circ;
    float off = pn1*1.8;
    d = 1.0 -smoothstep(-0.05 + off , 0.0+off , d);

    // float px = 0.;
    // float py  = 1. - 2.1*pn1;
    // float pk = .3 - 0.22*pn2;
    //
    // float d = sdParabola( p_n-vec2(px,py), pk );
    //
    // float edgeWidth = 0.05; // Adjust for edge smoothness
    // float edge = 1.0 - smoothstep(-edgeWidth, edgeWidth, d);
    //
    // // Compute vertical distance from parabola's edge
    // float x = p_n.x - px; // X relative to parabola vertex
    // float parabolaY = py + pk * x * x; // Y position on parabola at p_n.x
    // float verticalDist = p_n.y - parabolaY; // Vertical distance from parabola
    //
    // // Apply exponential falloff from parabola's edge
    // float falloffWidth = 2. - 1.*pn1; // Controls the range of the falloff
    // float decayRate = 1.0 + 3.*pn1; // Controls the steepness of the exponential decay
    // float falloff = exp(-decayRate * max(0.0, verticalDist / falloffWidth));
    //
    // // Combine edge smoothing and exponential falloff
    // float result = edge * falloff;
    //
    //
    // d = 1.3*result;
    // d *= smoothstep(1.0,0.9 , pn2);
    // d *= smoothstep(0.gcc)
    float debb = d;
    // RIPPLES
    // float ratio = uPlane.x/uPlane.y;
    //
    // vec2 center = vec2(0.5*ratio, 1.0);
    //
    // vec2 dir = center - vec2(vUv.x*ratio, vUv.y);
    //
    // float t = p2;
    // float t2 = p2;
    //
    // vec2 bang_offset = vec2(0.0);
    // float bang_d = 0.0;
    // float bang_d_glow = 0.0;
    // if (t >= 1.0) {
    //     float aT = t - 1.0;
    //     vec2 uv2 = scaledUv - 0.5;
    //     uv2.x *= uPlane.x / uPlane.y; // Use uPlane for aspect ratio
    //
    //     vec2 uv_bang = vec2(uv2.x, uv2.y);
    //     vec2 uv_bang_origin = vec2(uv_bang.x , uv_bang.y - 0.5);
    //     bang_d = (aT * 0.16) / length(uv_bang_origin);
    //     bang_d_glow = (aT * 0.16) / length(uv_bang_origin);
    //     // bang_d = (aT ) / length(uv_bang_origin);
    //     // bang_d_glow = (aT ) / length(uv_bang_origin);
    //     bang_d = smoothstep(0.09, 0.05, bang_d) * smoothstep(0.04, 0.07, bang_d) * (uv.y + 0.05);
    //
    //     // bang_offset = vec2(-8.0 * bang_d * uv2.x, -4.0 * bang_d * (uv2.y - 0.4)) * 0.1;
    //     // bang_d_glow= smoothstep(0.09, 0.05, bang_d_glow) * smoothstep(0.04, 0.051, bang_d_glow) * (uv.y + 0.05);
    //     bang_d_glow= smoothstep(0.09, 0.05, bang_d_glow) * smoothstep(0.05, 0.052, bang_d_glow) ;
    //
    //
    //     float bang_d2 = ((aT - 0.085) * 0.14) / length(uv_bang_origin);
    //     bang_d2 = smoothstep(0.09, 0.05, bang_d2) * smoothstep(0.04, 0.07, bang_d2) * (uv.y + 0.05);
    //     // bang_offset += vec2(-8.0 * bang_d2 * uv2.x, -4.0 * bang_d2 * (uv2.y - 0.4)) * -0.02;
    // }
    //
    //
    //
    // float edge = 0.05; // edge damping distance
    // float edgeDamp = smoothstep(0.0, edge, vUv.x) * smoothstep(0.0, edge, vUv.y) * 
    //              smoothstep(0.0, edge, 1.0 - vUv.x) * smoothstep(0.0, edge, 1.0 - vUv.y);
    //
    //
    // bang_offset *= edgeDamp;
    //
    // vec2 uv_bang = scaledUv + bang_offset;
    // vec4 color = texture(uTexture, uv_bang);
    // // color += bang_d * 500.0 * smoothstep(1.05, 1.1, t);
    // // color.xyz += bang_d_glow * 400.0*smoothstep(1.05 , 1.1,t) * glow_c;
    // color.xyz *= bang_d_glow * 1000.0*smoothstep(1.05 , 1.1,t) * glow_c;
    //
    // if (t >= 1.0) {
    //     float Pi = 6.28318530718 * 2.0;
    //     float Directions = 60.0;
    //     float Quality = 9.0;
    //     float Radius = t2 * 0.1 * pow(uv.y, 6.0) * 0.5;
    //     Radius *= smoothstep(1.3, 0.9, t);
    //     Radius += bang_d * 0.05;
    //
    //     // Blur calculations
    //     for (float d = 0.0; d < Pi; d += Pi / Directions) {
    //         for (float i = 1.0 / Quality; i <= 1.0; i += 1.0 / Quality) {
    //             vec2 blurPos = uv_bang + vec2(cos(d), sin(d)) * Radius * i;
    //             color += texture(uTexture, blurPos);
    //         }
    //     }
    //     color /= Quality * Directions;
    // }

    fragColor= color;


    vec3 blured = blur(scaledUv ,uTexture , 0.05).xyz;

    fragColor.xyz = mix(blured , color.xyz , unblur_p);



    // Top Glow
    float scaleX = 0.3;

    vec2 glow_position = vec2(0.5*ratio*scaleX, 1.);

    float glow_l = length(vec2(scaledUv.x*ratio*scaleX , scaledUv.y ) - glow_position);

    float glow = (0.001 + 0.1*p4)/glow_l;

    // glow = pow(glow , 1. + 1.*smoothstep(0.7 , 1.0 , p4) );
    glow = pow(glow ,1.3  );


    glow = 1.0 - exp( -glow);
    
    glow *= smoothstep(1.0 , 0.85 , p4);

    fragColor.xyz += glow * glow_c;
    fragColor.a = 1.0;
  


    fragColor = vec4(vec3(debb) , 1.0);

}

