<?php

if (!defined('ABSPATH')) {
    exit;
}

class Jahan_Football_Rest_Api {
    public static function init() {
        add_action('rest_api_init', array(__CLASS__, 'register_routes'));
    }

    public static function register_routes() {
        register_rest_route(JAHAN_FOOTBALL_API_NS, '/home', array(
            'methods' => 'GET',
            'callback' => array(__CLASS__, 'home'),
            'permission_callback' => '__return_true',
        ));
        register_rest_route(JAHAN_FOOTBALL_API_NS, '/news', array(
            'methods' => 'GET',
            'callback' => array(__CLASS__, 'news'),
            'permission_callback' => '__return_true',
        ));
        register_rest_route(JAHAN_FOOTBALL_API_NS, '/news/(?P<id>\d+)', array(
            'methods' => 'GET',
            'callback' => array(__CLASS__, 'news_item'),
            'permission_callback' => '__return_true',
        ));
        register_rest_route(JAHAN_FOOTBALL_API_NS, '/categories', array(
            'methods' => 'GET',
            'callback' => array(__CLASS__, 'categories'),
            'permission_callback' => '__return_true',
        ));
        register_rest_route(JAHAN_FOOTBALL_API_NS, '/search', array(
            'methods' => 'GET',
            'callback' => array(__CLASS__, 'search'),
            'permission_callback' => '__return_true',
        ));
        register_rest_route(JAHAN_FOOTBALL_API_NS, '/matches', array(
            'methods' => 'GET',
            'callback' => array(__CLASS__, 'matches'),
            'permission_callback' => '__return_true',
        ));
    }

    public static function home() {
        $posts = self::query_posts(array('posts_per_page' => 12));
        $featured = array_slice($posts, 0, 3);
        foreach ($featured as &$item) {
            $item['featured'] = true;
        }
        return rest_ensure_response(array(
            'featured' => $featured,
            'latest' => $posts,
            'matches' => self::matches_payload(),
            'categories' => self::category_payload(),
        ));
    }

    public static function news(WP_REST_Request $request) {
        $args = array('posts_per_page' => 20);
        $category = $request->get_param('category');
        if (!empty($category) && $category !== 'all') {
            $args['category_name'] = sanitize_title($category);
        }
        return rest_ensure_response(array('items' => self::query_posts($args)));
    }

    public static function news_item(WP_REST_Request $request) {
        $post = get_post((int) $request['id']);
        if (!$post || $post->post_status !== 'publish') {
            return new WP_Error('not_found', 'News not found', array('status' => 404));
        }
        return rest_ensure_response(self::map_post($post));
    }

    public static function categories() {
        return rest_ensure_response(array('items' => self::category_payload()));
    }

    public static function search(WP_REST_Request $request) {
        $q = sanitize_text_field((string) $request->get_param('q'));
        $items = self::query_posts(array(
            's' => $q,
            'posts_per_page' => 20,
        ));
        return rest_ensure_response(array('items' => $items));
    }

    public static function matches() {
        return rest_ensure_response(array('items' => self::matches_payload()));
    }

    private static function query_posts(array $args) {
        $query = new WP_Query(array_merge(array(
            'post_type' => 'post',
            'post_status' => 'publish',
        ), $args));
        $items = array();
        foreach ($query->posts as $post) {
            $items[] = self::map_post($post);
        }
        return $items;
    }

    private static function map_post(WP_Post $post) {
        $categories = get_the_category($post->ID);
        $category = $categories ? $categories[0] : null;
        return array(
            'id' => (string) $post->ID,
            'title' => get_the_title($post),
            'excerpt' => wp_strip_all_tags(get_the_excerpt($post)),
            'content' => apply_filters('the_content', $post->post_content),
            'image' => get_the_post_thumbnail_url($post, 'large') ?: '',
            'published_at' => get_post_time('c', true, $post),
            'category' => $category ? $category->name : 'اخبار',
            'category_id' => $category ? $category->slug : 'all',
            'author' => get_the_author_meta('display_name', $post->post_author),
            'source' => get_bloginfo('name'),
            'featured' => is_sticky($post->ID),
            'tags' => wp_get_post_tags($post->ID, array('fields' => 'names')),
        );
    }

    private static function category_payload() {
        $items = array(array('id' => 'all', 'name' => 'همه', 'slug' => 'all'));
        foreach (get_categories(array('hide_empty' => false)) as $category) {
            $items[] = array(
                'id' => $category->slug,
                'name' => $category->name,
                'slug' => $category->slug,
            );
        }
        return $items;
    }

    private static function matches_payload() {
        $stored = get_option('jahan_football_matches', array());
        return is_array($stored) ? $stored : array();
    }
}
