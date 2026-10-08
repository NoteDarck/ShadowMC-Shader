#ifndef SHADOW_FILTER_GLSL_INCLUDED
#define SHADOW_FILTER_GLSL_INCLUDED

#ifndef SHADOW_FILTER
#define SHADOW_FILTER 1
#endif

#include "/distort.glsl"

float shadowDepthSample(sampler2D map, vec2 uv) {
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return 1.0;
    }
    return texture2D(map, uv).r;
}

float shadowCompare(sampler2D map, vec2 uv, float depth) {
    return step(depth, shadowDepthSample(map, uv));
}

float shadowSample(sampler2D map, vec2 uv, float depth) {
    vec2 texel = vec2(1.0 / float(shadowMapResolution));

    #if SHADOW_FILTER == 0
        return shadowCompare(map, uv, depth);
    #elif SHADOW_FILTER == 1
        float result = 0.0;
        result += shadowCompare(map, uv + texel * vec2(-1.0, -1.0), depth);
        result += shadowCompare(map, uv + texel * vec2( 1.0, -1.0), depth);
        result += shadowCompare(map, uv + texel * vec2(-1.0,  1.0), depth);
        result += shadowCompare(map, uv + texel * vec2( 1.0,  1.0), depth);
        return result * 0.25;
    #else
        float result = 0.0;
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                result += shadowCompare(map, uv + texel * vec2(float(x), float(y)), depth);
            }
        }
        return result / 9.0;
    #endif
}

#endif // SHADOW_FILTER_GLSL_INCLUDED