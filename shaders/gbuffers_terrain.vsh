#version 120

attribute vec4 mc_Entity;

#define VEGETATION_SWAY 0.015 // Movimento de folhas e grama [0.00 0.005 0.010 0.015 0.020 0.030]
#define ATMOSPHERIC_FOG 0.65 // Névoa atmosférica de baixo custo [0.00 0.40 0.55 0.65 0.80 1.00]

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;
uniform float frameTimeCounter;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying float fogFactor;
varying float materialType;
varying float emissiveType;
varying float emissiveColorType;
varying float viewDistance;
varying vec3 viewPosition;
varying vec3 viewNormal;
varying vec3 worldPosition;
varying vec3 worldNormal;

#include "/distort.glsl"

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;
    materialType = (mc_Entity.x == 10001.0) ? 1.0 : 0.0;
    emissiveType = (mc_Entity.x >= 10002.0 && mc_Entity.x <= 10006.0) ? 1.0 : 0.0;
    emissiveColorType = mc_Entity.x - 10001.0;

    vec4 vertex = gl_Vertex;
    if (mc_Entity.x == 10000.0) {
        float phase = dot(gl_Vertex.xyz, vec3(1.7, 0.7, 2.1));
        float wind = sin(frameTimeCounter * 1.8 + phase) * VEGETATION_SWAY;
        vertex.x += wind * (0.35 + gl_Vertex.y);
        vertex.z += cos(frameTimeCounter * 1.35 + phase * 1.3) * VEGETATION_SWAY * 0.55 * (0.35 + gl_Vertex.y);
    }

    float lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));
    #ifdef EXCLUDE_FOLIAGE
        if (mc_Entity.x == 10000.0) lightDot = 1.0;
    #endif

    vec4 viewPos = gl_ModelViewMatrix * vertex;
    viewPosition = viewPos.xyz;
    viewNormal = normalize(gl_NormalMatrix * gl_Normal);
    worldPosition = (gbufferModelViewInverse * viewPos).xyz;
    worldNormal = normalize(mat3(gbufferModelViewInverse) * viewNormal);
    viewDistance = length(viewPos.xyz);
    fogFactor = clamp(exp(-pow(length(viewPos.xyz) * (0.006 + ATMOSPHERIC_FOG * 0.004), 2.0)), 0.0, 1.0);
    if (lightDot > 0.0) {
        vec4 playerPos = gbufferModelViewInverse * viewPos;
        shadowPos = shadowProjection * (shadowModelView * playerPos);
        float bias = computeBias(shadowPos.xyz);
        shadowPos.xyz = distort(shadowPos.xyz);
        shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5;
        #ifdef NORMAL_BIAS
            vec4 normal = shadowProjection * vec4(mat3(shadowModelView) * (mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal)), 1.0);
            shadowPos.xyz += normal.xyz / normal.w * bias;
        #else
            shadowPos.z -= bias / abs(lightDot);
        #endif
    }
    else {
        lmcoord.y *= SHADOW_BRIGHTNESS;
        shadowPos = vec4(0.0);
    }
    shadowPos.w = lightDot;
    gl_Position = gl_ProjectionMatrix * viewPos;
}
