#version 120

uniform sampler2D lightmap;
uniform sampler2D shadowtex0;
uniform sampler2D texture;
uniform vec3 sunPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying float materialType;
varying float foliageType;
varying vec3 viewPosition;
varying vec3 viewNormal;
varying float heldLightDist;

const bool shadowtex0Nearest = true;

#include "/settings.glsl"
#include "/shadow_filter.glsl"
#include "/held_light.glsl"
#include "/fog.glsl"

void main() {
    vec4 albedo = texture2D(texture, texcoord) * glcolor;
    #if OPAQUE_LEAVES == 1
        if (foliageType > 0.5) albedo.a = 1.0;
    #endif
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

    vec3 color = albedo.rgb * light;
    color *= 1.0 + AMBIENT_STRENGTH * (1.0 - clamp(lm.y, 0.0, 1.0));

    if (materialType > 0.5) {
        vec3 normal = normalize(viewNormal);
        vec3 viewDir = normalize(-viewPosition);
        vec3 lightDir = length(sunPosition) > 0.01 ? normalize(sunPosition) : vec3(0.0, 1.0, 0.0);
        vec3 reflected = reflect(-lightDir, normal);
        float facing = max(dot(normal, lightDir), 0.0);
        float fresnel = pow(1.0 - max(dot(normal, viewDir), 0.0), 5.0);

        if (materialType < 1.5) {
            float waterSpec = pow(max(dot(reflected, viewDir), 0.0), 32.0) * facing;
            color += vec3(0.38, 0.62, 0.86) * (waterSpec * WATER_SPECULAR * (0.65 + fresnel));
        } else {
            float metalSpec = pow(max(dot(reflected, viewDir), 0.0), 64.0) * facing;
            color += vec3(0.92, 0.94, 1.0) * (metalSpec * METAL_SPECULAR);
        }
    }

    color = applyFog(color, viewPosition);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, albedo.a);
}
