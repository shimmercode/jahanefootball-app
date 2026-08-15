# Android APK build

## Production command

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter create --platforms=android --org ir.jahanfootball --project-name jahan_football .
python3 ../scripts/configure_android.py
flutter build apk --release \
  --dart-define=ENV=production \
  --dart-define=API_BASE_URL=https://cdn.jsdelivr.net/gh/shimmercode/jahanefootball-app@v1.0.0/backend/public/v1 \
  --dart-define=FOOTBALL_API_BASE_URL=https://www.thesportsdb.com/api/v1/json/3
```

Helper:

```bash
bash scripts/build_apk.sh
```

Output:

- `mobile/build/app/outputs/flutter-apk/app-release.apk`
- `artifacts/jahan-football-v1.0.0-release.apk`

## Signing

Release signing uses GitHub secrets when present:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

Never commit the keystore.

## Validate

```bash
python3 scripts/validate_apk.py artifacts/jahan-football-v1.0.0-release.apk
```

## Package

`ir.jahanfootball.app`
