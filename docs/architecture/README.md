# Architecture

```
Android App (Flutter)
        │
        ├── Jahan Football JSON API  (backend/public/v1 or WordPress plugin)
        ├── WordPress REST            (optional, WORDPRESS_BASE_URL)
        └── TheSportsDB               (optional football enrichment)
                │
                └── LocalCatalog fallback (always available)
```

## Layers

- `lib/core` — env, theme, HTTP client
- `lib/data` — models, repositories, local catalog
- `lib/features` — screens (home, news, search, football, notifications)
- `wordpress-plugin` — production CMS adapter
- `.github/workflows` — test → build → release

## Environments

| Name | How |
| --- | --- |
| development | `--dart-define=ENV=development` |
| staging | `--dart-define=ENV=staging` |
| production | `--dart-define=ENV=production` (default) |

All URLs come from dart-defines. They are not scattered through widgets.
