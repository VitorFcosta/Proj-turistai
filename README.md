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
├── README.md
└── docs/
    ├── API_CONTRATO.md
    ├── ARQUITETURA.md
    ├── PLANO_IMPLEMENTACAO.md
    ├── ROTEIRO_APRESENTACAO.md
    ├── TESTES_MANUAIS.md
    └── TRABALHO_ACADEMICO.md
```

Quando a implementacao comecar, a estrutura prevista sera:

```text
Proj-turistai/
├── backend/       # API Node hospedada na Vercel
├── mobile/        # Aplicativo Flutter
├── docs/          # Documentacao academica e tecnica
└── README.md
```

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

## Como rodar futuramente

O projeto ainda esta na fase de documentacao e planejamento. Quando a implementacao comecar, os comandos esperados serao:

```bash
cd backend
npm install
npm run dev
```

```bash
cd mobile
flutter pub get
flutter run
```

Para gerar APK:

```bash
cd mobile
flutter build apk --release
```

## Cuidados importantes

- Nao colocar chave da Gemini API dentro do app Flutter.
- Nao versionar arquivos `.env`.
- Nao depender de login, banco de dados ou funcionalidades extras para a apresentacao.
- Testar no smartphone Android fisico antes da entrega.
- Testar tambem com internet movel, nao apenas no Wi-Fi.

## Documentos principais

- [Trabalho academico](docs/TRABALHO_ACADEMICO.md)
- [Arquitetura](docs/ARQUITETURA.md)
- [Contrato da API](docs/API_CONTRATO.md)
- [Plano de implementacao](docs/PLANO_IMPLEMENTACAO.md)
- [Roteiro de apresentacao](docs/ROTEIRO_APRESENTACAO.md)
- [Testes manuais](docs/TESTES_MANUAIS.md)

## Referencias tecnicas

- Flutter: https://docs.flutter.dev/
- geolocator: https://pub.dev/packages/geolocator
- flutter_map: https://pub.dev/packages/flutter_map
- Vercel Functions: https://vercel.com/docs/functions
- Gemini API: https://ai.google.dev/gemini-api/docs
