const DEFAULT_GEMINI_MODEL = 'gemini-3.5-flash';
const GEMINI_API_BASE_URL = 'https://generativelanguage.googleapis.com/v1beta';

const recommendationSchema = {
  type: 'object',
  properties: {
    title: {
      type: 'string',
      description: 'Titulo curto do roteiro recomendado.',
    },
    summary: {
      type: 'string',
      description: 'Resumo curto considerando perfil e localizacao.',
    },
    recommendations: {
      type: 'array',
      maxItems: 3,
      items: {
        type: 'object',
        properties: {
          placeId: {
            type: 'string',
            description: 'ID de um local recebido na requisicao.',
          },
          placeName: {
            type: 'string',
            description: 'Nome do local recomendado.',
          },
          suggestedOrder: {
            type: 'integer',
            description: 'Ordem sugerida de visita, comecando em 1.',
          },
          reason: {
            type: 'string',
            description: 'Motivo curto da recomendacao.',
          },
          tip: {
            type: 'string',
            description: 'Dica pratica curta para o usuario.',
          },
        },
        required: ['placeId', 'placeName', 'suggestedOrder', 'reason', 'tip'],
      },
    },
    generalTip: {
      type: 'string',
      description: 'Dica geral curta para o roteiro.',
    },
  },
  required: ['title', 'summary', 'recommendations', 'generalTip'],
};

export class GeminiRecommendationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'GeminiRecommendationError';
  }
}

export async function generateGeminiRecommendation({
  payload,
  apiKey,
  model = DEFAULT_GEMINI_MODEL,
  fetchImpl = globalThis.fetch,
}) {
  if (!apiKey) {
    throw new GeminiRecommendationError('Missing Gemini API key.');
  }

  if (typeof fetchImpl !== 'function') {
    throw new GeminiRecommendationError('Fetch API is not available.');
  }

  const response = await fetchImpl(
    `${GEMINI_API_BASE_URL}/models/${model}:generateContent`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: JSON.stringify(buildGeminiRequestBody(payload)),
    },
  );

  if (!response.ok) {
    throw new GeminiRecommendationError(
      `Gemini returned status ${response.status}.`,
    );
  }

  const responseBody = await response.json();
  const text = extractGeminiText(responseBody);
  const recommendation = parseJsonText(text);

  return normalizeRecommendation(recommendation, payload.places);
}

function buildGeminiRequestBody(payload) {
  return {
    contents: [
      {
        role: 'user',
        parts: [
          {
            text: buildPrompt(payload),
          },
        ],
      },
    ],
    generationConfig: {
      responseFormat: {
        text: {
          mimeType: 'APPLICATION_JSON',
          schema: recommendationSchema,
        },
      },
    },
  };
}

function buildPrompt(payload) {
  return [
    'Voce e um assistente turistico para um app academico mobile.',
    'Use apenas os locais enviados no JSON. Nao invente locais.',
    'Gere ate 3 recomendacoes em portugues do Brasil.',
    'Considere distancia, categoria, tempo disponivel, orcamento e deslocamento.',
    'Se os dados forem limitados, explique a limitacao de forma curta.',
    'Nao prometa horario de funcionamento, pois esse dado nao foi enviado.',
    '',
    'Dados do usuario e locais encontrados:',
    JSON.stringify(payload, null, 2),
  ].join('\n');
}

function extractGeminiText(responseBody) {
  const text = responseBody
    ?.candidates
    ?.[0]
    ?.content
    ?.parts
    ?.[0]
    ?.text;

  if (typeof text !== 'string' || text.trim() === '') {
    throw new GeminiRecommendationError('Gemini response has no text.');
  }

  return text;
}

function parseJsonText(text) {
  const cleanedText = text
    .trim()
    .replace(/^```json\s*/i, '')
    .replace(/^```\s*/i, '')
    .replace(/\s*```$/i, '');

  try {
    return JSON.parse(cleanedText);
  } catch {
    throw new GeminiRecommendationError('Gemini response is not valid JSON.');
  }
}

function normalizeRecommendation(recommendation, places) {
  if (!isObject(recommendation)) {
    throw new GeminiRecommendationError('Gemini response is not an object.');
  }

  const allowedPlaceIds = new Set(places.map((place) => place.id));
  const items = recommendation.recommendations;
  if (!Array.isArray(items) || items.length === 0) {
    throw new GeminiRecommendationError('Gemini response has no places.');
  }

  return {
    title: readString(recommendation, 'title'),
    summary: readString(recommendation, 'summary'),
    recommendations: items.slice(0, 3).map((item) => {
      if (!isObject(item)) {
        throw new GeminiRecommendationError('Invalid recommendation item.');
      }

      const placeId = readString(item, 'placeId');
      if (!allowedPlaceIds.has(placeId)) {
        throw new GeminiRecommendationError('Gemini recommended unknown place.');
      }

      return {
        placeId,
        placeName: readString(item, 'placeName'),
        suggestedOrder: readInteger(item, 'suggestedOrder'),
        reason: readString(item, 'reason'),
        tip: readString(item, 'tip'),
      };
    }),
    generalTip: readString(recommendation, 'generalTip'),
  };
}

function isObject(value) {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function readString(source, key) {
  const value = source[key];
  if (typeof value === 'string' && value.trim() !== '') {
    return value;
  }

  throw new GeminiRecommendationError(`Missing string field: ${key}.`);
}

function readInteger(source, key) {
  const value = source[key];
  if (Number.isInteger(value)) {
    return value;
  }

  throw new GeminiRecommendationError(`Missing integer field: ${key}.`);
}
