#version 120

#define SHADOW_MAP_RESOLUTION 1024 // [256 512 1024] Resolução do mapa de sombras
#define SHADOW_BIAS 1.25 // [0.75 1.00 1.25 1.50 1.80] Correção contra shadow acne
#define SHADOW_DISTORT_FACTOR 0.10 // [0.05 0.08 0.10 0.14 0.20] Distribuição de resolução das sombras
#define SHADOW_BRIGHTNESS 0.66 // [0.55 0.60 0.66 0.70 0.75] Luz preservada nas sombras
#define SHADOW_FILTER 1 // [0 1] Suavidade das bordas das sombras
#define VEGETATION_SWAY 0.015 // [0.00 0.005 0.010 0.015 0.020 0.030] Balanço da vegetação

attribute vec4 mc_Entity;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;
uniform float frameTimeCounter;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying float materialType;
varying vec3 viewPosition;
varying vec3 viewNormal;

#include "/distort.glsl"

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;
    materialType = mc_Entity.x == 10001.0 ? 1.0 : (mc_Entity.x == 10007.0 ? 2.0 : 0.0);

    float lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));
    #ifdef EXCLUDE_FOLIAGE
        if (mc_Entity.x == 10000.0) lightDot = 1.0;
    #endif

    vec4 vertex = gl_Vertex;
    if (mc_Entity.x == 10000.0 && VEGETATION_SWAY > 0.0) {
        float phase = dot(vertex.xz, vec2(1.71, 2.13));
        float height = 0.35 + 0.65 * fract(abs(vertex.y));
        float gust = sin(frameTimeCounter * 1.7 + phase) * 0.70 + sin(frameTimeCounter * 0.93 + phase * 1.37) * 0.30;
        vertex.x += gust * VEGETATION_SWAY * height;
        vertex.z += cos(frameTimeCounter * 1.35 + phase * 1.11) * VEGETATION_SWAY * 0.65 * height;
    }

    vec4 viewPos = gl_ModelViewMatrix * vertex;
    viewPosition = viewPos.xyz;
    viewNormal = normalize(gl_NormalMatrix * gl_Normal);
    if (lightDot > 0.0) {
        vec4 playerPos = gbufferModelViewInverse * viewPos;
        shadowPos = shadowProjection * (shadowModelView * playerPos);
        float bias = computeBias(shadowPos.xyz);
        shadowPos.xyz = distort(shadowPos.xyz) * 0.5 + 0.5;
        #ifdef NORMAL_BIAS
            vec4 normal = shadowProjection * vec4(mat3(shadowModelView) * (mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal)), 1.0);
            shadowPos.xyz += normal.xyz / normal.w * bias;
        #else
            shadowPos.z -= bias / max(abs(lightDot), 0.001);
        #endif
    } else {
        lmcoord.y *= SHADOW_BRIGHTNESS;
        shadowPos = vec4(0.0);
    }
    shadowPos.w = lightDot;
    gl_Position = gl_ProjectionMatrix * viewPos;
}
