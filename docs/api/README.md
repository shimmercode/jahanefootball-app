# API

Production base (release APK):

`https://raw.githubusercontent.com/shimmercode/jahanefootball-app/v1.0.0/backend/public/v1`

| Method | Path | Description |
| --- | --- | --- |
| GET | `/home.json` | Featured news, latest, matches, categories |
| GET | `/news.json` | News list |
| GET | `/news/{id}.json` | News detail |
| GET | `/categories.json` | Categories |
| GET | `/search.json` | Search results |
| GET | `/matches.json` | Match list |

WordPress plugin (when a real host exists):

`https://YOUR_WP_HOST/wp-json/jahan-football/v1/`

Football enrichment:

`https://www.thesportsdb.com/api/v1/json/3/eventsday.php?d=YYYY-MM-DD&s=Soccer`
