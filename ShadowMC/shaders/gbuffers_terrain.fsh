#version 120

#define COLORED_SHADOWS 0 // Sombras neutras, sem tingir a tela [0 1 2]
#ifndef SHADOW_BRIGHTNESS
#define SHADOW_BRIGHTNESS 0.75 // Luz preservada na sombra [0.00 0.25 0.50 0.60 0.65 0.70 0.75 0.80 0.90 1.00]
#endif
#ifndef SHADOW_FILTER
#define SHADOW_FILTER 1 // Suavidade das sombras [0 1 2]
#endif

uniform sampler2D lightmap;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D texture;
uniform vec3 fogColor;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying float fogFactor;

#include "/distort.glsl"

float shadowSample(sampler2D map, vec2 uv, float depth) {
    uv = clamp(uv, vec2(0.001), vec2(0.999));
    depth = clamp(depth, 0.001, 0.999);
    vec2 texel = vec2(1.0 / float(shadowMapResolution));
    #if SHADOW_FILTER == 0
        return smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv).r);
    #elif SHADOW_FILTER == 1
        float result = 0.0;
        result += smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv + texel * vec2(-1.0, -1.0)).r);
        result += smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv + texel * vec2( 1.0, -1.0)).r);
        result += smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv + texel * vec2(-1.0,  1.0)).r);
        result += smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv + texel * vec2( 1.0,  1.0)).r);
        return result * 0.25;
    #else
        float result = 0.0;
        for (int x = -1; x <= 1; x++) for (int y = -1; y <= 1; y++)
            result += smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv + texel * vec2(float(x), float(y))).r);
        return result / 9.0;
    #endif
}

void main() {
    vec4 color = texture2D(texture, texcoord) * glcolor;
    vec2 lm = lmcoord;

    if (shadowPos.w > 0.0 && shadowSample(shadowtex0, shadowPos.xy, shadowPos.z) < 0.5) {
        lm.y *= SHADOW_BRIGHTNESS;
    }

    // Iluminação vanilla do lightmap e sombras neutras; sem luz dinâmica da mão.
    color *= texture2D(lightmap, lm);
    color.rgb = mix(fogColor, color.rgb, fogFactor);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
