#ifndef SHADOWMC_SETTINGS_GLSL
#define SHADOWMC_SETTINGS_GLSL

// ------------------------------------------------------------
// Sombras
// ------------------------------------------------------------
const int shadowMapResolution = 1024; // [256 512 1024] Resolução do mapa de sombras
const float shadowDistance = 128.0; // [64.0 80.0 96.0 112.0 128.0 160.0 192.0 224.0 256.0] Distância de renderização das sombras
#define SHADOW_DISTORT_ENABLED 1 // [0 1] Distorção de sombras perto do jogador
#define SHADOW_DISTORT_FACTOR 0.10 // [0.05 0.08 0.10 0.14 0.20] Intensidade da distorção
#define SHADOW_BIAS 1.25 // [0.75 1.00 1.25 1.50 1.80] Correção contra shadow acne
#define SHADOW_BRIGHTNESS 0.66 // [0.55 0.60 0.66 0.70 0.75] Luz preservada dentro da sombra
#define SHADOW_FILTER 1 // [0 1 2] Suavidade das bordas (1, 4 ou 9 amostras)
#define NORMAL_BIAS 1 // [0 1] Bias pela normal (reduz peter-panning)
#define EXCLUDE_FOLIAGE 1 // [0 1] Plantas não projetam sombra
#define EXCLUDE_LIGHT_SOURCES 1 // [0 1] Tochas e lanternas não projetam sombra
#define OPAQUE_LEAVES 0 // [0 1] Folhas sem transparência

// ------------------------------------------------------------
// Iluminação
// ------------------------------------------------------------
#define ENTITY_SHADOW_STRENGTH 0.82 // [0.55 0.70 0.82 0.90 1.00] Intensidade da sombra em criaturas
#define AMBIENT_STRENGTH 0.12 // [0.00 0.08 0.12 0.16 0.20] Iluminação ambiente extra em áreas escuras

// ------------------------------------------------------------
// Materiais
// ------------------------------------------------------------
#define WATER_SPECULAR 0.32 // [0.00 0.16 0.32 0.48 0.64] Reflexo da água
#define METAL_SPECULAR 0.24 // [0.00 0.12 0.24 0.36 0.48] Reflexo de metais

// ------------------------------------------------------------
// Natureza e atmosfera
// ------------------------------------------------------------
#define VEGETATION_SWAY 0.015 // [0.00 0.005 0.010 0.015 0.020 0.030] Balanço da vegetação
#define SKY_HAZE_STRENGTH 0.35 // [0.10 0.25 0.35 0.45 0.60] Névoa no horizonte
#define FOG_ENABLED 1 // [0 1] Neblina de distância
#define STAR_TWINKLE 1 // [0 1] Cintilação das estrelas
#define UNDERWATER_EFFECTS 1 // [0 1] Efeitos embaixo d'água
#define VIGNETTE_STRENGTH 0.12 // [0.00 0.06 0.12 0.18 0.24] Vinheta discreta
#define COLOR_SATURATION 1.00 // [0.70 0.85 1.00 1.15 1.30] Saturação geral
#define COLOR_CONTRAST 1.00 // [0.90 1.00 1.10 1.20] Contraste geral

// ------------------------------------------------------------
// Luz na mão
// ------------------------------------------------------------
#define HAND_LIGHT_STRENGTH 0.85 // [0.00 0.40 0.65 0.85 1.10] Intensidade da luz do item segurado
#define HAND_LIGHT_RADIUS 8.0 // [4.0 6.0 8.0 10.0 12.0] Alcance da luz em blocos

// ------------------------------------------------------------
// Aura de encantamento
// ------------------------------------------------------------
#define ENCHANT_AURA_STRENGTH 0.30 // [0.00 0.15 0.30 0.45 0.60] Brilho da aura
#define ENCHANT_AURA_COLOR_PRESET 0 // [0 1 2 3 4 5 6 7] Cor da aura (0=Personalizada, 1=Azul, 2=Roxo, 3=Dourado, 4=Verde, 5=Vermelho, 6=Ciano, 7=Rosa)
#define ENCHANT_AURA_COLOR_R 0.30 // [0.00 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00] Vermelho
#define ENCHANT_AURA_COLOR_G 0.65 // [0.00 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00] Verde
#define ENCHANT_AURA_COLOR_B 1.00 // [0.00 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00] Azul

#endif // SHADOWMC_SETTINGS_GLSL
