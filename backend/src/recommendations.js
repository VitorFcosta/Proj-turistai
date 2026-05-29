import { generateGeminiRecommendation } from './gemini_recommendations.js';

const invalidRequest = {
  statusCode: 400,
  body: {
    error: 'invalid_request',
    message: 'Informe localizacao, preferencias e pelo menos um local encontrado.',
  },
};

export function buildRecommendationResponse(payload) {
  if (!isValidPayload(payload)) {
    return invalidRequest;
  }

  const places = [...payload.places]
    .sort((left, right) => left.distanceMeters - right.distanceMeters)
    .slice(0, 3);

  return {
    statusCode: 200,
    body: {
      title: titleForCategory(payload.preferences.category),
      summary: summaryForPreferences(payload.preferences),
      recommendations: places.map((place, index) => ({
        placeId: place.id,
        placeName: place.name,
        suggestedOrder: index + 1,
        reason: `${place.name} combina com a categoria escolhida e fica a cerca de ${Math.round(place.distanceMeters)} metros.`,
        tip: index === 0
          ? 'Comece por este local por ser o mais proximo.'
          : 'Visite depois se ainda tiver tempo disponivel.',
      })),
      generalTip: 'Confira o horario de funcionamento antes de sair.',
    },
  };
}

export async function handleRecommendationsRequest(request, options = {}) {
  if (request.method !== 'POST') {
    return {
      statusCode: 405,
      body: {
        error: 'method_not_allowed',
        message: 'Use POST para gerar recomendacoes.',
      },
    };
  }

  const fallbackResponse = buildRecommendationResponse(request.body);
  if (fallbackResponse.statusCode !== 200) {
    return fallbackResponse;
  }

  const geminiApiKey = options.geminiApiKey ?? process.env.GEMINI_API_KEY;
  if (!geminiApiKey) {
    return fallbackResponse;
  }

  const geminiGenerator =
    options.generateGeminiRecommendation ?? generateGeminiRecommendation;

  try {
    const body = await geminiGenerator({
      payload: request.body,
      apiKey: geminiApiKey,
      model: options.geminiModel ?? process.env.GEMINI_MODEL,
      fetchImpl: options.fetchImpl,
    });

    return {
      statusCode: 200,
      body,
    };
  } catch {
    return {
      statusCode: 502,
      body: {
        error: 'ai_provider_error',
        message:
          'Nao foi possivel gerar recomendacoes agora. Tente novamente em alguns instantes.',
      },
    };
  }
}

function isValidPayload(payload) {
  return Boolean(
    payload &&
      isValidLocation(payload.location) &&
      isValidPreferences(payload.preferences) &&
      Array.isArray(payload.places) &&
      payload.places.length > 0 &&
      payload.places.every(isValidPlace),
  );
}

function isValidLocation(location) {
  return Boolean(
    location &&
      Number.isFinite(location.latitude) &&
      Number.isFinite(location.longitude) &&
      Number.isFinite(location.radiusMeters),
  );
}

function isValidPreferences(preferences) {
  return Boolean(
    preferences &&
      typeof preferences.category === 'string' &&
      Number.isFinite(preferences.availableMinutes) &&
      typeof preferences.budget === 'string' &&
      typeof preferences.transportMode === 'string',
  );
}

function isValidPlace(place) {
  return Boolean(
    place &&
      typeof place.id === 'string' &&
      typeof place.name === 'string' &&
      typeof place.type === 'string' &&
      Number.isFinite(place.latitude) &&
      Number.isFinite(place.longitude) &&
      Number.isFinite(place.distanceMeters),
  );
}

function titleForCategory(category) {
  const titles = {
    comida: 'Roteiro gastronomico proximo',
    cultura: 'Roteiro cultural proximo',
    natureza: 'Roteiro ao ar livre proximo',
    estudo: 'Roteiro de estudo proximo',
    turismo: 'Roteiro turistico proximo',
  };

  return titles[category] ?? 'Roteiro personalizado proximo';
}

function summaryForPreferences(preferences) {
  const timeLabel = preferences.availableMinutes === 60
    ? '1 hora'
    : `${preferences.availableMinutes} minutos`;

  return `Sugestao para ${timeLabel}, com orcamento ${preferences.budget} e deslocamento ${preferences.transportMode}.`;
}
