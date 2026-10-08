#ifndef SHADOW_COMMON_GLSL_INCLUDED
#define SHADOW_COMMON_GLSL_INCLUDED

#include "/shadow_filter.glsl"

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

// Normal bias 使用 shadow map texel 的世界空间大小
// texel size = 2 * shadowDistance / shadowMapResolution
// 再乘 sqrt(2) 补偿 texel 方形的最坏对角偏移
float getNormalBiasScale() {
    return 1.4142136 * 2.0 / float(shadowMapResolution);
}

vec4 computeFragmentShadowPos(vec3 fragmentWorldPosition, vec3 fragmentWorldNormal,
                              float lightDot) {
    if (lightDot <= 0.0) return vec4(0.0);

    vec3 receiverPosition = fragmentWorldPosition;

    #ifdef NORMAL_BIAS
        // Normal bias: 沿法线偏移采样位置，偏移量由 texel 大小和角度决定
        // 不依赖世界坐标距离，避免移动时 bias 变化
        float angleBias = 1.0 - clamp(abs(lightDot), 0.0, 1.0);
        float normalBiasAmount = getNormalBiasScale() * (1.0 + angleBias * 2.0);
        receiverPosition += normalize(fragmentWorldNormal) * normalBiasAmount * SHADOW_BIAS;
    #endif

    vec4 playerPos = vec4(receiverPosition, 1.0);
    vec4 shadowClip = shadowProjection * (shadowModelView * playerPos);
    vec3 shadowNDC = shadowClip.xyz / shadowClip.w;

    float bias = computeBias(shadowNDC);
    shadowNDC = distort(shadowNDC);
    vec3 shadowUVZ = shadowNDC * 0.5 + 0.5;

    #ifndef NORMAL_BIAS
        shadowUVZ.z -= bias / max(abs(lightDot), 0.05);
    #endif

    return vec4(shadowUVZ, lightDot);
}

#endif // SHADOW_COMMON_GLSL_INCLUDED