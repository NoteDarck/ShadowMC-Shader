#ifndef SHADOWMC_DISTORT_GLSL
#define SHADOWMC_DISTORT_GLSL

#include "/settings.glsl"

#if SHADOW_DISTORT_ENABLED == 1
vec3 distort(vec3 pos) {
    float factor = length(pos.xy) + SHADOW_DISTORT_FACTOR;
    return vec3(pos.xy / factor, pos.z * 0.5);
}

float computeBias(vec3 pos) {
    float numerator = length(pos.xy) + SHADOW_DISTORT_FACTOR;
    numerator *= numerator;
    return SHADOW_BIAS / float(shadowMapResolution) * numerator / max(SHADOW_DISTORT_FACTOR, 0.01);
}
#else
vec3 distort(vec3 pos) {
    return vec3(pos.xy, pos.z * 0.5);
}

float computeBias(vec3 pos) {
    return SHADOW_BIAS / float(shadowMapResolution);
}
#endif

#endif // SHADOWMC_DISTORT_GLSL
