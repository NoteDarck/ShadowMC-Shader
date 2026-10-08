#version 120

#define SHADOW_MAP_RESOLUTION 1024 // [256 512 1024] Resolução do mapa de sombras
#define SHADOW_BIAS 1.25 // [0.75 1.00 1.25 1.50 1.80] Correção contra shadow acne
#define SHADOW_DISTORT_FACTOR 0.10 // [0.05 0.08 0.10 0.14 0.20] Distribuição de resolução das sombras
#define SHADOW_BRIGHTNESS 0.66 // [0.55 0.60 0.66 0.70 0.75] Luz preservada nas sombras
#define SHADOW_FILTER 1 // [0 1] Suavidade das bordas das sombras

uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;

#include "/distort.glsl"

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 playerPos = gbufferModelViewInverse * viewPos;
    shadowPos = shadowProjection * (shadowModelView * playerPos);
    float bias = computeBias(shadowPos.xyz);
    shadowPos.xyz = distort(shadowPos.xyz) * 0.5 + 0.5;
    #ifdef NORMAL_BIAS
        vec4 normal = shadowProjection * vec4(mat3(shadowModelView) * (mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal)), 1.0);
        shadowPos.xyz += normal.xyz / normal.w * bias;
    #else
        shadowPos.z -= bias;
    #endif

    // Entidades recebem sombra em todas as faces, evitando regiões sem sombra no modelo.
    shadowPos.w = 1.0;
    gl_Position = gl_ProjectionMatrix * viewPos;
}
