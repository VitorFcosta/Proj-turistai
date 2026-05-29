# Plano de Implementacao do TouristAI

## 1. Objetivo

Criar um app Flutter para Android que usa GPS, mapa, OpenStreetMap e Gemini API para recomendar locais proximos ao usuario.

Este plano esta em ordem pratica. A ideia e fazer uma parte pequena funcionar antes de passar para a proxima.

## 2. Estrutura prevista

```text
Proj-turistai/
├── backend/
│   ├── api/
│   │   └── recommendations.js
│   ├── package.json
│   └── vercel.json
├── mobile/
│   ├── android/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── pubspec.yaml
│   └── test/
├── docs/
└── README.md
```

## 3. Fase 1 - Preparar o projeto Flutter

### 3.1 Criar o app

Comando previsto:

```bash
flutter create mobile
```

Depois:

```bash
cd mobile
flutter run
```

Resultado esperado:

- app padrao do Flutter abre no emulador ou celular;
- ambiente Flutter esta funcionando.

### 3.2 Adicionar dependencias

Dependencias previstas no `pubspec.yaml`:

- `geolocator`: acessar GPS;
- `flutter_map`: exibir mapa;
- `latlong2`: trabalhar com coordenadas;
- `http`: chamar APIs;
- `provider` ou `setState`: controle simples de estado.

Recomendacao: comecar com `setState`. Para esse trabalho, adicionar arquitetura complexa cedo demais atrapalha.

### 3.3 Criar telas iniciais

Telas previstas:

- `HomeScreen`: formulario de preferencias;
- `MapScreen`: mapa, marcadores e botao de recomendacao;
- `RecommendationPanel`: area ou componente para mostrar resposta da IA.

Critico: nao gastar tempo com tela bonita antes do fluxo funcionar. Primeiro funcionar, depois melhorar visual.

## 4. Fase 2 - Geolocalizacao

### 4.1 Configurar permissoes Android

No Android, sera necessario permitir localizacao no manifesto do app.

Permissoes esperadas:

- localizacao aproximada;
- localizacao precisa.

### 4.2 Criar servico de localizacao

Arquivo previsto:

```text
mobile/lib/services/location_service.dart
```

Responsabilidades:

- verificar se o GPS esta ativo;
- pedir permissao;
- retornar latitude e longitude;
- retornar erro amigavel quando o usuario negar permissao.

### 4.3 Testar no celular fisico

Comando:

```bash
flutter run
```

Teste:

- abrir app;
- permitir localizacao;
- confirmar que latitude e longitude aparecem no log ou na tela temporaria.

## 5. Fase 3 - Mapa

### 5.1 Exibir mapa

Usar `flutter_map` para mostrar OpenStreetMap.

Resultado esperado:

- mapa abre na tela;
- centro do mapa fica na localizacao do usuario.

### 5.2 Mostrar marcador do usuario

Adicionar um marcador visual para a posicao atual.

Resultado esperado:

- usuario entende onde esta no mapa;
- mapa nao fica em uma regiao aleatoria.

## 6. Fase 4 - Busca de locais no OpenStreetMap/Overpass

### 6.1 Criar servico de locais

Arquivo previsto:

```text
mobile/lib/services/places_service.dart
```

Responsabilidades:

- receber latitude, longitude, raio e categoria;
- montar consulta Overpass;
- chamar a API Overpass;
- converter resposta em lista de locais;
- calcular ou guardar distancia aproximada;
- limitar a quantidade de locais enviados para a IA.

### 6.2 Categorias iniciais

Categorias do app e exemplos de busca:

- comida: restaurantes, cafes, fast food;
- cultura: museus, teatros, galerias;
- natureza: parques, pracas, jardins;
- estudo: bibliotecas, universidades;
- turismo: atracoes, monumentos, pontos turisticos.

### 6.3 Tratar busca vazia

Se nao encontrar locais:

- mostrar mensagem clara;
- sugerir aumentar raio;
- sugerir trocar categoria.

Como o grupo decidiu nao usar fallback local, esse tratamento e obrigatorio para nao parecer que o app quebrou.

## 7. Fase 5 - Backend Vercel

### 7.1 Criar projeto backend

Estrutura prevista:

```text
backend/
├── api/
│   └── recommendations.js
├── package.json
└── vercel.json
```

### 7.2 Criar endpoint

Endpoint:

```text
POST /api/recommendations
```

Responsabilidades:

- aceitar JSON do app;
- validar campos obrigatorios;
- chamar Gemini API;
- retornar JSON padronizado.

### 7.3 Configurar variavel de ambiente

Na Vercel:

```text
GEMINI_API_KEY
```

Nao criar arquivo `.env` versionado.

Para teste local, se for necessario usar `.env.local`, esse arquivo deve ficar fora do Git.

## 8. Fase 6 - Integracao com Gemini API

### 8.1 Montar prompt

O prompt deve deixar claro:

- usar apenas os locais enviados;
- nao inventar lugares;
- considerar tempo, orcamento, categoria e deslocamento;
- responder em JSON.

### 8.2 Validar resposta

O backend deve conferir se a resposta possui:

- titulo;
- resumo;
- lista de recomendacoes;
- dica geral.

Se a IA responder em formato invalido, retornar erro amigavel ao app.

## 9. Fase 7 - Integrar app com backend

### 9.1 Criar servico da API

Arquivo previsto:

```text
mobile/lib/services/recommendation_service.dart
```

Responsabilidades:

- receber preferencias, localizacao e locais;
- chamar `POST /api/recommendations`;
- converter resposta em modelo interno;
- tratar erro de rede e erro da API.

### 9.2 Exibir recomendacoes

Na interface:

- mostrar titulo do roteiro;
- mostrar resumo;
- listar ate 3 recomendacoes;
- mostrar motivo e dica de cada local.

## 10. Fase 8 - Melhorar usabilidade

Melhorias importantes:

- botao claro para buscar locais;
- botao claro para gerar roteiro;
- indicador de carregamento;
- mensagens de erro simples;
- textos curtos;
- layout legivel em tela pequena.

Nao gastar tempo com animacoes complexas.

## 11. Fase 9 - Gerar APK

Comando:

```bash
cd mobile
flutter build apk --release
```

Arquivo esperado:

```text
mobile/build/app/outputs/flutter-apk/app-release.apk
```

Teste obrigatorio:

- instalar APK em Android fisico;
- abrir sem depender do computador;
- testar permissao de GPS;
- testar chamada da API publicada.

## 12. Fase 10 - Ensaio da apresentacao

Antes de 10/06/2026:

- testar no local da apresentacao ou em local parecido;
- testar com internet movel;
- abrir app do zero;
- permitir localizacao;
- escolher categoria;
- mostrar mapa;
- gerar recomendacao;
- explicar os requisitos atendidos.

## 13. Ordem recomendada de trabalho

1. Criar Flutter e rodar app padrao.
2. Fazer GPS funcionar.
3. Fazer mapa abrir.
4. Mostrar marcador do usuario.
5. Buscar locais no OpenStreetMap.
6. Criar backend simples.
7. Fazer backend responder mock fixo.
8. Ligar app ao backend.
9. Trocar mock por Gemini API.
10. Exibir recomendacao no app.
11. Melhorar mensagens de erro.
12. Gerar APK.
13. Ensaiar apresentacao.

## 14. Criterio para dizer que esta pronto

O projeto so deve ser considerado pronto quando:

- estiver instalado em Android fisico;
- o app abrir sem computador;
- o mapa carregar;
- a localizacao real funcionar;
- pelo menos uma categoria encontrar locais;
- a IA gerar recomendacao;
- erros comuns tiverem mensagem amigavel;
- o grupo souber explicar o fluxo inteiro.
