# Arquitetura do TouristAI

## 1. Visao geral

O TouristAI tera duas partes principais:

- **Aplicativo mobile:** feito em Flutter, instalado em um smartphone Android.
- **Backend:** API Node.js hospedada na Vercel, responsavel por chamar a Gemini API com seguranca.

Separar app e backend e importante porque a chave da IA nao deve ficar dentro do aplicativo. Um app instalado no celular pode ser analisado por terceiros, entao qualquer chave embutida nele estaria exposta.

## 2. Fluxo principal

```text
Usuario
  |
  v
App Flutter
  |
  |-- pega GPS com geolocator
  |-- mostra mapa com flutter_map
  |-- busca locais no OpenStreetMap/Overpass
  |
  v
Backend Vercel
  |
  |-- monta prompt com localizacao, preferencias e locais
  |-- chama Gemini API
  |
  v
App Flutter
  |
  |-- exibe recomendacoes
  v
Usuario
```

## 3. Responsabilidades do app Flutter

O app mobile sera responsavel por:

- pedir permissao de localizacao;
- obter latitude e longitude atuais;
- mostrar mapa;
- mostrar marcadores dos locais encontrados;
- coletar preferencias do usuario;
- chamar o backend;
- exibir estados de carregamento;
- exibir mensagens de erro amigaveis;
- apresentar as recomendacoes da IA.

O app nao sera responsavel por:

- guardar chave da Gemini API;
- fazer login;
- salvar historico;
- manter banco de dados;
- calcular rotas reais com transito.

## 4. Responsabilidades do backend

O backend sera responsavel por:

- receber dados do app;
- validar os campos obrigatorios;
- montar uma instrucao clara para a Gemini API;
- chamar a Gemini API;
- transformar a resposta em JSON padronizado;
- retornar erro amigavel se algo falhar.

O backend tambem protege a chave da IA, pois a variavel `GEMINI_API_KEY` ficara configurada na Vercel.

## 5. Responsabilidades do OpenStreetMap/Overpass

O OpenStreetMap/Overpass sera usado para obter pontos de interesse proximos ao usuario.

Exemplos de locais:

- restaurantes;
- cafes;
- museus;
- parques;
- pontos turisticos;
- bibliotecas;
- locais de estudo.

Como essa consulta depende de internet e disponibilidade externa, o app precisa tratar falhas sem travar.

## 6. Dados principais

### 6.1 Preferencias do usuario

```json
{
  "category": "cultura",
  "availableMinutes": 60,
  "budget": "baixo",
  "transportMode": "a_pe"
}
```

### 6.2 Localizacao

```json
{
  "latitude": -23.55052,
  "longitude": -46.633308,
  "radiusMeters": 1500
}
```

### 6.3 Local encontrado

```json
{
  "id": "osm-node-123",
  "name": "Museu Exemplo",
  "type": "museum",
  "latitude": -23.551,
  "longitude": -46.634,
  "distanceMeters": 350
}
```

### 6.4 Recomendacao da IA

```json
{
  "title": "Roteiro cultural rapido",
  "summary": "Sugestao para visitar locais proximos em cerca de 1 hora.",
  "recommendations": [
    {
      "placeName": "Museu Exemplo",
      "reason": "Fica perto e combina com interesse em cultura.",
      "suggestedOrder": 1,
      "tip": "Comece por este local porque e o mais proximo."
    }
  ]
}
```

## 7. Estados da interface

O app devera considerar os seguintes estados:

- carregando permissao de GPS;
- permissao negada;
- carregando mapa;
- carregando locais proximos;
- nenhum local encontrado;
- gerando recomendacao com IA;
- recomendacao carregada;
- erro de internet;
- erro da API.

Esses estados sao importantes porque o professor avaliara funcionamento geral e usabilidade.

## 8. Decisoes tecnicas

### Flutter

Escolhido porque o grupo ja teve contato basico e porque facilita a criacao de app Android com interface consistente.

### flutter_map

Escolhido para usar OpenStreetMap sem depender diretamente do Google Maps.

### geolocator

Escolhido para acessar GPS e lidar com permissoes de localizacao.

### Vercel Functions

Escolhida para criar uma API HTTP simples, sem precisar manter servidor proprio.

### Gemini API

Escolhida como API de IA para transformar dados de localizacao e preferencias em recomendacoes personalizadas.

## 9. Pontos de atencao

- A chave da Gemini API nunca deve ir para o app.
- Arquivos `.env` nao devem ser versionados.
- A demonstracao deve ser testada no celular real.
- O app depende de internet para mapa, Overpass e Gemini.
- Sem fallback local, a consulta ao OpenStreetMap e um risco assumido.
