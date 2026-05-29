# TouristAI - Documentacao Academica

## 1. Identificacao do projeto

**Nome do aplicativo:** TouristAI

**Tipo de aplicacao:** aplicativo mobile com geolocalizacao e inteligencia artificial.

**Plataforma de apresentacao:** Android.

**Data da apresentacao:** 10/06/2026.

## 2. Problema

Pessoas que estao em uma regiao desconhecida muitas vezes nao sabem quais locais proximos valem a pena visitar. Mesmo com mapas comuns, o usuario ainda precisa pesquisar, comparar opcoes, entender distancias e decidir sozinho.

O TouristAI resolve esse problema sugerindo lugares proximos com base na localizacao atual e nas preferencias informadas pelo usuario.

## 3. Solucao proposta

O aplicativo usa o GPS do celular para obter a localizacao atual do usuario. Em seguida, exibe um mapa e busca pontos de interesse proximos usando dados do OpenStreetMap.

Depois disso, o usuario informa preferencias simples, como categoria de passeio, tempo disponivel, orcamento e modo de deslocamento. Esses dados sao enviados para uma API propria, que consulta a Gemini API e retorna recomendacoes personalizadas.

A resposta da IA e exibida no app de forma objetiva, com:

- locais recomendados;
- justificativa da recomendacao;
- ordem sugerida de visita;
- dicas praticas para o usuario.

## 4. Publico-alvo

O publico-alvo sao pessoas que querem descobrir locais proximos de forma rapida, principalmente turistas, estudantes, visitantes de uma cidade ou pessoas que estao explorando uma regiao nova.

## 5. Uso de geolocalizacao

A geolocalizacao nao sera usada apenas para mostrar um mapa. Ela tera papel central no funcionamento do app.

O aplicativo usara latitude e longitude para:

- centralizar o mapa na posicao real do usuario;
- buscar pontos de interesse em um raio proximo;
- calcular quais locais fazem sentido para a regiao atual;
- enviar contexto geografico para a IA;
- gerar sugestoes que mudam conforme o local onde o usuario esta.

Isso gera valor pratico porque as recomendacoes dependem diretamente da posicao real do usuario.

## 6. Mapa na interface

O mapa sera exibido dentro do aplicativo e mostrara:

- posicao aproximada do usuario;
- marcadores dos pontos de interesse encontrados;
- relacao visual entre o usuario e os locais recomendados.

O mapa sera construido com Flutter usando a biblioteca `flutter_map` e tiles do OpenStreetMap.

## 7. Uso de inteligencia artificial

A inteligencia artificial sera consumida por meio de uma API. O app Flutter nao chamara a Gemini API diretamente. Em vez disso, ele chamara um backend hospedado na Vercel.

Fluxo:

1. usuario informa preferencias;
2. app coleta a localizacao atual;
3. app busca locais proximos;
4. app envia dados para o backend;
5. backend chama a Gemini API;
6. backend retorna recomendacoes para o app;
7. app mostra o resultado ao usuario.

A IA sera usada para transformar uma lista de locais em uma recomendacao personalizada, considerando contexto, preferencia e utilidade para o usuario.

## 8. Dados fornecidos pelo usuario

O usuario devera preencher informacoes simples:

- categoria desejada: comida, cultura, natureza, estudo ou turismo;
- tempo disponivel: 30 minutos, 1 hora ou 2 horas;
- orcamento: gratis, baixo ou medio;
- forma de deslocamento: a pe ou carro.

Esses dados tornam a resposta da IA mais util. Por exemplo, um usuario com pouco tempo e deslocamento a pe deve receber recomendacoes mais proximas.

## 9. Criterios de avaliacao

### 9.1 Responsividade e usabilidade - 2,5 pontos

O app sera projetado com telas simples:

- uma tela para preferencias;
- uma tela com mapa;
- uma area clara para recomendacoes.

A interface deve ser facil de demonstrar no smartphone, com botoes visiveis, textos curtos e feedback de carregamento.

### 9.2 Uso de geolocalizacao - 2,5 pontos

O app usara GPS real do celular, exibira mapa e buscara locais proximos a partir da posicao atual. A geolocalizacao sera parte essencial da recomendacao, nao apenas um detalhe visual.

### 9.3 Integracao com API de IA - 2,5 pontos

O app chamara um backend proprio. Esse backend chamara a Gemini API e retornara uma resposta personalizada com base em:

- localizacao;
- preferencias do usuario;
- lista de locais proximos.

### 9.4 Funcionamento geral - 2,5 pontos

O app devera funcionar em Android fisico, com tratamento para:

- permissao de localizacao negada;
- falha ao carregar mapa;
- falha ao buscar locais;
- falha na resposta da IA.

## 10. Escopo da primeira versao

Funcionalidades dentro do escopo:

- localizar usuario via GPS;
- mostrar mapa;
- buscar locais proximos;
- coletar preferencias;
- gerar recomendacoes com IA;
- exibir resultado no app;
- gerar APK para Android.

Funcionalidades fora do escopo:

- login;
- cadastro de usuario;
- favoritos;
- historico;
- banco de dados;
- pagamento;
- chat completo;
- rotas com transito em tempo real;
- notificacoes por proximidade.

Essa decisao foi tomada para reduzir risco e garantir uma apresentacao funcional.

## 11. Riscos conhecidos

O principal risco e depender do OpenStreetMap/Overpass ao vivo. Se a internet estiver ruim ou a API retornar poucos dados, o app pode nao encontrar locais suficientes.

Como o grupo decidiu nao usar uma lista local de fallback, o app devera pelo menos mostrar mensagens claras quando nao encontrar resultados.

Outro risco e expor a chave da Gemini API. Para evitar isso, a chave ficara somente no backend, dentro das variaveis de ambiente da Vercel.

## 12. Conclusao

O TouristAI atende aos requisitos do trabalho porque combina mapa, geolocalizacao real e uma API de inteligencia artificial para gerar recomendacoes uteis. O foco do projeto e demonstrar um fluxo simples, funcional e claro no smartphone, em vez de tentar criar muitas funcionalidades incompletas.
