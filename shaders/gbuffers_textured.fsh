#version 120

uniform sampler2D lightmap;
uniform sampler2D shadowtex0;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying vec3 viewPosition;
varying float heldLightDist;

const bool shadowtex0Nearest = true;

#include "/settings.glsl"
#include "/shadow_filter.glsl"
#include "/held_light.glsl"
#include "/fog.glsl"

void main() {
    vec4 albedo = texture2D(texture, texcoord) * glcolor;
    if (albedo.a < 0.1) discard;

    vec2 lm = lmcoord;

    if (shadowPos.w > 0.001 &&
        shadowPos.x > 0.002 && shadowPos.x < 0.998 &&
        shadowPos.y > 0.002 && shadowPos.y < 0.998 &&
        shadowPos.z > 0.002 && shadowPos.z < 0.998) {
        float visibility = shadowSample(shadowtex0, shadowPos.xy, shadowPos.z);
        lm.y *= mix(SHADOW_BRIGHTNESS, 1.0, visibility);
    }

    vec3 light = texture2D(lightmap, lm).rgb;

    if (getHeldLightLevel() > 0.0) {
        light += getHeldLightContribution(heldLightDist);
    }

    vec3 color = applyFog(albedo.rgb * light, viewPosition);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, albedo.a);
}
