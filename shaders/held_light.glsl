#ifndef SHADOWMC_HELD_LIGHT_GLSL
#define SHADOWMC_HELD_LIGHT_GLSL

#include "/settings.glsl"

uniform int heldItemId;
uniform int heldItemId2;
uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;
uniform vec3 heldBlockLightColor;
uniform vec3 heldBlockLightColor2;

int getHeldLightItemId() {
    if (heldBlockLightValue2 > heldBlockLightValue) {
        return heldItemId2;
    }
    return heldItemId;
}

vec3 getHeldLightColor() {
    int itemId = getHeldLightItemId();

    if (itemId == 10002) return vec3(1.00, 0.72, 0.42); // tocha / lanterna
    if (itemId == 10003) return vec3(0.35, 0.78, 1.00); // tocha / lanterna das almas
    if (itemId == 10004) return vec3(1.00, 0.66, 0.34); // glowstone / fogueira
    if (itemId == 10005) return vec3(0.55, 0.95, 1.00); // lanterna do mar
    if (itemId == 10006) return vec3(1.00, 0.28, 0.20); // tocha de redstone
    if (itemId == 10007) return vec3(1.00, 0.76, 0.42); // shroomlight / abóbora / froglight
    if (itemId == 10008) return vec3(1.00, 0.42, 0.12); // balde de lava

    vec3 customColor = heldBlockLightColor2;
    if (heldBlockLightValue >= heldBlockLightValue2) {
        customColor = heldBlockLightColor;
    }

    float colorSum = customColor.r + customColor.g + customColor.b;
    if (colorSum > 0.01 && colorSum < 2.99) {
        return customColor;
    }
    return vec3(1.00, 0.72, 0.42);
}

float getHeldLightLevel() {
    if (getHeldLightItemId() == 10008) return 1.0;

    int level = heldBlockLightValue;
    if (heldBlockLightValue2 > level) {
        level = heldBlockLightValue2;
    }
    return clamp(float(level) / 15.0, 0.0, 1.0);
}

vec3 getHeldLightContribution(float distanceToPlayer) {
    float level = getHeldLightLevel();
    if (level <= 0.001) {
        return vec3(0.0);
    }

    float falloff = 1.0 - clamp(distanceToPlayer / HAND_LIGHT_RADIUS, 0.0, 1.0);
    falloff *= falloff;

    return getHeldLightColor() * (level * falloff * HAND_LIGHT_STRENGTH);
}

#endif // SHADOWMC_HELD_LIGHT_GLSL
