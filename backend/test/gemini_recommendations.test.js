import assert from 'node:assert/strict';
import test from 'node:test';

import {
  GeminiRecommendationError,
  generateGeminiRecommendation,
} from '../src/gemini_recommendations.js';

test('requests structured recommendations from Gemini REST API', async () => {
  let requestUrl;
  let requestOptions;

  const result = await generateGeminiRecommendation({
    payload: validPayload(),
    apiKey: 'test-key',
    fetchImpl: async (url, options) => {
      requestUrl = url;
      requestOptions = options;

      return {
        ok: true,
        status: 200,
        json: async () => ({
          candidates: [
            {
              content: {
                parts: [
                  {
                    text: JSON.stringify({
                      title: 'Roteiro cultural proximo',
                      summary: 'Passeio curto com os locais enviados.',
                      recommendations: [
                        {
                          placeId: 'node-1',
                          placeName: 'Museu Exemplo',
                          suggestedOrder: 1,
                          reason: 'Fica perto e combina com cultura.',
                          tip: 'Va primeiro neste local.',
                        },
                      ],
                      generalTip: 'Confirme horarios antes de sair.',
                    }),
                  },
                ],
              },
            },
          ],
        }),
      };
    },
  });

  assert.equal(
    requestUrl,
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent',
  );
  assert.equal(requestOptions.method, 'POST');
  assert.equal(requestOptions.headers['x-goog-api-key'], 'test-key');
  assert.equal(requestOptions.headers['Content-Type'], 'application/json');

  const requestBody = JSON.parse(requestOptions.body);
  assert.equal(
    requestBody.generationConfig.responseFormat.text.mimeType,
    'APPLICATION_JSON',
  );
  assert.match(requestBody.contents[0].parts[0].text, /Museu Exemplo/);
  assert.match(requestBody.contents[0].parts[0].text, /Nao invente locais/);

  assert.equal(result.title, 'Roteiro cultural proximo');
  assert.equal(result.recommendations[0].placeName, 'Museu Exemplo');
});

test('throws a typed error when Gemini returns non-success status', async () => {
  await assert.rejects(
    generateGeminiRecommendation({
      payload: validPayload(),
      apiKey: 'test-key',
      fetchImpl: async () => ({
        ok: false,
        status: 503,
        json: async () => ({}),
      }),
    }),
    GeminiRecommendationError,
  );
});

test('throws a typed error when Gemini returns invalid JSON text', async () => {
  await assert.rejects(
    generateGeminiRecommendation({
      payload: validPayload(),
      apiKey: 'test-key',
      fetchImpl: async () => ({
        ok: true,
        status: 200,
        json: async () => ({
          candidates: [
            {
              content: {
                parts: [{ text: 'nao e json' }],
              },
            },
          ],
        }),
      }),
    }),
    GeminiRecommendationError,
  );
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
