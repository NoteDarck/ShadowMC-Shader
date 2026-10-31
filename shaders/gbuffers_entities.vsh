#version 120

uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying float heldLightDist;

#include "/distort.glsl"

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    heldLightDist = length(viewPos.xyz);

    vec4 playerPos = gbufferModelViewInverse * viewPos;
    shadowPos = shadowProjection * (shadowModelView * playerPos);
    float bias = computeBias(shadowPos.xyz);
    shadowPos.xyz = distort(shadowPos.xyz) * 0.5 + 0.5;

    #if NORMAL_BIAS == 1
        vec4 normal = shadowProjection * vec4(mat3(shadowModelView) * (mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix * gl_Normal)), 1.0);
        shadowPos.xyz += normal.xyz / normal.w * bias;
    #else
        shadowPos.z -= bias;
    #endif

    shadowPos.w = 1.0;
    gl_Position = gl_ProjectionMatrix * viewPos;
}
