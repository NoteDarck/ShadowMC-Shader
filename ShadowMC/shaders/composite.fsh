#version 120

// Passe final neutro com AO opcional de baixo custo.
uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform sampler2D depthtex2;
uniform float viewWidth;
uniform float viewHeight;
varying vec2 texcoord;

#define SSAO_ENABLED 0 // AO em tela [0 1]
#define SSAO_STRENGTH 0.18 // Intensidade do AO [0.00 0.10 0.18 0.25]

void main() {
    vec4 color = texture2D(gcolor, texcoord);

    #if SSAO_ENABLED == 1
        vec2 pixel = vec2(1.0 / viewWidth, 1.0 / viewHeight);
        float center = texture2D(depthtex2, texcoord).r;
        float worldDepth = texture2D(depthtex2, texcoord).r;
        float handDepth = texture2D(depthtex0, texcoord).r;
        float handMask = smoothstep(0.001, 0.008, worldDepth - handDepth);
        float ao = 0.0;
        ao += step(texture2D(depthtex2, texcoord + pixel * vec2(-1.0,  0.0)).r + 0.002, center);
        ao += step(texture2D(depthtex2, texcoord + pixel * vec2( 1.0,  0.0)).r + 0.002, center);
        ao += step(texture2D(depthtex2, texcoord + pixel * vec2( 0.0, -1.0)).r + 0.002, center);
        ao += step(texture2D(depthtex2, texcoord + pixel * vec2( 0.0,  1.0)).r + 0.002, center);
        ao = 1.0 - (ao * 0.25 * SSAO_STRENGTH);
        ao = mix(ao, 1.0, handMask);
        if (center < 0.999) color.rgb *= ao;
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
