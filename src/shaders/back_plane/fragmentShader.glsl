#version 300 es
#define BORDER_RADIUS 0.08
precision mediump float;

uniform sampler2D uTexture;
uniform vec2 uImage;
uniform vec2 uPlane;

uniform float texture_stretch_p;
uniform float wave_p;
uniform float wave_fade_p;
uniform float distortion_wave_p;

in vec2 vUv;
out vec4 fragColor;

// Includes function for blur and sdRoundedBox
#include ../utils/utils.glsl


void main() {
    // Normalized UV coordinates to [-1, 1] with aspect ratio correction
    vec2 normalized_uv = vUv * 2.0 - 1.0; // Remap [0, 1] to [-1, 1]
    vec2 p_n = normalized_uv;
    float aspect = uPlane.x / uPlane.y;
    normalized_uv.x *= aspect;

    // Border Radius
    vec2 p = vUv - 0.5;
    vec2 b = uPlane * 0.5;
    vec4 r = vec4(BORDER_RADIUS);

    // Calculate SDF
    float sdf_round_box = sdRoundedBox(p * uPlane, b, r);

    // Discard fragments outside the rounded box
    if (sdf_round_box > 0.0) {
        discard;
    }

    // Texture and normalizing its UV
    vec2 a_ratio = vec2(
        min((uPlane.x / uPlane.y) / (uImage.x / uImage.y), 1.0),
        min((uPlane.y / uPlane.x) / (uImage.y / uImage.x), 1.0)
    );

    ////////////////////////////////////////
    // This is to implement object cover behaviour but for textures , so texture doesn't stretch after placed on the plane(can be skipped in the IOS implementation)
    ////////////////////////////////////////
    // Cover UV behaviour for image
    vec2 uv = vec2(
        vUv.x * a_ratio.x + (1.0 - a_ratio.x) * 0.5,
        vUv.y * a_ratio.y + (1.0 - a_ratio.y) * 0.5
    );

    // Y Texture Scale
    float scaleFactor = mix(1.0, 1.11, texture_stretch_p);
    vec2 scaledUv = uv;
    scaledUv.y = uv.y / mix(1.0, scaleFactor, (uv.y + (texture_stretch_p + 0.001) * ((texture_stretch_p + 0.001) + 0.5) * 0.4 / (texture_stretch_p + 0.001)));


    //CIRCLE with squeezing its area so the curvature remains
    float circ = length( ( normalized_uv - vec2(0.0, 0.925)) * vec2(1.0 + 0.6 * wave_p, 1.0));

    float t1 = wave_p;
    float off = t1 * 2.7; // main ripple
    float off1 = (t1 - 0.25 - 0.15 * wave_fade_p) * 2.7; // ripple that masks out the above one to create fade 
    float ripple = 1.0 - smoothstep(-0.06 + off, 0.0 + off, circ);
    ripple *= smoothstep(-0.06 + off1, 0.0 + off1 + 1.0 * wave_fade_p, circ);


    // Rectangular band for the distortion
    float bandWidth = 0.02;      // Width of the band
    float smoothTop = 0.3;       // Smoothness of top edge
    float smoothBottom = 0.3;    // Smoothness of bottom edge
    float bandPos = distortion_wave_p * 0.95;  // Calculate band position (moving from top to bottom)

    // Create smooth band effect with different top and bottom smoothness
    float band = smoothstep(bandPos - bandWidth - smoothBottom, bandPos - bandWidth, 1.0 - vUv.y) -
                 smoothstep(bandPos, bandPos + smoothTop, 1.0 - vUv.y);


    float m = band;
    float edge = 0.15; // edge damping distance
    float edgeDamp = smoothstep(0.0, edge, vUv.y) * smoothstep(0.0, edge, 1.0 - vUv.y);
    m *= edgeDamp * smoothstep(0.0, 0.2, distortion_wave_p);

    vec2 bangOff = vec2(scaledUv.x + 0.0 * ripple, scaledUv.y - 0.06 * m);

    vec4 color = texture(uTexture, bangOff);
    vec3 blured = blur(bangOff, uTexture, 0.05).xyz;

    vec3 final_color = mix(blured, color.xyz, smoothstep(0.2, 1.0, distortion_wave_p));

    // TOP Glow 
    vec2 glow_position = vec2(0.0, 0.925);
    float glow_l = length(vec2(normalized_uv.x * 0.6, normalized_uv.y) - glow_position);
    float glow = (0.001 + 0.08 * texture_stretch_p) / glow_l;
    glow = pow(glow, 1.0);

    final_color += glow;
    final_color *= (1.0 + (1.7) * ripple * smoothstep(1.0, 0.8, wave_fade_p));

    fragColor = vec4(final_color , 1.0);
}
