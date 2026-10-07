#version 120

#define COLORED_SHADOWS 0 // Sombras neutras, sem tingir a tela [0 1 2]
#ifndef SHADOW_BRIGHTNESS
#define SHADOW_BRIGHTNESS 0.75 // Luz preservada na sombra [0.00 0.25 0.50 0.60 0.65 0.70 0.75 0.80 0.90 1.00]
#endif
#ifndef SHADOW_FILTER
#define SHADOW_FILTER 1 // Suavidade das sombras [0 1 2]
#endif
#ifndef WET_GROUND_STRENGTH
#define WET_GROUND_STRENGTH 0.22 // Brilho/escurecimento do solo molhado [0.00 0.12 0.22 0.32 0.40]
#endif
#ifndef PUDDLE_STRENGTH
#define PUDDLE_STRENGTH 0.28 // Intensidade das poças [0.00 0.12 0.20 0.28 0.36]
#endif

uniform sampler2D lightmap;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D texture;
uniform vec3 fogColor;
uniform float rainStrength;
uniform vec3 sunPosition;
uniform float frameTimeCounter;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying float fogFactor;
varying float materialType;
varying float emissiveType;
varying vec3 viewPosition;
varying vec3 viewNormal;
varying vec3 worldPosition;
varying vec3 worldNormal;

#include "/distort.glsl"

float shadowSample(sampler2D map, vec2 uv, float depth) {
    uv = clamp(uv, vec2(0.001), vec2(0.999));
    depth = clamp(depth, 0.001, 0.999);
    vec2 texel = vec2(1.0 / float(shadowMapResolution));
    #if SHADOW_FILTER == 0
        return smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv).r);
    #elif SHADOW_FILTER == 1
        float result = 0.0;
        result += smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv + texel * vec2(-1.0, -1.0)).r);
        result += smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv + texel * vec2( 1.0, -1.0)).r);
        result += smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv + texel * vec2(-1.0,  1.0)).r);
        result += smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv + texel * vec2( 1.0,  1.0)).r);
        return result * 0.25;
    #else
        float result = 0.0;
        for (int x = -1; x <= 1; x++) for (int y = -1; y <= 1; y++)
            result += smoothstep(depth - 0.003, depth + 0.001, texture2D(map, uv + texel * vec2(float(x), float(y))).r);
        return result / 9.0;
    #endif
}

float puddleNoise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec4 color = texture2D(texture, texcoord) * glcolor;
    vec2 lm = lmcoord;

    if (shadowPos.w > 0.0 && shadowSample(shadowtex0, shadowPos.xy, shadowPos.z) < 0.5) {
        lm.y *= SHADOW_BRIGHTNESS;
    }

    // Iluminação vanilla do lightmap e sombras neutras; sem luz dinâmica da mão.
    color *= texture2D(lightmap, lm);

    // Chuva: escurece levemente o material e cria um brilho especular barato.
    if (rainStrength > 0.001 && materialType < 0.5 && emissiveType < 0.5) {
        float wet = clamp(rainStrength * WET_GROUND_STRENGTH, 0.0, 0.45);
        color.rgb *= 1.0 - wet * 0.22;
        vec3 viewDir = normalize(-viewPosition);
        vec3 sunDir = length(sunPosition) > 0.01 ? normalize(sunPosition) : vec3(0.0, 1.0, 0.0);
        vec3 reflectedSun = reflect(-sunDir, normalize(viewNormal));
        float wetHighlight = pow(max(dot(reflectedSun, viewDir), 0.0), 18.0) * wet * 0.35;
        color.rgb += vec3(0.82, 0.90, 1.0) * wetHighlight;

        // Poças pequenas: somente superfícies quase horizontais recebem a máscara.
        float flatSurface = smoothstep(0.82, 0.98, abs(worldNormal.y));
        vec2 puddleCell = floor(worldPosition.xz * 0.22);
        float puddlePatch = smoothstep(0.48, 0.76, puddleNoise(puddleCell));
        float puddleMask = rainStrength * PUDDLE_STRENGTH * flatSurface * puddlePatch;
        float ripplePhase = dot(worldPosition.xz, vec2(1.70, 1.25)) * 3.0 + frameTimeCounter * 4.0;
        float rippleWave = 0.5 + 0.5 * sin(ripplePhase);
        float rippleBand = smoothstep(0.70, 0.92, rippleWave) * puddleMask;
        // O reflexo usa viewNormal porque sunPosition e viewDir estão em espaço de visão.
        vec3 rippleNormal = normalize(viewNormal + vec3(sin(ripplePhase) * 0.08, 0.0, cos(ripplePhase) * 0.08));
        float puddleHighlight = pow(max(dot(reflectedSun, viewDir), 0.0), 24.0) * puddleMask * 0.75;
        float rippleHighlight = pow(max(dot(reflect(-viewDir, rippleNormal), viewDir), 0.0), 8.0) * rippleBand * 1.15;
        color.rgb = mix(color.rgb, color.rgb * vec3(0.74, 0.82, 0.88) + vec3(0.035), puddleMask * 0.65);
        color.rgb += vec3(0.72, 0.84, 1.0) * (puddleHighlight + rippleHighlight);
    }
    color.rgb = mix(fogColor, color.rgb, fogFactor);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
