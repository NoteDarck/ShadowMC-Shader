#version 120

#define SHADOW_MAP_RESOLUTION 1024 // [256 512 1024] Resolução do mapa de sombras
#define SHADOW_BIAS 1.25 // [0.75 1.00 1.25 1.50 1.80] Correção contra shadow acne
#define SHADOW_DISTORT_FACTOR 0.10 // [0.05 0.08 0.10 0.14 0.20] Distribuição de resolução das sombras
#define SHADOW_BRIGHTNESS 0.66 // [0.55 0.60 0.66 0.70 0.75] Luz preservada nas sombras
#define SHADOW_FILTER 1 // [0 1] Suavidade das bordas das sombras
uniform sampler2D lightmap;
uniform sampler2D shadowtex0;
uniform sampler2D texture;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 shadowPos;
const bool shadowtex0Nearest = true;

#include "/distort.glsl"

float shadowVisibility(vec2 uv, float depth) {
    #if SHADOW_FILTER == 0
        return step(depth, texture2D(shadowtex0, uv).r + 0.0015);
    #else
        vec2 texel = vec2(1.0 / float(SHADOW_MAP_RESOLUTION));
        float visibility = 0.0;
        visibility += step(depth, texture2D(shadowtex0, uv + texel * vec2(-1.0, -1.0)).r + 0.0015);
        visibility += step(depth, texture2D(shadowtex0, uv + texel * vec2( 1.0, -1.0)).r + 0.0015);
        visibility += step(depth, texture2D(shadowtex0, uv + texel * vec2(-1.0,  1.0)).r + 0.0015);
        visibility += step(depth, texture2D(shadowtex0, uv + texel * vec2( 1.0,  1.0)).r + 0.0015);
        return visibility * 0.25;
    #endif
}

void main() {
    vec4 color = texture2D(texture, texcoord) * glcolor;
    vec2 lm = lmcoord;
    if (shadowPos.x > 0.001 && shadowPos.x < 0.999 && shadowPos.y > 0.001 && shadowPos.y < 0.999 && shadowPos.z > 0.001 && shadowPos.z < 0.999) {
        if (shadowVisibility(shadowPos.xy, shadowPos.z) < 0.5) lm.y *= SHADOW_BRIGHTNESS;
    }
    color *= texture2D(lightmap, lm);
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
