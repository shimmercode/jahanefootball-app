# جهان فوتبال — Jahan Football

اپلیکیشن اندروید اخبار و نتایج فوتبال ایران و جهان.

**Package:** `ir.jahanfootball.app`  
**Version:** `1.0.0+1`  
**Minimum Android:** 6.0 (API 23)

هدف این مخزن: **سورس Flutter + API + بیلد واقعی APK + GitHub Release**.

## Project

جهان فوتبال یک کلاینت موبایل فارسی/RTL است برای:

- صفحه خانه با خبر ویژه و نتایج زنده
- لیست و جزئیات خبر
- جستجو
- مرکز فوتبال (زنده / برنامه / تمام‌شده)
- مرکز اعلان داخل برنامه

## Features

- رابط تیره زمردی با تأکید طلایی، کاملاً راست‌چین
- اتصال به API جهان فوتبال و در صورت تنظیم، WordPress
- غنی‌سازی مسابقات با TheSportsDB
- کاتالوگ آفلاین؛ خانه و اخبار بدون اینترنت هم باز می‌شوند
- آیکون adaptive و اسپلش
- CI برای تست، بیلد APK و انتشار GitHub Release

## Architecture

نگاه کنید به [`docs/architecture/README.md`](docs/architecture/README.md).

```
mobile/                 Flutter application
wordpress-plugin/       Jahan Football REST plugin
backend/public/v1/     Production JSON API
docs/                   Architecture, API, build, deploy
.github/workflows/      Test, Android build, Release
```

## Requirements

- Flutter stable 3.24+
- JDK 17
- Android SDK (compile/target 35)
- Git / GitHub

## Installation

از [Releases](https://github.com/shimmercode/jahanefootball-app/releases/tag/v1.0.0) فایل

`jahan-football-v1.0.0-release.apk`

را دانلود و روی دستگاه Android نصب کنید (منبع ناشناس را اجازه دهید).

## Development

```bash
cd mobile
flutter pub get
flutter run --dart-define=ENV=development
```

## Build

مستند کامل: [`docs/build/android-apk.md`](docs/build/android-apk.md)

```bash
bash scripts/build_apk.sh
```

یا:

```bash
cd mobile
flutter build apk --release \
  --dart-define=ENV=production \
  --dart-define=API_BASE_URL=https://raw.githubusercontent.com/shimmercode/jahanefootball-app/v1.0.0/backend/public/v1 \
  --dart-define=FOOTBALL_API_BASE_URL=https://www.thesportsdb.com/api/v1/json/3
```

خروجی: `artifacts/jahan-football-v1.0.0-release.apk`

## Environment Variables

| Variable | Default |
| --- | --- |
| `ENV` | `production` |
| `API_BASE_URL` | GitHub-hosted JSON API tagged `v1.0.0` |
| `FOOTBALL_API_BASE_URL` | `https://www.thesportsdb.com/api/v1/json/3` |
| `WORDPRESS_BASE_URL` | empty |

هرگز URL پروداکشن را در ویجت‌ها hardcode نکنید. فقط `AppEnv`.

## API

[`docs/api/README.md`](docs/api/README.md)

حداقل endpointها:

- `GET /home.json`
- `GET /news.json`
- `GET /news/{id}.json`
- `GET /categories.json`
- `GET /search.json`
- `GET /matches.json`

## Firebase

پوش FCM در این نسخه **فعال نشده** چون `google-services.json` و کلید پروژه در اختیار نبود.

وضعیت: `BLOCKED — Firebase credentials required`

مرکز اعلان داخل برنامه کار می‌کند.

## WordPress

پلاگین قابل نصب در `wordpress-plugin/`.

اگر هاست WordPress پروداکشن موجود نیست:

`BLOCKED — Production WordPress endpoint required`

اپ در این حالت از JSON API و کاتالوگ داخلی استفاده می‌کند.

## Release

1. تست‌ها باید سبز باشند
2. تگ `v1.0.0` پوش شود
3. Workflow `Release` فایل APK/AAB را می‌سازد، اعتبارسنجی می‌کند و GitHub Release می‌سازد

## Troubleshooting

| مشکل | راه حل |
| --- | --- |
| خانه خالی است | Pull-to-refresh؛ کاتالوگ داخلی باید همیشه خبر نشان دهد |
| تصویر لود نمی‌شود | آیکون توپ جایگزین می‌شود؛ کرش نمی‌کند |
| Flutter/SDK روی این sandbox نیست | بیلد روی GitHub Actions انجام می‌شود |
| نصب APK رد می‌شود | Unknown sources را فعال کنید؛ minSdk 23 |
| Firebase / WP / Football key | در گزارش نهایی به‌صورت BLOCKED آمده است |

## License

MIT — see [LICENSE](LICENSE)
