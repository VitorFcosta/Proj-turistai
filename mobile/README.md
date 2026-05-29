# TouristAI Mobile

Aplicativo Flutter Android do TouristAI.

## Estrutura

```text
lib/
├── main.dart
├── screens/
│   └── home_screen.dart
├── services/
│   ├── location_service.dart
│   ├── places_service.dart
│   └── recommendation_service.dart
└── widgets/
    ├── current_location_map.dart
    ├── location_status_card.dart
    ├── places_summary_card.dart
    ├── preference_dropdown.dart
    └── recommendation_card.dart
```

## Responsabilidades

- `main.dart`: inicia o app, configura tema e abre a tela principal.
- `screens/home_screen.dart`: controla o estado da tela, preferencias, busca de locais e chamada da IA.
- `services/`: isolam GPS, Overpass/OpenStreetMap e backend de recomendacoes.
- `widgets/`: componentes visuais reutilizados pela tela principal.

## Comandos

```bash
flutter test
flutter analyze
flutter run --dart-define=TOURISTAI_API_BASE_URL=https://touristai-backend.vercel.app
```
