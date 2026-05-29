# Contrato da API

## 1. Visao geral

A API do TouristAI sera responsavel por receber localizacao, preferencias do usuario e locais proximos, chamar a Gemini API e devolver uma recomendacao estruturada.

Endpoint planejado:

```text
POST /api/recommendations
```

## 2. Por que existe backend

O app Flutter nao deve chamar a Gemini API diretamente, porque isso exigiria colocar a chave da IA dentro do aplicativo.

O backend evita esse problema:

- o app chama apenas a API do projeto;
- o backend usa a chave `GEMINI_API_KEY`;
- a chave fica protegida nas variaveis de ambiente da Vercel.

## 3. Requisicao

### Metodo

```text
POST
```

### Headers

```text
Content-Type: application/json
```

### Body

```json
{
  "location": {
    "latitude": -23.55052,
    "longitude": -46.633308,
    "radiusMeters": 1500
  },
  "preferences": {
    "category": "cultura",
    "availableMinutes": 60,
    "budget": "baixo",
    "transportMode": "a_pe"
  },
  "places": [
    {
      "id": "osm-node-123",
      "name": "Museu Exemplo",
      "type": "museum",
      "latitude": -23.551,
      "longitude": -46.634,
      "distanceMeters": 350
    }
  ]
}
```

## 4. Campos da requisicao

### `location`

| Campo | Tipo | Obrigatorio | Descricao |
| --- | --- | --- | --- |
| `latitude` | number | sim | Latitude atual do usuario. |
| `longitude` | number | sim | Longitude atual do usuario. |
| `radiusMeters` | number | sim | Raio usado para buscar locais proximos. |

### `preferences`

| Campo | Tipo | Obrigatorio | Valores esperados |
| --- | --- | --- | --- |
| `category` | string | sim | `comida`, `cultura`, `natureza`, `estudo`, `turismo` |
| `availableMinutes` | number | sim | `30`, `60`, `120` |
| `budget` | string | sim | `gratis`, `baixo`, `medio` |
| `transportMode` | string | sim | `a_pe`, `carro` |

### `places`

Lista de locais encontrados pelo app usando OpenStreetMap/Overpass.

| Campo | Tipo | Obrigatorio | Descricao |
| --- | --- | --- | --- |
| `id` | string | sim | Identificador do local. |
| `name` | string | sim | Nome do local. |
| `type` | string | sim | Tipo do local. |
| `latitude` | number | sim | Latitude do local. |
| `longitude` | number | sim | Longitude do local. |
| `distanceMeters` | number | sim | Distancia aproximada ate o usuario. |

## 5. Resposta de sucesso

Status:

```text
200 OK
```

Body:

```json
{
  "title": "Roteiro cultural proximo",
  "summary": "Sugestao de passeio para aproximadamente 1 hora, priorizando locais proximos.",
  "recommendations": [
    {
      "placeId": "osm-node-123",
      "placeName": "Museu Exemplo",
      "suggestedOrder": 1,
      "reason": "Combina com a categoria cultura e fica a cerca de 350 metros.",
      "tip": "Comece por este local por ser o mais proximo."
    }
  ],
  "generalTip": "Leve em conta o horario de funcionamento dos locais antes de sair."
}
```

## 6. Respostas de erro

### 400 - requisicao invalida

Quando faltarem campos obrigatorios ou os tipos estiverem incorretos.

```json
{
  "error": "invalid_request",
  "message": "Informe localizacao, preferencias e pelo menos um local encontrado."
}
```

### 502 - falha na IA

Quando o backend nao conseguir obter resposta valida da Gemini API.

```json
{
  "error": "ai_provider_error",
  "message": "Nao foi possivel gerar recomendacoes agora. Tente novamente em alguns instantes."
}
```

### 500 - erro inesperado

Quando ocorrer uma falha nao prevista no backend.

```json
{
  "error": "internal_error",
  "message": "Erro interno ao processar recomendacoes."
}
```

## 7. Regras de negocio

- A API deve recomendar no maximo 3 locais.
- A resposta deve ser curta o suficiente para caber bem na tela do celular.
- A IA deve considerar distancia, categoria, tempo disponivel, orcamento e deslocamento.
- Se houver poucos locais, a IA deve explicar a limitacao em vez de inventar locais.
- A IA nao deve prometer horarios de funcionamento se esses dados nao forem enviados.

## 8. Exemplo de prompt para a IA

O backend deve montar uma instrucao com este objetivo:

```text
Voce e um assistente turistico. Use apenas os locais enviados pelo sistema.
Gere ate 3 recomendacoes para o usuario, considerando localizacao, categoria,
tempo disponivel, orcamento e forma de deslocamento.
Nao invente locais. Responda em JSON seguindo o formato pedido.
```

## 9. Seguranca

- Nunca enviar `GEMINI_API_KEY` para o app.
- Configurar `GEMINI_API_KEY` nas variaveis de ambiente da Vercel.
- Nao registrar dados sensiveis em logs.
- Validar entrada antes de chamar a IA.
