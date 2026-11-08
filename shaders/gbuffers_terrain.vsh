#version 120

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
varying float foliageType;
varying vec3 viewPosition;
varying vec3 viewNormal;
varying float heldLightDist;

#include "/distort.glsl"

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;

    foliageType = (mc_Entity.x == 10000.0 || mc_Entity.x == 10008.0) ? 1.0 : 0.0;
    materialType = 0.0;
    if (mc_Entity.x == 10001.0) {
        materialType = 1.0;
    } else if (mc_Entity.x == 10007.0) {
        materialType = 2.0;
    }

    vec4 vertex = gl_Vertex;
    if ((mc_Entity.x == 10000.0 || mc_Entity.x == 10008.0) && VEGETATION_SWAY > 0.0) {
        float phase = dot(vertex.xz, vec2(1.71, 2.13));
        float height = 0.35 + 0.65 * fract(abs(vertex.y));
        float gust = sin(frameTimeCounter * 1.7 + phase) * 0.70 + sin(frameTimeCounter * 0.93 + phase * 1.37) * 0.30;
        vertex.x += gust * VEGETATION_SWAY * height;
        vertex.z += cos(frameTimeCounter * 1.35 + phase * 1.11) * VEGETATION_SWAY * 0.65 * height;
    }

    vec4 viewPos = gl_ModelViewMatrix * vertex;
    viewPosition = viewPos.xyz;
    viewNormal = normalize(gl_NormalMatrix * gl_Normal);
    heldLightDist = length(viewPos.xyz);

    float lightDot = dot(normalize(shadowLightPosition), viewNormal);
    #if EXCLUDE_FOLIAGE == 1
        if (mc_Entity.x == 10000.0 || mc_Entity.x == 10008.0) {
            lightDot = 1.0;
        }
    #endif

    if (lightDot > 0.0) {
        vec4 playerPos = gbufferModelViewInverse * viewPos;
        shadowPos = shadowProjection * (shadowModelView * playerPos);
        float bias = computeBias(shadowPos.xyz);
        shadowPos.xyz = distort(shadowPos.xyz) * 0.5 + 0.5;

        #if NORMAL_BIAS == 1
            vec4 normal = shadowProjection * vec4(mat3(shadowModelView) * (mat3(gbufferModelViewInverse) * viewNormal), 0.0);
            shadowPos.xyz += normal.xyz * bias;
        #else
            shadowPos.z -= bias / max(abs(lightDot), 0.05);
        #endif
    } else {
        lmcoord.y *= SHADOW_BRIGHTNESS;
        shadowPos = vec4(0.0);
    }

    shadowPos.w = lightDot;
    gl_Position = gl_ProjectionMatrix * viewPos;
}
