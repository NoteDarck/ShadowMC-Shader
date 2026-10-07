# ShadowMC

Shaderpack leve para OptiFine/Iris, com sombras coloridas e pós-processamento configurável.

## Perfis rápidos

Abra as opções do shader e escolha um perfil:

- **Potato** — sombras 256, sem bloom e sem vinheta; indicado para PCs muito fracos.
- **Low** — sombras 512 e efeitos mínimos; bom equilíbrio para notebooks.
- **Balanced** — sombras 1024, imagem mais viva e bloom sutil; recomendado.
- **High** — sombras 2048 e pós-processamento um pouco mais forte.

Depois de selecionar um perfil, você pode ajustar os controles individualmente:

- **Shadow Map Resolution** — nitidez das sombras versus FPS.
- **Shadow Distort Factor** — concentra mais resolução perto do jogador.
- **Shadow Bias** — aumente se aparecer acne/flickering; reduza se a sombra parecer afastada do bloco.
- **Shadow Brightness** — quantidade de luz preservada dentro das sombras.
- **Image Brightness** — brilho/exposição geral.
- **Image Contrast** — contraste da imagem.
- **Image Saturation** — intensidade das cores.
- **Bloom Strength** — brilho suave em áreas claras, com apenas quatro amostras extras.
- **Vignette Strength** — escurecimento sutil nas bordas da tela.

## Características

- Sombras com distorção espacial para obter mais detalhe perto do jogador.
- Sombras coloridas de vidro e outros blocos translúcidos.
- Brilho, contraste e saturação aplicados em um único passe.
- Bloom opcional de baixo custo, sem buffers adicionais.
- Vinheta opcional e discreta.
- Perfis de desempenho para alternar rapidamente entre qualidade e FPS.

## Compatibilidade

Compatível com shader loaders que suportam o formato OptiFine/Iris. Se a opção não aparecer, recarregue os shaders ou reinicie o mundo após trocar o pack.

## Como as sombras funcionam

A sombra é renderizada primeiro em um shadow map visto da posição do sol. Depois, os passes `gbuffers` comparam a profundidade do mundo com esse mapa para escurecer apenas as superfícies que estão ocultas do sol. A distorção aumenta a quantidade efetiva de detalhe perto do jogador sem exigir uma resolução enorme em todo o mapa.

## Melhorias visuais

A versão atual também inclui sombras suaves configuráveis, água com reflexo estilizado de baixo custo, animação de folhas e grama, névoa atmosférica por distância e iluminação ambiente leve. O perfil **Potato** desliga o reflexo e usa sombra simples; **Low** reduz os efeitos; **Balanced** oferece o visual recomendado; e **High** usa PCF 3×3 e efeitos mais fortes.

## Água e luz dinâmica

A água agora usa apenas uma mistura de cor de baixo custo, sem SSR, sem ondas em tempo real e sem amostras extras. Isso evita o aspecto artificial e reduz o impacto no FPS; o perfil Potato desliga o reflexo e Low usa apenas um reflexo mínimo.

Quando o jogador segura uma tocha, lanterna ou outro item com emissão de luz reconhecida pelo Iris/OptiFine, o shader aplica uma luz quente suave próxima à câmera. O controle `DYNAMIC_HAND_LIGHT` permite reduzir ou desligar o efeito. Essa é uma aproximação leve, não uma nova fonte de luz dinâmica completa, por isso não exige um segundo passe de renderização.

A iluminação da mão diferencia os itens: tochas e lanternas normais usam luz laranja, tochas e lanternas das almas usam luz azul fria, e Glowstone, lanternas do mar e fogueiras usam luz amarela quente. A própria mão recebe uma emissão discreta para o item não parecer apagado.

A iluminação global amarela foi removida dos perfis. As cores agora ficam separadas por fonte: tocha/lanterna em laranja, soul torch/soul lantern em azul, Glowstone/fogueira em dourado e Sea Lantern em ciano. Isso evita que toda a sala fique amarela quando existe apenas uma fonte específica.

## Edição otimizada

A edição otimizada mantém um passe final neutro para preservar as cores originais. Ela inclui sombras com PCF configurável, bias e distorção, iluminação ambiente apenas em áreas escuras, névoa atmosférica por distância, movimento leve de folhas e grama, água com uma tintura simples sem reflexos caros e perfis Potato, Low, Balanced e High. A mão não recebe iluminação ou tintura customizada.

A arquitetura segue a documentação de desenvolvimento do OptiFine/Iris e usa quatro amostras de sombra no perfil Balanced, deixando nove amostras apenas no High.

## Recursos recomendados adicionados

Esta versão adiciona uma atmosfera leve no céu, tonalização discreta de chuva/neve e um SSAO experimental de quatro amostras. O SSAO permanece desligado em todos os perfis e pode ser testado na tela Experimental. A mão continua sem tintura, bloom, lightmap adicional ou emissão customizada. LabPBR, SSR, TAA, POM, god rays e névoa volumétrica não foram ativados nesta rodada por exigirem buffers e testes específicos no Minecraft 26.3.

## Iluminação da mão e cores vibrantes

A iluminação da mão voltou de forma controlada. A luz segurada usa `heldBlockLightValue` para iluminar suavemente o terreno, com cores específicas por fonte. O item renderizado recebe apenas uma emissão multiplicativa pequena, preservando a textura e evitando o véu branco. A intensidade pode ser ajustada em Lighting com `DYNAMIC_HAND_LIGHT` e `HAND_EMISSION_STRENGTH`.

## Luz pontual nos pés

A emissão visual da mão foi removida novamente. Ao segurar uma fonte luminosa, o terreno recebe agora uma luz pontual suave centrada aproximadamente nos pés do jogador, com queda por distância. A cor acompanha a fonte segurada: tocha laranja, soul torch azul, Sea Lantern ciano e redstone vermelha. Os controles são `FOOT_LIGHT_STRENGTH` e `FOOT_LIGHT_RADIUS`.

## Revisão final da iluminação

O passe da mão foi reduzido ao mínimo: apenas textura original e nenhum uniform, lightmap, sombra ou cor customizada. A iluminação de fonte segurada existe somente no terreno, como uma luz pontual na posição aproximada dos pés. A intensidade foi aumentada com limites por perfil para tornar o efeito visível sem lavar as cores.

## Iluminação neutra

A edição atual remove as cores customizadas da tela: luz dos pés, ambiente colorido, tintura da água, tonalização de chuva/clima e sombras coloridas foram desligados. Permanecem apenas sombras neutras, fog vanilla e a iluminação vanilla da mão.

## Implementação baseada em referências de BSL/Iris/OptiFine

A mão permanece vanilla. A luz segurada é calculada separadamente no terreno usando `heldItemId`, `heldItemId2`, `heldBlockLightValue` e `heldBlockLightValue2`. A contribuição é pontual, centrada na posição aproximada dos pés em espaço de visão, com queda por distância e cor escolhida pela mão de maior intensidade. Nenhuma cor é aplicada ao passe da mão ou como filtro global da tela.

## Luz segurada neutra

A luz da fonte segurada agora é branca/neutra no terreno. A cor original da tocha fica somente na textura vanilla da mão; o shader não colore mais a cena de laranja, azul ou vermelho.

## Iluminação dinâmica removida

A luz segurada foi removida completamente. Não há mais `heldItemId`, `heldBlockLightValue`, luz nos pés ou emissão da mão. A mão usa somente o lightmap vanilla, e o terreno usa o lightmap vanilla com sombras neutras.

## Sombras responsivas

O filtro do terreno agora respeita `SHADOW_FILTER` dos perfis. Potato, Low e Balanced usam uma amostra para reduzir custo e atraso perceptível; High usa quatro amostras e resolução limitada a 1024 para evitar que o shadow map fique atrasado durante movimentos rápidos.

## Solo molhado durante a chuva

Durante a chuva, blocos opacos recebem um escurecimento discreto e um brilho especular de baixo custo, calculado com normal, direção do sol e posição da superfície. Água, folhagem e blocos emissivos são ignorados. A mão permanece vanilla.

## Poças reflexivas na chuva

Poças sutis aparecem apenas com chuva, em manchas irregulares de superfícies quase horizontais. A máscara usa posição do mundo, normal e direção do sol, com brilho especular barato. O efeito não é aplicado em água existente, folhagem ou blocos emissivos.

## Correção das poças e ondulações

A máscara agora usa a normal no espaço do mundo, então não desaparece quando a câmera inclina. As poças têm manchas mais visíveis e ondulações procedurais animadas por `frameTimeCounter`, ativadas somente pela chuva. O efeito continua restrito a superfícies horizontais e materiais não emissivos.

## Pente-fino das poças

Foi corrigida a mistura de espaços de coordenadas: a máscara usa normal do mundo e o reflexo usa normal de visão, compatível com `sunPosition`/`viewDir`. A mancha foi reforçada, o limiar foi ampliado e as ondulações ficaram mais visíveis. O custo continua restrito ao branch de chuva, com uma função de ruído e uma onda procedural, sem novo buffer ou amostras de tela.
