<?php
/**
 * Plugin Name: Jahan Football API
 * Plugin URI: https://github.com/shimmercode/jahanefootball-app
 * Description: REST API for the Jahan Football Android app — home, news, categories, search and matches.
 * Version: 1.0.0
 * Author: Jahan Football
 * Text Domain: jahan-football
 * Requires at least: 6.0
 * Requires PHP: 7.4
 */

if (!defined('ABSPATH')) {
    exit;
}

define('JAHAN_FOOTBALL_API_VERSION', '1.0.0');
define('JAHAN_FOOTBALL_API_NS', 'jahan-football/v1');

require_once __DIR__ . '/includes/class-cors.php';
require_once __DIR__ . '/includes/class-rest-api.php';

add_action('plugins_loaded', static function () {
    Jahan_Football_Cors::init();
    Jahan_Football_Rest_Api::init();
});

register_activation_hook(__FILE__, static function () {
    flush_rewrite_rules();
});

register_deactivation_hook(__FILE__, static function () {
    flush_rewrite_rules();
});
