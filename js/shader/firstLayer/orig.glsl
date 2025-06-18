// ============================================================================
// UNIFORMS AND INPUTS
// ============================================================================

// Main texture to be processed (the image/video we're applying effects to)
uniform sampler2D tex;

// Screen/viewport resolution in pixels (width, height)
uniform vec2 resolution;

// Size of a single texel (1/textureWidth, 1/textureHeight) - used for proper blur scaling
uniform vec2 uTexelSize;

// Animation parameters controlled from outside:
uniform float p2;    // Controls ripple animation progress (0.0 to 1.0)
uniform float p3;    // Controls Y-axis texture scaling intensity
uniform float p;     // Controls overall effect intensity and ring animation

// UV coordinates passed from vertex shader (0,0 to 1,1)
varying vec2 vUv;

// ============================================================================
// BLUR CONSTANTS AND SETUP
// ============================================================================

// Blur sampling configuration
const int samples = 80;      // Total samples for blur effect (higher = better quality, slower)
const int LOD = 2;           // Level of Detail for texture sampling (mipmapping level)
const int sLOD = 1 << LOD;   // Bit shift: 1 << 2 = 4, used for sampling optimization

// Gaussian blur standard deviation - controls blur spread
// Larger sigma = more blur, smaller sigma = sharper
const float sigma = float(samples) * 0.25;

// ============================================================================
// GAUSSIAN BLUR FUNCTIONS
// ============================================================================

/**
 * Gaussian weight function - calculates how much each sample contributes to the blur
 * @param i: offset from center sample
 * @return: weight value (higher for samples closer to center)
 */
float gaussian(vec2 i) {
    i /= sigma;  // Normalize by standard deviation
    // Gaussian formula: e^(-0.5 * |x|²) / (2π * σ²)
    // 6.2831853 = 2π
    return exp(-0.5 * dot(i, i)) / (6.2831853 * sigma * sigma);
}

/**
 * Gaussian blur implementation
 * @param tex: texture to blur
 * @param uv: center UV coordinate
 * @param scale: blur kernel size scaling
 * @return: blurred color
 */
vec4 blur(sampler2D tex, vec2 uv, vec2 scale) {
    vec4 color = vec4(0.0);          // Accumulated color
    int s = samples / sLOD;          // Reduced sample count for performance (80/4 = 20)
    
    // Sample in a grid pattern around the center point
    for (int i = 0; i < s * s; i++) {  // 20x20 = 400 samples total
        // Convert linear index to 2D grid coordinates
        vec2 d = vec2(i % s, i / s) * float(sLOD) - float(samples) * 0.5;
        
        // Calculate offset UV coordinate for this sample
        vec2 offsetUV = uv + scale * d;
        
        // Sample texture with LOD and weight by gaussian function
        color += gaussian(d) * textureLod(tex, offsetUV, float(LOD));
    }
    
    // Normalize by alpha to handle transparency correctly
    return color / color.a;
}

// ============================================================================
// SHAPE FUNCTIONS
// ============================================================================

/**
 * Signed Distance Function for rounded rectangle
 * @param p: point to test
 * @param b: half-size of rectangle (width/2, height/2)
 * @param r: corner radius
 * @return: distance (negative = inside, positive = outside)
 */
float roundedBox(vec2 p, vec2 b, float r) {
    // Distance to rectangle edges, then subtract radius for rounded corners
    return length(max(abs(p) - b + r, 0.0)) - r;
}

// ============================================================================
// RIPPLE EFFECT FUNCTIONS
// ============================================================================

/**
 * Creates expanding ripple effect with smooth falloff
 * @param p: animation progress (0.0 to 1.0)
 * @param dir: direction vector from ripple center to current pixel
 * @return: ripple intensity at this pixel
 */
float ripple(float p, vec2 dir) {
    // Calculate distance from ripple wavefront
    // As p increases, the ripple radius grows (1.0 * p)
    float d = length(dir) - 1.0 * p;
    
    // Create sharp ripple edge with small glow
    // smoothstep(0, 0.051, abs(d)) creates a band 0.051 units wide around d=0
    // 1.0 - smoothstep(...) inverts it so we get maximum intensity at d=0
    d *= 1.0 - smoothstep(0.0, 0.051, abs(d));
    
    // Fade in ripple at the beginning (prevents sudden appearance)
    // When p < 0.1, ripple is faded out
    d *= smoothstep(0.0, 0.1, p);
    
    // Fade out ripple at the end (prevents abrupt disappearance)
    // When p > 0.9, ripple starts fading out, completely gone at p = 1.0
    d *= 1.0 - smoothstep(0.9, 1.0, p);
    
    return d;
}

// ============================================================================
// MAIN SHADER FUNCTION
// ============================================================================

void main() {
    // Start with original UV coordinates
    vec2 uv = vUv;
    
    // ========================================================================
    // Y-AXIS TEXTURE SCALING (Creates perspective/depth effect)
    // ========================================================================
    
    // Calculate how much to scale the Y-axis (1.0 to 1.25 based on p3)
    float scaleFactor = mix(1.0, 1.25, p3);
    
    vec2 scaledUv = uv;
    
    // Complex Y-scaling formula that creates non-uniform scaling
    // - Scaling is stronger towards the bottom of the screen
    // - Creates a perspective effect like looking at a surface at an angle
    // - The formula: (uv.y + (p3+0.001)*((p3+0.001)+0.5)*0.4/(p3+0.001))
    //   creates a curve that varies the scaling across the Y-axis
    scaledUv.y = uv.y / mix(1.0, scaleFactor, 
        (uv.y + (p3+0.001)*((p3+0.001)+0.5)*0.4/(p3+0.001)));
    
    // ========================================================================
    // ROUNDED BORDER MASK
    // ========================================================================
    
    float radius = 28.0;  // Corner radius in pixels
    vec2 halfSize = resolution * 0.5;  // Half of screen size
    
    // Convert UV coordinates to pixel coordinates relative to center
    vec2 pixelPos = (vUv * resolution) - halfSize;
    
    // Calculate distance to rounded rectangle border
    float border = roundedBox(pixelPos, halfSize, radius);
    
    // Convert to mask: step(0.0, border) = 0 inside, 1 outside
    // We'll use this to make pixels outside the rounded rect transparent
    border = step(0.0, border);
    
    // ========================================================================
    // RIPPLE EFFECT SETUP
    // ========================================================================
    
    // Account for screen aspect ratio to keep ripples circular
    float ratio = resolution.x / resolution.y;
    
    // Ripple center point (adjusted for aspect ratio)
    // Located at middle-right, top of screen
    vec2 center = vec2(0.5 * ratio, 1.0);
    
    // Direction vector from ripple center to current pixel
    vec2 dir = center - vec2(vUv.x * ratio, vUv.y);
    
    // ========================================================================
    // CHROMATIC ABERRATION RIPPLES
    // ========================================================================
    
    // Create slightly offset ripples for Red, Green, Blue channels
    // This creates a chromatic aberration effect (rainbow edges)
    float debug = ripple(p2, dir);                    // For debugging
    float rDisp = ripple(p2 - 0.0025, dir);         // Red channel (slightly behind)
    float gDips = ripple(p2, dir);                   // Green channel (center)
    float bDips = ripple(p2 + 0.0025, dir);         // Blue channel (slightly ahead)
    
    // Calculate overall distance for mixing effects
    // 1.1 * p2 makes the mixing area slightly larger than the ripple
    float d = length(dir) - 1.1 * p2;
    
    // Normalize direction for displacement
    dir = normalize(dir);
    
    // ========================================================================
    // TEXTURE SAMPLING WITH DISPLACEMENT
    // ========================================================================
    
    // Sample each color channel with its own displacement
    // Displacement creates the "refraction" effect of the ripple
    float r = texture2D(tex, uv + dir * rDisp * 2.0).r;
    float g = texture2D(tex, uv + dir * gDips * 2.0).g;
    float b = texture2D(tex, uv + dir * bDips * 2.0).b;
    
    // Sample blurred version with displacement (for background effect)
    vec4 blurred = blur(tex, scaledUv + dir * rDisp, uTexelSize);
    
    // Regular texture sample (currently unused but kept)
    vec4 t = texture2D(tex, scaledUv + dir * rDisp);
    
    // ========================================================================
    // BRIGHT RING EFFECT
    // ========================================================================
    
    // Create a bright ring that follows the ripple
    // Center is slightly offset from ripple center (1.1 vs 1.0)
    vec2 center2 = vec2(vUv.x * ratio, vUv.y) - vec2(0.5 * ratio, 1.1);
    
    // Distance from ring center, scaled by animation progress
    float dist = (p * 1.15) - length(center2);
    
    // Create ring shape with smooth edges
    float ring = smoothstep(0.0, 0.15, dist);        // Outer edge
    ring *= smoothstep(0.1 + 0.1, 0.1, dist);        // Inner edge (creates hollow ring)
    ring *= 1.0 - smoothstep(0.9, 1.0, p);           // Fade out near end of animation
    
    // ========================================================================
    // FINAL COLOR COMPOSITION
    // ========================================================================
    
    // Mix blurred background with sharp displaced texture
    // When d is close to 1.0 (near ripple edge), show more of the displaced texture
    // When d is less than 0.95, show more of the blurred background
    gl_FragColor.rgb = mix(
        vec3(blurred).rgb * 1.2,              // Slightly brightened blur
        vec3(r, g, b),                        // Chromatic aberration displaced texture
        smoothstep(0.95, 1.0, 1.0 - d)       // Smooth transition based on distance
    );
    
    // Add bright ring effect on top
    // 22.5 * p creates intensity that grows with animation
    // Multiplied by blurred.rgb to tint the ring with underlying colors
    gl_FragColor.rgb += ring * 22.5 * p * blurred.rgb;
    
    // Debug option (uncommented to see raw ripple values)
    // gl_FragColor.rgb = vec3(debug * 10.0);
    
    // Set alpha: transparent outside rounded border, opaque inside
    gl_FragColor.a = mix(1.0, 0.0, border);
}
