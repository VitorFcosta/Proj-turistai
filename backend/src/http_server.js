import { createServer } from 'node:http';

import { handleRecommendationsRequest } from './recommendations.js';

export function createTouristAiServer() {
  return createServer(async (req, res) => {
    if (req.url !== '/api/recommendations') {
      sendJson(res, 404, {
        error: 'not_found',
        message: 'Rota nao encontrada.',
      });
      return;
    }

    const body = await readJsonBody(req);
    const result = await handleRecommendationsRequest({
      method: req.method,
      body,
    });

    sendJson(res, result.statusCode, result.body);
  });
}

function sendJson(res, statusCode, body) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
  });
  res.end(JSON.stringify(body));
}

async function readJsonBody(req) {
  if (req.method !== 'POST') {
    return {};
  }

  let rawBody = '';
  for await (const chunk of req) {
    rawBody += chunk;
  }

  if (rawBody.trim() === '') {
    return {};
  }

  try {
    return JSON.parse(rawBody);
  } catch {
    return {};
  }
}
