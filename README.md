# TouristAI

TouristAI e um aplicativo mobile academico que usa geolocalizacao e inteligencia artificial para sugerir pontos de interesse proximos ao usuario.

O objetivo do projeto e atender a atividade de desenvolvimento de um app mobile com:

- mapa na interface;
- uso real de geolocalizacao;
- beneficio pratico baseado na posicao do usuario;
- consumo de uma API com IA;
- demonstracao funcionando em smartphone Android no dia 10/06/2026.

## Mapa geral das pastas

```text
Proj-turistai/
├── backend/       # API Node local/Vercel que chama a Gemini
├── mobile/        # Aplicativo Flutter Android
├── docs/          # Documentacao academica e tecnica
└── README.md
```

Documentos principais:

```text
docs/
├── API_CONTRATO.md
├── ARQUITETURA.md
├── PLANO_IMPLEMENTACAO.md
├── ROTEIRO_APRESENTACAO.md
├── TESTES_MANUAIS.md
└── TRABALHO_ACADEMICO.md
```

Estrutura principal do backend:

```text
backend/
├── api/
│   └── recommendations.js
├── src/
│   ├── gemini_recommendations.js
│   ├── http_server.js
│   └── recommendations.js
├── test/
└── package.json
```

Estrutura principal do app:

```text
mobile/
├── android/
├── lib/
│   ├── main.dart
│   └── services/
├── test/
└── pubspec.yaml
```

## Documentos principais

- [Trabalho academico](docs/TRABALHO_ACADEMICO.md)
- [Arquitetura](docs/ARQUITETURA.md)
- [Contrato da API](docs/API_CONTRATO.md)
- [Plano de implementacao](docs/PLANO_IMPLEMENTACAO.md)
- [Roteiro de apresentacao](docs/ROTEIRO_APRESENTACAO.md)
- [Testes manuais](docs/TESTES_MANUAIS.md)

## Como rodar

### Backend local

Sem chave da Gemini, o backend roda com recomendacao mock. Isso e util para testar o fluxo sem depender da IA:

```bash
cd backend
npm install
npm run dev
```

Com Gemini real, configure a chave apenas como variavel de ambiente do terminal:

```bash
cd backend
GEMINI_API_KEY="SUA_CHAVE_AQUI" npm run dev
```

Opcionalmente, e possivel trocar o modelo:

```bash
GEMINI_MODEL="gemini-3.5-flash" GEMINI_API_KEY="SUA_CHAVE_AQUI" npm run dev
```

### App Flutter

Em outro terminal:

```bash
cd mobile
flutter pub get
flutter run --dart-define=TOURISTAI_API_BASE_URL=http://SEU_IP_LOCAL:3000
```

Exemplo:

```bash
cd mobile
flutter run --dart-define=TOURISTAI_API_BASE_URL=http://192.168.0.101:3000
```

### Backend na Vercel

Para a apresentacao, o ideal e publicar o backend. Assim o app no celular nao depende do Mac ligado na mesma rede Wi-Fi.

Dentro da pasta `backend`, faca o deploy:

```bash
cd backend
vercel
```

Na Vercel, configure a variavel de ambiente:

```text
GEMINI_API_KEY
```

Depois de configurar a variavel, gere um deploy de producao:

```bash
vercel --prod
```

Com a URL publica da Vercel, rode o app apontando para ela:

```bash
cd mobile
flutter run --dart-define=TOURISTAI_API_BASE_URL=https://sua-url-da-vercel.vercel.app
```

Para gerar APK:

```bash
cd mobile
flutter build apk --release
```

## Testes

Backend:

```bash
cd backend
npm test
```

Flutter:

```bash
cd mobile
flutter test
flutter analyze
```

## O que o app faz hoje

- solicita permissao de localizacao;
- mostra latitude e longitude atuais;
- busca locais proximos no OpenStreetMap/Overpass;
- permite escolher categoria, tempo, orcamento, deslocamento e raio de busca;
- mostra mapa com a posicao do usuario e marcadores dos locais encontrados;
- envia localizacao, preferencias e locais para o backend;
- usa Gemini API quando `GEMINI_API_KEY` esta configurada;
- usa resposta mock quando a chave nao esta configurada.

## Ideia do app

O usuario abre o app, permite o acesso a localizacao, escolhe preferencias de passeio e recebe sugestoes personalizadas de locais proximos.

Exemplo de preferencias:

- categoria: comida, cultura, natureza, estudo ou turismo;
- tempo disponivel: 30 minutos, 1 hora ou 2 horas;
- orcamento: gratis, baixo ou medio;
- deslocamento: a pe ou carro.

Com esses dados, o app:

1. pega a latitude e longitude atuais do usuario;
2. exibe um mapa com a posicao atual;
3. busca pontos de interesse proximos usando OpenStreetMap/Overpass;
4. envia localizacao, preferencias e locais encontrados para uma API;
5. a API chama a Gemini API;
6. o app mostra recomendacoes claras para o usuario.

## Stack definida

- Mobile: Flutter
- Plataforma de demonstracao: Android
- Geolocalizacao: `geolocator`
- Mapa: `flutter_map` com OpenStreetMap
- Coordenadas: `latlong2`
- Requisicoes HTTP: `http`
- Backend: Node.js em Vercel Functions
- IA: Gemini API
- Fonte de locais: OpenStreetMap/Overpass ao vivo

## Por que Flutter

Flutter foi escolhido porque o grupo ja teve contato basico com a tecnologia e porque o uso de OpenStreetMap com `flutter_map` e direto para um app academico.

React Native tambem seria possivel, principalmente se o grupo tivesse mais experiencia com React. Porem, para o escopo escolhido, Flutter reduz o risco tecnico do mapa com OpenStreetMap e da geracao de APK para Android.

## Cuidados importantes

- Nao colocar chave da Gemini API dentro do app Flutter.
- Nao versionar arquivos `.env`.
- Nao depender de login, banco de dados ou funcionalidades extras para a apresentacao.
- Testar no smartphone Android fisico antes da entrega.
- Testar tambem com internet movel, nao apenas no Wi-Fi.

## Referencias tecnicas

- Flutter: https://docs.flutter.dev/
- geolocator: https://pub.dev/packages/geolocator
- flutter_map: https://pub.dev/packages/flutter_map
- Vercel Functions: https://vercel.com/docs/functions
- Gemini API: https://ai.google.dev/gemini-api/docs
