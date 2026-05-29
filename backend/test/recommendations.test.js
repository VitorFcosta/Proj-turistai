import assert from 'node:assert/strict';
import test from 'node:test';

import {
  buildRecommendationResponse,
  handleRecommendationsRequest,
} from '../src/recommendations.js';

test('builds mock recommendations from valid location, preferences and places', () => {
  const result = buildRecommendationResponse({
    location: {
      latitude: -23.55052,
      longitude: -46.633308,
      radiusMeters: 1500,
    },
    preferences: {
      category: 'cultura',
      availableMinutes: 60,
      budget: 'baixo',
      transportMode: 'a_pe',
    },
    places: [
      {
        id: 'node-2',
        name: 'Centro Cultural B',
        type: 'museum',
        latitude: -23.552,
        longitude: -46.635,
        distanceMeters: 900,
      },
      {
        id: 'node-1',
        name: 'Museu Exemplo',
        type: 'museum',
        latitude: -23.551,
        longitude: -46.634,
        distanceMeters: 350,
      },
    ],
  });

  assert.equal(result.statusCode, 200);
  assert.equal(result.body.title, 'Roteiro cultural proximo');
  assert.equal(result.body.recommendations.length, 2);
  assert.equal(result.body.recommendations[0].placeId, 'node-1');
  assert.equal(result.body.recommendations[0].placeName, 'Museu Exemplo');
  assert.match(result.body.summary, /1 hora/);
  assert.match(result.body.generalTip, /horario/i);
});

test('returns 400 when request has no places', () => {
  const result = buildRecommendationResponse({
    location: {
      latitude: -23.55052,
      longitude: -46.633308,
      radiusMeters: 1500,
    },
    preferences: {
      category: 'cultura',
      availableMinutes: 60,
      budget: 'baixo',
      transportMode: 'a_pe',
    },
    places: [],
  });

  assert.equal(result.statusCode, 400);
  assert.deepEqual(result.body, {
    error: 'invalid_request',
    message: 'Informe localizacao, preferencias e pelo menos um local encontrado.',
  });
});

test('handler rejects methods other than POST', async () => {
  const response = await handleRecommendationsRequest({
    method: 'GET',
    body: {},
  });

  assert.equal(response.statusCode, 405);
  assert.deepEqual(response.body, {
    error: 'method_not_allowed',
    message: 'Use POST para gerar recomendacoes.',
  });
});

test('handler uses Gemini when API key is configured', async () => {
  const response = await handleRecommendationsRequest(
    {
      method: 'POST',
      body: validPayload(),
    },
    {
      geminiApiKey: 'test-key',
      generateGeminiRecommendation: async ({ payload, apiKey }) => {
        assert.equal(apiKey, 'test-key');
        assert.equal(payload.preferences.category, 'cultura');

        return {
          title: 'Roteiro gerado pela Gemini',
          summary: 'Sugestao baseada nos locais enviados.',
          recommendations: [
            {
              placeId: 'node-1',
              placeName: 'Museu Exemplo',
              suggestedOrder: 1,
              reason: 'Combina com o perfil informado.',
              tip: 'Comece por este local.',
            },
          ],
          generalTip: 'Confira as condicoes do local antes de sair.',
        };
      },
    },
  );

  assert.equal(response.statusCode, 200);
  assert.equal(response.body.title, 'Roteiro gerado pela Gemini');
});

test('handler returns 502 when Gemini fails', async () => {
  const response = await handleRecommendationsRequest(
    {
      method: 'POST',
      body: validPayload(),
    },
    {
      geminiApiKey: 'test-key',
      generateGeminiRecommendation: async () => {
        throw new Error('Gemini unavailable');
      },
    },
  );

  assert.equal(response.statusCode, 502);
  assert.deepEqual(response.body, {
    error: 'ai_provider_error',
    message:
      'Nao foi possivel gerar recomendacoes agora. Tente novamente em alguns instantes.',
  });
});

function validPayload() {
  return {
    location: {
      latitude: -23.55052,
      longitude: -46.633308,
      radiusMeters: 1500,
    },
    preferences: {
      category: 'cultura',
      availableMinutes: 60,
      budget: 'baixo',
      transportMode: 'a_pe',
    },
    places: [
      {
        id: 'node-1',
        name: 'Museu Exemplo',
        type: 'museum',
        latitude: -23.551,
        longitude: -46.634,
        distanceMeters: 350,
      },
    ],
  };
}
