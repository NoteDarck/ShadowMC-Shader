#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float foliageType;

#include "/settings.glsl"

void main() {
    vec4 color = texture2D(texture, texcoord) * glcolor;
    #if OPAQUE_LEAVES == 1
        if (foliageType == 1.0) color.a = 1.0;
    #endif
    if (color.a < 0.1) discard;

	gl_FragData[0] = color;
}