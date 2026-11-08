#version 120

uniform sampler2D gcolor;
uniform float frameTimeCounter;
uniform int isEyeInWater;

varying vec2 texcoord;

#include "/settings.glsl"

vec3 applyColorGrade(vec3 color) {
    float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
    color = mix(vec3(luminance), color, COLOR_SATURATION);
    return clamp((color - 0.5) * COLOR_CONTRAST + 0.5, 0.0, 1.0);
}

void main() {
    vec2 uv = texcoord;

    #if UNDERWATER_EFFECTS == 1
        if (isEyeInWater == 1) {
            uv += vec2(
                sin(uv.y * 38.0 + frameTimeCounter * 1.6),
                cos(uv.x * 33.0 + frameTimeCounter * 1.2)
            ) * 0.0012;
        }
    #endif

    uv = clamp(uv, 0.0, 1.0);
    vec3 color = texture2D(gcolor, uv).rgb;
    color = applyColorGrade(color);

    #if UNDERWATER_EFFECTS == 1
        if (isEyeInWater == 1) {
            color = mix(color, color * vec3(0.55, 0.75, 1.00), 0.35);
        } else if (isEyeInWater == 2) {
            color *= vec3(1.00, 0.45, 0.15);
        }
    #endif

    vec2 centered = texcoord - 0.5;
    color *= 1.0 - VIGNETTE_STRENGTH * dot(centered, centered) * 2.0;

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}
