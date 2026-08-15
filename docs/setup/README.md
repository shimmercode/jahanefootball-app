# Setup

## Requirements

- Flutter stable (3.24+)
- JDK 17
- Android SDK 35 / build-tools
- Git

## Run

```bash
cd mobile
flutter pub get
flutter run --dart-define=ENV=development
```

## Environment variables

| Key | Purpose |
| --- | --- |
| `ENV` | development / staging / production |
| `API_BASE_URL` | Jahan Football JSON API |
| `FOOTBALL_API_BASE_URL` | TheSportsDB or custom football API |
| `WORDPRESS_BASE_URL` | WordPress origin (optional) |
