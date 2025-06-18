uniform sampler2D tex;
uniform vec2 resolution;
uniform vec2 uTexelSize;
uniform float p2;
uniform float p3;
uniform float p4;
uniform float p;

varying vec2 vUv;

#define c(value, minVal, maxVal) clamp(value, minVal, maxVal)






float roundedBox( vec2 p, vec2 b, float r ){
    return length(max(abs(p)-b+r,0.0))-r;
}


void main()	{
	vec2 uv = vUv;
  vec3 glow_c = vec3(1.0, 0.92, 0.8);


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

    float t = p2;
    float t2 = p2;

    vec2 bang_offset = vec2(0.0);
    float bang_d = 0.0;
    float bang_d_glow = 0.0;
    if (t >= 1.0) {
        float aT = t - 1.0;
        vec2 uv2 = scaledUv - 0.5;
        uv2.x *= resolution.x / resolution.y; // Use uPlane for aspect ratio

        vec2 uv_bang = vec2(uv2.x, uv2.y);
        vec2 uv_bang_origin = vec2(uv_bang.x , uv_bang.y - 0.5);
        bang_d = (aT * 0.16) / length(uv_bang_origin);
        bang_d_glow = (aT * 0.16) / length(uv_bang_origin);
        bang_d = smoothstep(0.09, 0.05, bang_d) * smoothstep(0.04, 0.07, bang_d) * (uv.y + 0.05);

        bang_d_glow= smoothstep(0.09, 0.05, bang_d_glow) * smoothstep(0.04, 0.07, bang_d_glow) * (uv.y + 0.05);
        bang_offset = vec2(-8.0 * bang_d * uv2.x, -4.0 * bang_d * (uv2.y - 0.4)) * 0.1;

        float bang_d2 = ((aT - 0.085) * 0.14) / length(uv_bang_origin);
        bang_d2 = smoothstep(0.09, 0.05, bang_d2) * smoothstep(0.04, 0.07, bang_d2) * (uv.y + 0.05);
        bang_offset += vec2(-8.0 * bang_d2 * uv2.x, -4.0 * bang_d2 * (uv2.y - 0.4)) * -0.02;
    }

    vec2 uv_bang = scaledUv + bang_offset;
    vec4 color = texture2D(tex , uv_bang);
    // color += bang_d * 500.0 * smoothstep(1.05, 1.1, t);
    color.xyz += bang_d_glow * 400.0*smoothstep(1.05 , 1.1,t) * glow_c;

    if (t >= 1.0) {
        float Pi = 6.28318530718 * 2.0;
        float Directions = 60.0;
        float Quality = 10.0;
        float Radius = t2 * 0.1 * pow(uv.y, 6.0) * 0.5;
        Radius *= smoothstep(1.3, 0.9, t);
        Radius += bang_d * 0.05;

        // Blur calculations
        for (float d = 0.0; d < Pi; d += Pi / Directions) {
            for (float i = 1.0 / Quality; i <= 1.0; i += 1.0 / Quality) {
                vec2 blurPos = uv_bang + vec2(cos(d), sin(d)) * Radius * i;
                color += texture2D(tex, blurPos);
            }
        }
        color /= Quality * Directions;
    }

    gl_FragColor = color;


    // Top Glow
    float scaleX = 0.3;

    vec2 glow_position = vec2(0.5*ratio*scaleX, 1.);

    float glow_l = length(vec2(scaledUv.x*ratio*scaleX , scaledUv.y ) - glow_position);

    float glow = (0.001 + 0.10*p4)/glow_l;

    // glow = pow(glow , 1. + 1.*smoothstep(0.7 , 1.0 , p4) );
    glow = pow(glow , 1.2  );


    glow = 1.0 - exp( -glow);
    
    glow *= smoothstep(1.0 , 0.85 , p4);

    gl_FragColor.xyz += glow * glow_c;
    gl_FragColor.a = mix(1.,0.,border);
}
