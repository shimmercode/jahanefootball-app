<?php

if (!defined('ABSPATH')) {
    exit;
}

class Jahan_Football_Cors {
    public static function init() {
        add_action('rest_api_init', array(__CLASS__, 'send_headers'), 15);
    }

    public static function send_headers() {
        remove_filter('rest_pre_serve_request', 'rest_send_cors_headers');
        add_filter('rest_pre_serve_request', static function ($value) {
            $origin = get_http_origin();
            if ($origin) {
                header('Access-Control-Allow-Origin: ' . esc_url_raw($origin));
            } else {
                header('Access-Control-Allow-Origin: *');
            }
            header('Access-Control-Allow-Methods: GET, OPTIONS');
            header('Access-Control-Allow-Headers: Authorization, Content-Type, Accept');
            header('Access-Control-Allow-Credentials: true');
            header('Vary: Origin');
            return $value;
        });
    }
}
