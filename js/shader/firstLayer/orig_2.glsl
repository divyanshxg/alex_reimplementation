uniform sampler2D tex;
uniform vec2 resolution;
uniform vec2 uTexelSize;
uniform float p2;
uniform float p3;
uniform float p;

varying vec2 vUv;

#define c(value, minVal, maxVal) clamp(value, minVal, maxVal)


float remap(float value, float oldMin, float oldMax, float newMin, float newMax) {
    return newMin + (value - oldMin) * (newMax - newMin) / (oldMax - oldMin);
}

const int samples = 80,
          LOD = 2,         
          sLOD = 1 << LOD;
const float sigma = float(samples) * .25;

float gaussian(vec2 i) {
    i /= sigma;
    return exp(-0.5 * dot(i, i)) / (6.2831853 * sigma * sigma);
}

vec4 blur(sampler2D tex, vec2 uv, vec2 scale) {
    vec4 color = vec4(0.0);
    int s = samples / sLOD;

    for (int i = 0; i < s * s; i++) {
        vec2 d = vec2(i % s, i / s) * float(sLOD) - float(samples) * 0.5;
        vec2 offsetUV = uv + scale * d;
        color += gaussian(d) * textureLod(tex, offsetUV, float(LOD));
    }

    return color / color.a;
}




float roundedBox( vec2 p, vec2 b, float r ){
    return length(max(abs(p)-b+r,0.0))-r;
}

// float ripple(float p, vec2 dir){
//    float d = length(vec2(dir.x , dir.y - 0.4*p )) - 0.5 * p; // its starts from the middle 
//     d *= 1. - smoothstep(0.,0.051, abs(d)); // 0.051 units of glow from either 0 position of ripple
//     d *= smoothstep(0.,0.1, p); // initial mask
//     d *= 1. - smoothstep(0.9,1., p); // final mask
//     // d *= smoothstep(0.,0.1, p); // initial mask
//     // d *= 1. - smoothstep(0.9,1., p); // final mask
//
//     return d;
// }




float ripple(float p, vec2 dir){
   float d = 0.5*p - length(dir); // its starts from the middle 
   // float d = 0.6 - length(dir); // its starts from the middle 
   float a = 0.2;
   float b = 0.01;
   d  = smoothstep(0.00-a/2., 0.0+a/2., d);
   // d *= 0.1;
   
   //  d *= 1.;

    d *= smoothstep(0.,0.04, p); // initial mask
    d *= 1. - smoothstep(0.9,1., p); // final mask
    // d *= smoothstep(0.,0.1, p); // initial mask
    // d *= 1. - smoothstep(0.9,1., p); // final mask

    return d;
}


void main()	{
	vec2 uv = vUv;


    // Y TEXTURE SCALE
    float scaleFactor = mix(1.0, 1.25, p3);
    vec2 scaledUv = uv;
    scaledUv.y = uv.y/mix(1.0, scaleFactor, (uv.y + (p3+0.001)*((p3+0.001)+0.5)*0.4/(p3+0.001) ) );



    //BORDER RADIUS
    float radius = 28.;
    vec2 halfSize = resolution * 0.5;
    float border = roundedBox((vUv * resolution) - halfSize, halfSize, radius);
    border = step(0.0, border);


    // RIPPLES
    float ratio = resolution.x/resolution.y;

    vec2 center = vec2(0.5*ratio, 1.0);
    vec2 dir = center - vec2(vUv.x*ratio, vUv.y);

    float debug = ripple(p2, dir);
    // float rDisp = ripple(p2 - 0.0025, dir);
    // float gDips = ripple(p2, dir);
    // float bDips = ripple(p2 + 0.0025, dir);
    //
    // float d = length(dir) - 1.1 * p2;
    //
    // dir = normalize(dir);
    //
    // float r = texture2D(tex, uv + dir * rDisp * 2.).r;
    // float g = texture2D(tex, uv + dir * gDips * 2.).g;
    // float b = texture2D(tex, uv + dir * bDips * 2.).b;
    //
    //
    //  vec4 blurred = blur(tex, scaledUv + dir * rDisp, uTexelSize);
    //  vec4 t = texture2D(tex, scaledUv + dir * rDisp);
    //
    //
    // vec2 center2 = vec2(vUv.x*ratio, vUv.y) - vec2(0.5*ratio, 1.1);
    //
    // float dist = (p*1.15)-length(center2);
    //
    // float ring =  smoothstep(0., 0.15, dist);
    // ring *= smoothstep(0.1 + 0.1, 0.1, dist);
    // ring *= 1. - smoothstep(0.9,1., p);
    //
    //
    //
    // gl_FragColor.rgb = mix(vec3(blurred).rgb * 1.2, vec3(r, g, b), smoothstep(0.95,1.,1.-d));
    // gl_FragColor.rgb += ring * 22.5 * p * blurred.rgb;


    
  // My debug
    gl_FragColor.rgb = vec3(debug*1.);

    gl_FragColor.a = mix(1.,0.,border);
}
