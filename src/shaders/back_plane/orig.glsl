#version 300 es
#define BORDER_RADIUS 0.1
precision mediump float;

uniform sampler2D uTexture;
uniform vec2 uImage;
uniform vec2 uPlane;
uniform float unblur_p;
uniform float uGlowWave; 
uniform float uGlowRadius;
uniform float uRippleWave;
uniform float uTextureStretch;

// to be removed (since they are from GUI) after tweaking and place these values at appropriate places
uniform float uDistortion; // 0.09 (value from gui)
uniform float uBottomRingSmoothness; // 0.02 (value from gui)
uniform float uTopRingSmoothness; // 0.1 (value from gui)
uniform float uShockwaveSpeed;

in vec2 vUv;
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
  vec2 b = uPlane * 0.5;
  vec4 r = vec4(uRadius, uRadius, uRadius, uRadius);
  
  // Calculate SDF
  float sdf_round_box = sdRoundedBox(p * uPlane, b, r);
  
  // Discard fragments outside the rounded box
  if (sdf_round_box > 0.0) {
      discard;
  }


  //Texture and normalizing its UV
  vec2 ratio = vec2(
        min((uPlane.x / uPlane.y) / (uImage.x / uImage.y), 1.0),
        min((uPlane.y / uPlane.x) / (uImage.y / uImage.x), 1.0)
    );

  // Cover UV behaviour for image
vec2 uv = vec2(
        vUv.x * ratio.x + (1.0 - ratio.x) * 0.5,
        vUv.y * ratio.y + (1.0 - ratio.y) * 0.5
    );



// Two Major Effects - Glow Accumulation and Shockwave

// Effect 1 GLOW Accumulation
// The Glow accumulation is acheived by creating a ring but its ring merges with the shcokwave mid transition and at the same time intensity of glow wave is reduced


    float t1 = uGlowWave*3.  - 1.5;
    // 0.95 is the y position for 
    float d = 1.0 - length(normalized_uv - vec2(0.0, 0.95));

  float glow_size = smoothstep(0.0, 0.5, uGlowWave) * (1.0 - smoothstep(0.7, 1.0, uGlowWave));

  // Two waves to form a ring 
    float d1 = smoothstep(-t1 -0.15 - 0.3*uGlowRadius , -t1, d);
    float d2 = smoothstep(-t1 , -t1+0.15 + 0.3*uGlowRadius , d);
    float d_glow = d1-d2;



// Effect 2 Shockwave/Ripple

    // prevent the edge of texture from distortion since it creates wierd effects
    float edge = 0.1; // edge damping distance
    float edgeDamp = smoothstep(0.0, edge, vUv.x) * smoothstep(0.0, edge, vUv.y) * 
                 smoothstep(0.0, edge, 1.0 - vUv.x) * smoothstep(0.0, edge, 1.0 - vUv.y);

    float effectiveRippleSpeed = uRippleWave*uShockwaveSpeed;
    // timing varaibles t2 , t3
    float t2 = effectiveRippleSpeed*0.46;
    float t3 = effectiveRippleSpeed*0.26;

    vec2 viewSize = uPlane;
    vec2 position = vUv * viewSize;

    vec2 position_yflip = vec2(position.x ,  position.y);

    // origin of the shockwave/ripple
    float uv_y_dynamic_island_offset = 0.46;

    vec2 uv_d  =  position_yflip/viewSize;

    // texture stretching when the front plane moves up
    vec2 stretch_uv = vec2(uv.x, uv.y/(1.+uTextureStretch/10.) );
    vec4 texture_color = texture(uTexture , stretch_uv);


    // Initialize variables for the bang effect
    vec2 bang_offset = vec2(0.0);
    float bang_d = 0.0;

    if (t2 >= 0.0) {

        float aT = t3 - 0.0;
        vec2 uv2 = uv_d;
        uv2 -= 0.5;
        uv2.x *= viewSize.x / viewSize.y; 

        // offset to make ring will move downwards as its radius increases to retain curvatuyre also t3 should be reduces appropriately so the ring does not goes all the way
        float yOff = smoothstep(0.3,0.6,effectiveRippleSpeed )*effectiveRippleSpeed*0.4;

        vec2 uv_bang = vec2(uv2.x, uv2.y); 

        vec2 uv_bang_origin = vec2(uv_bang.x, uv_bang.y - uv_y_dynamic_island_offset  + yOff); 

        bang_d = (aT * 0.16) / length(uv_bang_origin); 


        // smoothness of ring edges
        // float a = smoothstep(0.6,1.0,effectiveRippleSpeed )*0.02; // bottom edge smoothness
        // float b = smoothstep(0.5,1.0,effectiveRippleSpeed )*0.1; // top edge smoothness
        float a = smoothstep(0.6,1.0,effectiveRippleSpeed )*uTopRingSmoothness; // top edge smoothness
        float b = smoothstep(0.5,1.0,effectiveRippleSpeed )*uBottomRingSmoothness; // bottom edge smoothness

        // ring
        float factor = 0.44; // factor to vary the 
        bang_d = smoothstep(0.07+a/2., 0.05-a/2., bang_d) * smoothstep(0.04-b/2., 0.07 +b/2., bang_d)*factor; 

        // offset/distortion in texture uv caused due to shockwave
        float off = 0.5; // offset to vary the distortion radius
        bang_offset += vec2(-8.0*off * bang_d * uv2.x, -4.0*off * bang_d * (uv2.y - 0.4)) * uDistortion;

    }


    vec2 effective_bang_offset = bang_offset;
    // smoothing out the distortionn
    effective_bang_offset *= 1.0 - smoothstep(0.84, 1.,uRippleWave);
    // damping out distortion on the edges
    effective_bang_offset *= edgeDamp;

    vec2 uv_blast = stretch_uv + effective_bang_offset*2. ;
    texture_color = texture(uTexture, uv_blast); // Sample texture at displaced coords

    // chrome offset along with smoothing out at the end of wave
    vec2 chrome_offset = vec2(0.0 , effective_bang_offset)*smoothstep(0.5,0.7,effectiveRippleSpeed );

  // smoothing out the chromatic aberration at the end of shockwave
  float aberration_factor = 1.0 - smoothstep(0.75, 0.88, uRippleWave);


  float r_aberation = texture(uTexture, uv_blast).r;
  float g_aberation = texture(uTexture, uv_blast - aberration_factor * chrome_offset).g;
  float b_aberation = texture(uTexture, uv_blast - aberration_factor * chrome_offset).b;

    texture_color.xyz = vec3(r_aberation , g_aberation , b_aberation);

    // masking the bang wave to smooth out the glow caused by shockwave
    bang_d *= 1.0 - smoothstep(0.85, 1. ,uRippleWave);

    // Apply blur effect where bang is active
    if (bang_d > 0.0) {
        float Pi = 6.28318530718 * 2.0; // Define 2*PI for circular sampling
        float Directions = 20.0;        // Number of directions for blur sampling
        float Quality = 6.0;            // Number of samples per direction
        float Radius = bang_d * 0.08;   // Blur radius scales with bang intensity

        vec4 blurColor = vec4(0.0);     // Initialize blur color accumulator
        float totalSamples = 0.0;       // Track number of samples for averaging

        // Loop over directions and distances to sample blur
        for(float d = 0.0; d < Pi; d += Pi / Directions) {
            for(float i = 1.0 / Quality; i <= 1.0; i += 1.0 / Quality) {
                vec2 blurPos = uv_blast + vec2(cos(d), sin(d)) * Radius * i; // Calculate blur sample position
                blurColor += texture(uTexture, blurPos); // Add sample to blur color
                totalSamples += 1.0; // Increment sample count
            }
        }
        blurColor /= totalSamples; // Average the blur samples

        // Blend original displaced color with blurred color based on bang intensity
        texture_color = mix(texture_color, blurColor, bang_d * 2.0);
    }

    // Enhance colors with a flash effect based on bang intensity and time
    texture_color = texture_color * (1.0 + bang_d * 8. * smoothstep(.05, .1, t2));

    // texture that included distortion by shcokwave and the glow caused by it
    vec3 tex = texture_color.xyz;
    // blurred texture
    vec3 blured = blur(stretch_uv ,uTexture , 0.07);
    
    // switching between normal textuer and blurred texture
    vec3 final_texture = mix(tex, blured , 1.0 - unblur_p);
    
    // Masking the glow ring (for glow accumulation)
    d_glow *= smoothstep(0.1, 0.6, uGlowRadius);

    // Glow Intensity Factor 
    float uGlowIntensity = 0.8;


    // giving the glow a slight tint of yellow and setting a minimum value of it
    // the glow here is the accumulation one because the glow of shockwave has already been adjusted in the final_texture
    vec3 final_color = final_texture + vec3(1.0,1.0,0.85 )*( (( uGlowIntensity*max(0.45,effectiveRippleSpeed) )*d_glow ) );

    fragColor = vec4( final_color , 1.0);
}

