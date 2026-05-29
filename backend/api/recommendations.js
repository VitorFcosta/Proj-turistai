import { handleRecommendationsRequest } from '../src/recommendations.js';

export default async function handler(req, res) {
  const result = await handleRecommendationsRequest({
    method: req.method,
    body: req.body,
  });

  res.status(result.statusCode).json(result.body);
}
