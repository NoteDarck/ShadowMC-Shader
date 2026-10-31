#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;
uniform float frameTimeCounter;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

#include "/settings.glsl"
#include "/held_light.glsl"

void main() {
    vec4 tex = texture2D(texture, texcoord);
    vec4 color = tex * glcolor;
    vec3 light = texture2D(lightmap, lmcoord).rgb;

    if (heldBlockLightValue > 0 || heldBlockLightValue2 > 0) {
        light += getHeldLightColor() * (getHeldLightLevel() * HAND_LIGHT_STRENGTH * 0.40);
    }

    float mask = tex.a * glcolor.a;
    float shimmer = 0.85 + 0.15 * sin(frameTimeCounter * 2.5 + (texcoord.x + texcoord.y) * 18.0);
    vec3 aura = vec3(ENCHANT_AURA_COLOR_R, ENCHANT_AURA_COLOR_G, ENCHANT_AURA_COLOR_B);

    color.rgb = color.rgb * light + aura * (mask * ENCHANT_AURA_STRENGTH * shimmer);
    color.a = tex.a * glcolor.a;

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
