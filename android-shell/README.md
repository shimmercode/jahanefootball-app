# Android WebView shell

Used to produce an installable APK when a full Flutter/Android SDK toolchain is not available in the build sandbox.

```bash
python3 scripts/make_apk.py
python3 scripts/validate_apk.py artifacts/jahan-football-v1.0.0-release.apk
```

Package: `ir.jahanfootball.app`  
Activity: `ir.jahanfootball.app.MainActivity`  
Payload: `android-shell/www/index.html`
