# ShadowMC Shader

Shaderpack leve para Minecraft Java com Iris/OptiFine, focado em sombras estáveis, desempenho e uma iluminação de mão que realmente ilumina o mundo.

## Recursos

- Sombras com distorção, bias por normal e filtro suave configurável (1, 4 ou 9 amostras).
- Perdas de luz suaves nas bordas das sombras, com perfis Potato, Low, Balanced, High e Ultra.
- Plantas e fontes de luz pequenas (tochas, lanternas) não projetam sombra, reduzindo artefatos e custo do shadow pass.
- Sombras em criaturas com intensidade separada do terreno.
- Iluminação ambiente discreta para evitar áreas totalmente pretas.
- Balanço procedural de vegetação, sincronizado entre o mundo e o shadow pass.
- Reflexos baratos em água e metais.
- Névoa sutil no horizonte e cintilação das estrelas.
- Aura RGB configurável em itens encantados.
- Efeito submerso (tinta azul + ondulação) e vinheta discreta no composite.
- **Luz na mão**: tochas, lanternas, glowstone, fogueiras, sea lantern, redstone torch, shroomlight, jack o'lantern e froglights iluminam o mundo ao redor e a própria mão. Funciona com item na mão principal ou secundária.

## Luz na mão

O pack usa os uniforms `heldItemId`, `heldBlockLightValue` e `heldBlockLightColor` fornecidos pelo Iris. As cores são escolhidas pelo ID do item definido em `shaders/item.properties`:

- `10002`: tocha / lanterna (laranja quente)
- `10003`: tocha / lanterna das almas / fogueira das almas (ciano)
- `10004`: glowstone / fogueira / magma (âmbar)
- `10005`: lanterna do mar (azul-esverdeado)
- `10006`: tocha de redstone (vermelho)
- `10007`: shroomlight / jack o'lantern / froglights (dourado)

A intensidade (`HAND_LIGHT_STRENGTH`) e o alcance (`HAND_LIGHT_RADIUS`) são configuráveis. Se outro mod fornecer uma cor personalizada via `heldBlockLightColor`, ela é usada automaticamente.

## Perfis

| Perfil | Shadow map | Filtro | Uso sugerido |
| --- | --- | --- | --- |
| Potato | 256 | 1 amostra | PCs bem modestos |
| Low | 512 | 1 amostra | PCs modestos |
| Balanced | 1024 | 4 amostras | Recomendado |
| High | 1024 | 4 amostras | Mais contraste e efeitos |
| Ultra | 1024 | 9 amostras | Qualidade máxima opcional |

As opções podem ser alteradas individualmente no menu de shaders. Todos os perfis mantêm o custo controlado: não há pós-processamento pesado, buffer extra, SSR, bloom, AO ou histórico de frames.

## Estrutura

- `distort.glsl`: distorção do shadow map e cálculo de bias.
- `shadow_filter.glsl`: comparação e filtro PCF do shadow map.
- `settings.glsl`: todas as opções do pack.
- `held_light.glsl`: cálculo da luz do item segurado.
- `gbuffers_*`: terreno, entidades, partículas, mão, céu e aura de encantamento.
- `composite.fsh`: efeitos de tela (submerso e vinheta).

## Compatibilidade

- Iris 1.7+ ou OptiFine com suporte a shaders.
- GLSL 1.20, sem dependência de compute shaders.
- IDs de blocos modernos (1.13+) e fallback legado em `block.properties`.
- A luz na mão depende de `heldBlockLightValue`; em versões muito antigas do OptiFine ela pode ficar desativada, sem quebrar o pack.

## Créditos

Estrutura de sombras baseada no exemplo clássico de shadow mapping para shaders de Minecraft. Reconstruído, otimizado e expandido por NoteDarck.
