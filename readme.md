# ShadowMC Shader

Shaderpack leve para Minecraft Java com Iris/OptiFine, focado em sombras estáveis, desempenho e uma iluminação de mão que realmente ilumina o mundo.

## Recursos

- Sombras com distorção, bias por normal e filtro suave configurável (1, 4 ou 9 amostras).
- Perdas de luz suaves nas bordas das sombras, com perfis Potato, Low, Balanced, High e Ultra.
- Plantas e fontes de luz (tochas, lanternas, glowstone, etc.) não projetam sombra, reduzindo artefatos e custo do shadow pass.
- Sombras em criaturas com intensidade separada do terreno.
- Iluminação ambiente discreta para evitar áreas totalmente pretas.
- Balanço procedural de vegetação, sincronizado entre o mundo e o shadow pass.
- Reflexos baratos em água e metais.
- Névoa sutil no horizonte, neblina de distância configurável e cintilação das estrelas.
- Corte alpha correto em plantas, partículas, criaturas e itens na mão.
- Aura RGB configurável em itens encantados.
- Efeito submerso (tinta azul + ondulação) e vinheta discreta no composite.
- **Luz na mão**: tochas, lanternas, glowstone, fogueiras, sea lantern, redstone torch, shroomlight, jack o'lantern, froglights, balde de lava, glow lichen, sea pickle, ametista, obsidiana chorando, beacon, conduit e end rod iluminam o mundo ao redor e a própria mão. Funciona com item na mão principal ou secundária.
- **Sombras do jogador**: o personagem também é renderizado no shadow pass (`shadowPlayer=true`), inclusive em 1.20.1.
- **Folhas opacas opcionalmente**: remove o efeito quadriculado/transparente das folhas sem alterar o restante do terreno.
- **Imagem configurável**: saturação e contraste gerais para ajustar o visual sem editar shader.

## Luz na mão

O pack usa os uniforms `heldItemId`, `heldBlockLightValue` e `heldBlockLightColor` fornecidos pelo Iris. As cores são escolhidas pelo ID do item definido em `shaders/item.properties`:

- `10002`: tocha / lanterna (laranja quente)
- `10003`: tocha / lanterna das almas / fogueira das almas / glow lichen / sea pickle (ciano)
- `10004`: glowstone / fogueira / magma (âmbar)
- `10005`: lanterna do mar / beacon / conduit (azul-esverdeado)
- `10006`: tocha de redstone (vermelho)
- `10007`: shroomlight / jack o'lantern / froglights (dourado)
- `10008`: balde de lava (laranja intenso)
- `10009`: ametista / obsidiana chorando (violeta)
- `10010`: bastão do End (branco quente)

A intensidade (`HAND_LIGHT_STRENGTH`) e o alcance (`HAND_LIGHT_RADIUS`) são configuráveis, e a neblina pode ser desligada em `FOG_ENABLED`. Se outro mod fornecer uma cor personalizada via `heldBlockLightColor`, ela é usada automaticamente.

## Aura de encantamento

A aura colorida é aplicada ao brilho de equipamentos encantados (armadura e item na mão). No menu, abra `ENCHANTMENT`:

- `ENCHANT_AURA_STRENGTH`: intensidade da aura.
- `ENCHANT_AURA_COLOR_PRESET`: `0` para cor personalizada ou presets `1` azul, `2` roxo, `3` dourado, `4` verde, `5` vermelho, `6` ciano e `7` rosa.
- `ENCHANT_AURA_COLOR_R`, `ENCHANT_AURA_COLOR_G` e `ENCHANT_AURA_COLOR_B`: cor personalizada quando o preset é `0`.

## Folhas e imagem

- `OPAQUE_LEAVES`: use `1` na tela `SHADOWS` para remover a transparência quadriculada das folhas. O padrão `0` mantém o visual vanilla.
- `COLOR_SATURATION`: reduz ou aumenta a intensidade das cores no composite.
- `COLOR_CONTRAST`: ajusta o contraste final sem alterar a iluminação das sombras.

## Perfis

| Perfil | Shadow map | Distância | Filtro | Uso sugerido |
| --- | --- | --- | --- | --- |
| Potato | 256 | 64 blocos | 1 amostra | PCs bem modestos |
| Low | 512 | 96 blocos | 1 amostra | PCs modestos |
| Balanced | 1024 | 128 blocos | 4 amostras | Recomendado |
| High | 1024 | 160 blocos | 4 amostras | Mais contraste e efeitos |
| Ultra | 1024 | 192 blocos | 9 amostras | Qualidade máxima opcional |

As opções podem ser alteradas individualmente no menu de shaders. Todos os perfis mantêm o custo controlado: não há pós-processamento pesado, buffer extra, SSR, bloom, AO ou histórico de frames.

## Estrutura

- `distort.glsl`: distorção do shadow map e cálculo de bias.
- `shadow_filter.glsl`: comparação e filtro PCF do shadow map.
- `settings.glsl`: todas as opções do pack.
- `held_light.glsl`: cálculo da luz do item segurado.
- `fog.glsl`: neblina de distância baseada em `fogColor`, `fogStart`, `fogEnd` e `fogDensity`.
- `gbuffers_*`: terreno, entidades, partículas, mão, céu e aura de encantamento.
- `composite.fsh`: efeitos de tela (submerso e vinheta).

## Compatibilidade

- Iris 1.7+ ou OptiFine com suporte a shaders.
- GLSL 1.20, sem dependência de compute shaders.
- IDs de blocos modernos (1.13+) com tratamento de `short_grass`/`grass` por versão e fallback legado em `block.properties`.
- A luz na mão depende de `heldItemId`/`heldBlockLightValue`; em versões muito antigas do OptiFine ela pode ficar desativada, sem quebrar o pack.

## Versões e branches

- `mc-1.13` a `mc-1.21`: linhas modernas do Minecraft Java.
- `mc-26.1`, `mc-26.2`, `mc-26.3`: versões atuais.
- `mc-legacy`: Minecraft 1.7.10 a 1.12.2, usando o fallback de IDs antigos.
- `main`: código-fonte atualizado e base para novos desenvolvimentos.

Os ZIPs por versão são publicados no release `v0.1.3`.

## Créditos

Estrutura de sombras baseada no exemplo clássico de shadow mapping para shaders de Minecraft. Reconstruído, otimizado e expandido por NoteDarck.
