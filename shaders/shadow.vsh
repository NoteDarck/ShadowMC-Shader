#version 120

attribute vec4 mc_Entity;
uniform float frameTimeCounter;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float foliageType;

#include "/distort.glsl"

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;
    if (mc_Entity.x == 10009.0) {
        foliageType = 1.0;
    } else if (mc_Entity.x == 10000.0) {
        foliageType = 2.0;
    } else if (mc_Entity.x == 10008.0) {
        foliageType = 3.0;
    } else {
        foliageType = 0.0;
    }

    #if EXCLUDE_FOLIAGE == 1
        if (mc_Entity.x == 10000.0 || mc_Entity.x == 10008.0) {
            gl_Position = vec4(10.0);
            return;
        }
    #endif

    if (mc_Entity.x == 10001.0) {
        gl_Position = vec4(10.0);
        return;
    }

    #if EXCLUDE_LIGHT_SOURCES == 1
        if (mc_Entity.x >= 10002.0 && mc_Entity.x <= 10006.0) {
            gl_Position = vec4(10.0);
            return;
        }
    #endif

    vec4 vertex = gl_Vertex;
    if ((mc_Entity.x == 10000.0 || mc_Entity.x == 10008.0 || mc_Entity.x == 10009.0) && VEGETATION_SWAY > 0.0) {
        float phase = dot(vertex.xz, vec2(1.71, 2.13));
        float height = 0.35 + 0.65 * fract(abs(vertex.y));
        float gust = sin(frameTimeCounter * 1.7 + phase) * 0.70 + sin(frameTimeCounter * 0.93 + phase * 1.37) * 0.30;
        vertex.x += gust * VEGETATION_SWAY * height;
        vertex.z += cos(frameTimeCounter * 1.35 + phase * 1.11) * VEGETATION_SWAY * 0.65 * height;
    }

    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * vertex;
    gl_Position.xyz = distort(gl_Position.xyz);
}
