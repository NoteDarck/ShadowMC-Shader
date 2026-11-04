#ifndef SHADOWMC_FOG_GLSL
#define SHADOWMC_FOG_GLSL

#include "/settings.glsl"

uniform vec3 fogColor;
uniform float fogDensity;
uniform float fogStart;
uniform float fogEnd;
uniform int fogShape;

vec3 applyFog(vec3 color, vec3 viewPosition) {
    #if FOG_ENABLED == 1
        float distanceToCamera = fogShape == 0 ? length(viewPosition) : length(viewPosition.xz);

        float exponentialFog = 1.0 - exp(-fogDensity * fogDensity * distanceToCamera * distanceToCamera);
        float linearFog = 0.0;
        if (fogEnd > fogStart) {
            linearFog = 1.0 - clamp((fogEnd - distanceToCamera) / (fogEnd - fogStart), 0.0, 1.0);
        }
        float fogFactor = clamp(max(exponentialFog, linearFog), 0.0, 1.0);

        return mix(color, fogColor, fogFactor);
    #else
        return color;
    #endif
}

#endif // SHADOWMC_FOG_GLSL
