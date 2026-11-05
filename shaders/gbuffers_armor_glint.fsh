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
    if (color.a < 0.1) discard;
    vec3 light = texture2D(lightmap, lmcoord).rgb;

    if (getHeldLightLevel() > 0.0) {
        light += getHeldLightColor() * (getHeldLightLevel() * HAND_LIGHT_STRENGTH * 0.40);
    }

    float mask = tex.a * glcolor.a;
    float shimmer = 0.85 + 0.15 * sin(frameTimeCounter * 2.5 + (texcoord.x + texcoord.y) * 18.0);
    vec3 aura = vec3(ENCHANT_AURA_COLOR_R, ENCHANT_AURA_COLOR_G, ENCHANT_AURA_COLOR_B);
    #if ENCHANT_AURA_COLOR_PRESET == 1
        aura = vec3(0.30, 0.65, 1.00);
    #elif ENCHANT_AURA_COLOR_PRESET == 2
        aura = vec3(0.65, 0.30, 1.00);
    #elif ENCHANT_AURA_COLOR_PRESET == 3
        aura = vec3(1.00, 0.75, 0.25);
    #elif ENCHANT_AURA_COLOR_PRESET == 4
        aura = vec3(0.30, 1.00, 0.45);
    #elif ENCHANT_AURA_COLOR_PRESET == 5
        aura = vec3(1.00, 0.30, 0.25);
    #elif ENCHANT_AURA_COLOR_PRESET == 6
        aura = vec3(0.25, 1.00, 0.95);
    #elif ENCHANT_AURA_COLOR_PRESET == 7
        aura = vec3(1.00, 0.40, 0.75);
    #endif

    color.rgb = color.rgb * light + aura * (mask * ENCHANT_AURA_STRENGTH * shimmer);
    color.a = tex.a * glcolor.a;

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
