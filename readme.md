# ShadowMC Clean

Reconstrução limpa do shaderpack para Minecraft Java com Iris/OptiFine.

## Princípios

- A mão usa somente textura, `glcolor` e `lightmap` vanilla.
- Não há luz dinâmica segurada, luz nos pés, emissão customizada ou filtro global de cor.
- Sombras usam apenas `shadowtex0` e uma comparação neutra.
- Entidades, terreno e partículas usam a mesma regra de sombra, sem `shadowcolor0`.
- O composite apenas copia `gcolor`; não há bloom, AO, SSR, histórico de frames ou poças em pós-processamento.
- Macros de configuração são protegidas por `#ifndef`, evitando redefinições conflitantes.
- Perfis Potato, Low, Balanced e High controlam somente resolução, bias, distorção e brilho das sombras.

## Perfis

Balanced é o perfil recomendado. Potato e Low reduzem o custo do shadow map; High aumenta a resolução sem ativar filtros adicionais.

## Limitação intencional

Efeitos de chuva, poças e luz colorida foram removidos nesta base para evitar conflitos. Primeiro a iluminação e as sombras ficam estáveis; efeitos adicionais podem ser reintroduzidos em passes isolados depois.

## Correção de triângulo preto e iluminação ambiente

As sombras agora ignoram coordenadas fora do shadow map e usam uma tolerância de profundidade de 0.0015 para evitar shadow acne e triângulos pretos isolados. O terreno recebe um lift ambiente neutro controlado por `AMBIENT_STRENGTH`; a mão permanece totalmente vanilla.

## Perfis e melhorias visuais

Os perfis usam a sintaxe oficial `OPCAO=valor` e as opções são declaradas diretamente nos passes que as utilizam. Potato e Low usam sombras de uma amostra; Balanced e High usam filtro suave de quatro amostras. A iluminação ambiente neutra melhora áreas escuras sem alterar a mão ou adicionar cor global.

## Sombras de criaturas e atmosfera

Entidades agora calculam posição no shadow map em todas as faces do modelo, em vez de descartar faces voltadas para longe do sol. Isso permite que jogadores, animais e monstros recebam sombras completas. `ENTITY_SHADOW_STRENGTH` controla a intensidade separadamente. Também foi adicionado `SKY_HAZE_STRENGTH` para uma atmosfera discreta no horizonte.

## Reflexos especulares

Água recebe um reflexo amplo azul-esverdeado com fresnel suave. Ferro, ouro, cobre, diamante, esmeralda e netherita recebem reflexos mais concentrados e neutros. A classificação usa `block.properties` e o cálculo acontece apenas no passe do terreno, sem alterar a mão ou criar pós-processamento global.

## Vegetação animada

Folhas, grama, flores, plantações e outras entradas de `block.10000` recebem balanço procedural leve usando `frameTimeCounter`. O mesmo movimento é aplicado ao shadow pass quando a vegetação participa dele, evitando sombras atrasadas. A intensidade é controlada por `VEGETATION_SWAY` nos perfis.
