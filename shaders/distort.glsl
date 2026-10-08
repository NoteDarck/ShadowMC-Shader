#define SHADOW_MAP_RESOLUTION 1024 // [256 512 1024] Resolução do mapa de sombras
#define SHADOW_BIAS 1.25 // [0.75 1.00 1.25 1.50 1.80] Correção contra shadow acne
#define SHADOW_DISTORT_FACTOR 0.10 // [0.05 0.08 0.10 0.14 0.20] Distribuição de resolução das sombras
#define SHADOW_BRIGHTNESS 0.66 // [0.55 0.60 0.66 0.70 0.75] Luz preservada nas sombras
#define SHADOW_FILTER 1 // [0 1] Suavidade das bordas das sombras
#ifndef SHADOW_DISTORT_ENABLED
#define SHADOW_DISTORT_ENABLED
#endif
#ifndef SHADOW_DISTORT_FACTOR
#define SHADOW_DISTORT_FACTOR 0.10
#endif
#ifndef SHADOW_BIAS
#define SHADOW_BIAS 1.25
#endif
#ifndef SHADOW_BRIGHTNESS
#define SHADOW_BRIGHTNESS 0.66
#endif
#ifndef AMBIENT_STRENGTH
#define AMBIENT_STRENGTH 0.12
#endif
#ifndef SHADOW_MAP_RESOLUTION
#define SHADOW_MAP_RESOLUTION 1024
#endif
#ifndef NORMAL_BIAS
#define NORMAL_BIAS
#endif
#ifndef EXCLUDE_FOLIAGE
#define EXCLUDE_FOLIAGE
#endif

const int shadowMapResolution = SHADOW_MAP_RESOLUTION;

#ifdef SHADOW_DISTORT_ENABLED
vec3 distort(vec3 pos) {
    float factor = length(pos.xy) + SHADOW_DISTORT_FACTOR;
    return vec3(pos.xy / factor, pos.z * 0.5);
}
float computeBias(vec3 pos) {
    float numerator = length(pos.xy) + SHADOW_DISTORT_FACTOR;
    numerator *= numerator;
    return SHADOW_BIAS / float(shadowMapResolution) * numerator / SHADOW_DISTORT_FACTOR;
}
#else
vec3 distort(vec3 pos) { return vec3(pos.xy, pos.z * 0.5); }
float computeBias(vec3 pos) { return SHADOW_BIAS / float(shadowMapResolution); }
#endif
