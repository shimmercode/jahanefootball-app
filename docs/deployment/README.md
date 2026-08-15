# Deployment

1. Merge to a release-ready commit
2. Tag `v1.0.0`
3. GitHub Actions `Release` workflow:
   - Flutter analyze + test
   - Release APK + AAB
   - APK validation
   - GitHub Release with assets
4. Install APK on a physical Android device (unknown sources allowed)

WordPress:

1. Zip `wordpress-plugin/`
2. Upload in wp-admin → Plugins
3. Confirm HTTPS endpoints
4. Rebuild the app with `--dart-define=WORDPRESS_BASE_URL=https://your-site.tld`
