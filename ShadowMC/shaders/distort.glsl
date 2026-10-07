#ifndef SHADOW_DISTORT_ENABLED
#define SHADOW_DISTORT_ENABLED // Distorção aumenta detalhe perto do jogador.
#endif
#ifndef SHADOW_DISTORT_FACTOR
#define SHADOW_DISTORT_FACTOR 0.10 // Distorção [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50]
#endif
#ifndef SHADOW_BIAS
#define SHADOW_BIAS 1.00 // Corrige shadow acne; valores maiores reduzem acne [0.00 0.25 0.50 0.75 1.00 1.50 2.00 3.00]
#endif
#ifndef NORMAL_BIAS
#define NORMAL_BIAS
#endif
#ifndef EXCLUDE_FOLIAGE
#define EXCLUDE_FOLIAGE
#endif
#ifndef SHADOW_BRIGHTNESS
#define SHADOW_BRIGHTNESS 0.75 // Luz preservada na sombra [0.00 0.25 0.50 0.60 0.65 0.70 0.75 0.80 0.90 1.00]
#endif
#ifndef SHADOW_MAP_RESOLUTION
#define SHADOW_MAP_RESOLUTION 1024 // Resolução [128 256 512 1024 2048 4096]
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
    return SHADOW_BIAS / shadowMapResolution * numerator / SHADOW_DISTORT_FACTOR;
}
#else
vec3 distort(vec3 pos) {
    return vec3(pos.xy, pos.z * 0.5);
}

float computeBias(vec3 pos) {
    return SHADOW_BIAS / shadowMapResolution;
}
#endif
