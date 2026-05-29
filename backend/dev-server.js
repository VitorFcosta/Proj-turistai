import { createTouristAiServer } from './src/http_server.js';

const port = Number(process.env.PORT ?? 3000);
const host = process.env.HOST ?? '0.0.0.0';

const server = createTouristAiServer();

server.listen(port, host, () => {
  console.log(`TouristAI backend running at http://${host}:${port}`);
});
