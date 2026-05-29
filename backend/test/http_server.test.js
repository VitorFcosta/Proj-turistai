import assert from 'node:assert/strict';
import test from 'node:test';

import { createTouristAiServer } from '../src/http_server.js';

test('local server responds to POST /api/recommendations', async () => {
  const restoreGeminiApiKey = temporarilyUnsetGeminiApiKey();
  const server = createTouristAiServer();
  await listen(server);

  let response;
  let body;
  try {
    const { port } = server.address();
    response = await fetch(`http://127.0.0.1:${port}/api/recommendations`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
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
      }),
    });
    body = await response.json();
  } finally {
    server.close();
    restoreGeminiApiKey();
  }

  assert.equal(response.status, 200);
  assert.equal(body.recommendations[0].placeName, 'Museu Exemplo');
});

test('local server returns 404 for unknown route', async () => {
  const server = createTouristAiServer();
  await listen(server);

  const { port } = server.address();
  const response = await fetch(`http://127.0.0.1:${port}/unknown`);
  const body = await response.json();
  server.close();

  assert.equal(response.status, 404);
  assert.deepEqual(body, {
    error: 'not_found',
    message: 'Rota nao encontrada.',
  });
});

function listen(server) {
  return new Promise((resolve) => {
    server.listen(0, '127.0.0.1', resolve);
  });
}

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
