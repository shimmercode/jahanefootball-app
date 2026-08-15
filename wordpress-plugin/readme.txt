=== Jahan Football API ===
Contributors: jahanfootball
Requires at least: 6.0
Tested up to: 6.6
Requires PHP: 7.4
Stable tag: 1.0.0
License: MIT

REST API used by the Jahan Football Android application.

== Description ==

Exposes:

* GET /wp-json/jahan-football/v1/home
* GET /wp-json/jahan-football/v1/news
* GET /wp-json/jahan-football/v1/news/{id}
* GET /wp-json/jahan-football/v1/categories
* GET /wp-json/jahan-football/v1/search?q=
* GET /wp-json/jahan-football/v1/matches

CORS is enabled for mobile clients.

== Installation ==

1. Upload the `jahan-football-api` folder to `wp-content/plugins/`
2. Activate the plugin
3. Confirm endpoints respond over HTTPS
4. Point the Flutter app at the WordPress origin via `--dart-define=WORDPRESS_BASE_URL=`
