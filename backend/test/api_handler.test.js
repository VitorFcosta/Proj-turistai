import assert from 'node:assert/strict';
import test from 'node:test';

import handler from '../api/recommendations.js';

test('Vercel handler returns JSON response', async () => {
  const restoreGeminiApiKey = temporarilyUnsetGeminiApiKey();
  const response = createMockResponse();

  try {
    await handler(
      {
        method: 'POST',
        body: {
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
        },
      },
      response,
    );
  } finally {
    restoreGeminiApiKey();
  }

  assert.equal(response.statusCode, 200);
  assert.equal(response.body.recommendations[0].placeName, 'Museu Exemplo');
});

function temporarilyUnsetGeminiApiKey() {
  const previousApiKey = process.env.GEMINI_API_KEY;
  delete process.env.GEMINI_API_KEY;

  return () => {
    if (previousApiKey === undefined) {
      delete process.env.GEMINI_API_KEY;
      return;
    }

    process.env.GEMINI_API_KEY = previousApiKey;
  };
}

function createMockResponse() {
  return {
    statusCode: undefined,
    body: undefined,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.body = payload;
      return this;
    },
  };
}
