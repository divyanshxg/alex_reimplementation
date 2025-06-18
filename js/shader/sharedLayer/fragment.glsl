uniform sampler2D tex;
uniform vec2 resolution;
uniform float p;
uniform float p2;

varying vec2 vUv;


float easeInOutQuint(float x) {
    return x < 0.5 ? 16. * x * x * x * x * x : 1. - pow(-2. * x + 2., 5.) / 2.;
}

float roundedBox( vec2 p, vec2 b, float r ){
    return length(max(abs(p)-b+r,0.0))-r;
}



void main()	{
	vec2 uv = vUv;

    float ratio = resolution.x/resolution.y;


    // ACCOUNT FOR VERTEX SQUEEZE DEFORMATION
    float squeeze = easeInOutQuint(min(1., (distance(vec2(0.5*ratio,0.5), vec2(uv.x*ratio, uv.y)) * 2. * p) + p));
    vec2 planeSize = resolution;
    planeSize.x *= squeeze + 0.35 * (1.-squeeze);
    planeSize.y *= squeeze + 0.82 * (1.-squeeze);
    uv.x = (uv.x-0.5)*(1.-0.65*(1.-squeeze))+0.5;
    uv.y = (uv.y-0.5)*(1. - ((1.-p) * 0.45))+0.5;

    // SCALING THE IMAGE ON Y AXIS
    float scaleFactor = mix(1.0, 3.0, p2);
    vec2 scaledUv = uv;
    scaledUv.y = uv.y/mix(1.0, scaleFactor, (uv.y + (p2+0.001)*((p2+0.001)+0.5)*0.4/(p2+0.001)));

    // BORDER RADIUS
    float radius = 28. - 14. * (1.-squeeze);
	vec2 halfSize = vec2(planeSize) * 0.5;
	float border = roundedBox((vUv * planeSize) - halfSize, halfSize, radius);
    border = step(0.0, border);
	vec4 empty = vec4(0.,0.,0.,0.);

    vec4 t = texture2D(tex, scaledUv);

	gl_FragColor = mix(t, empty, border);
	
}