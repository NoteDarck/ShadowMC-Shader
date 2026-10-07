#ifndef SHADOW_FILTER
#define SHADOW_FILTER 1 // Suavidade das sombras [0 1 2]
#endif
#include "/distort.glsl"

float shadowSample(sampler2D map, vec2 uv, float depth) {
    // Fora do mapa, a textura pode retornar preto e criar falsos pixels de sombra.
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
