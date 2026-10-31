#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

#include "/settings.glsl"
#include "/held_light.glsl"

void main() {
    vec4 albedo = texture2D(texture, texcoord) * glcolor;
    vec3 light = texture2D(lightmap, lmcoord).rgb;

    if (getHeldLightLevel() > 0.0) {
        light += getHeldLightColor() * (getHeldLightLevel() * HAND_LIGHT_STRENGTH);
    }

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(albedo.rgb * light, albedo.a);
}
