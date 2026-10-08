#version 120

#define SHADOW_MAP_RESOLUTION 1024 // [256 512 1024] Resolução do mapa de sombras
#define SHADOW_BIAS 1.25 // [0.75 1.00 1.25 1.50 1.80] Correção contra shadow acne
#define SHADOW_DISTORT_FACTOR 0.10 // [0.05 0.08 0.10 0.14 0.20] Distribuição de resolução das sombras
#define SHADOW_BRIGHTNESS 0.66 // [0.55 0.60 0.66 0.70 0.75] Luz preservada nas sombras
#define SHADOW_FILTER 1 // [0 1] Suavidade das bordas das sombras
#define AMBIENT_STRENGTH 0.12 // [0.00 0.08 0.12 0.16 0.20] Iluminação ambiente neutra
#define WATER_SPECULAR 0.32 // [0.00 0.16 0.32 0.48 0.64] Reflexo da água
#define METAL_SPECULAR 0.24 // [0.00 0.12 0.24 0.36 0.48] Reflexo de metais

uniform sampler2D lightmap;
uniform sampler2D shadowtex0;
uniform sampler2D texture;
uniform vec3 sunPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying float materialType;
varying vec3 viewPosition;
varying vec3 viewNormal;

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
    if (shadowPos.w > 0.001 && shadowPos.x > 0.001 && shadowPos.x < 0.999 && shadowPos.y > 0.001 && shadowPos.y < 0.999 && shadowPos.z > 0.001 && shadowPos.z < 0.999) {
        vec2 shadowUV = shadowPos.xy;
        float shadowDepth = shadowPos.z;
        // A pequena tolerância evita shadow acne e triângulos pretos de um pixel.
        if (shadowVisibility(shadowUV, shadowDepth) < 0.5) lm.y *= SHADOW_BRIGHTNESS;
    }
    color *= texture2D(lightmap, lm);
    // Iluminação ambiente neutra somente no terreno; a mão continua vanilla.
    float ambientLift = AMBIENT_STRENGTH * (1.0 - clamp(lm.y, 0.0, 1.0));
    color.rgb *= 1.0 + ambientLift;

    // Reflexo barato: água largo/azulado; metal mais concentrado e neutro.
    if (materialType > 0.5) {
        vec3 normal = normalize(viewNormal);
        vec3 viewDir = normalize(-viewPosition);
        vec3 lightDir = length(sunPosition) > 0.01 ? normalize(sunPosition) : vec3(0.0, 1.0, 0.0);
        vec3 reflected = reflect(-lightDir, normal);
        float facing = max(dot(normal, lightDir), 0.0);
        float fresnel = pow(1.0 - max(dot(normal, viewDir), 0.0), 5.0);
        if (materialType < 1.5) {
            float waterSpec = pow(max(dot(reflected, viewDir), 0.0), 32.0) * facing;
            color.rgb += vec3(0.38, 0.62, 0.86) * waterSpec * WATER_SPECULAR * (0.65 + fresnel);
        } else {
            float metalSpec = pow(max(dot(reflected, viewDir), 0.0), 64.0) * facing;
            color.rgb += vec3(0.92, 0.94, 1.0) * metalSpec * METAL_SPECULAR;
        }
    }
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
