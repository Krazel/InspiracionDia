# Build Android

La version Android es nativa y vive en `android/`.

ID fijo:

```text
com.dmkr.inspiraciondia
```

Build local desde Windows:

```powershell
cd android
.\gradlew.bat assembleDebug
```

El APK local queda en:

```text
android/app/build/outputs/apk/debug/app-debug.apk
```

Copiar a `artifact/` con nombre versionado:

```text
artifact/InspiracionDia-Android-v1.0-local.apk
```

GitHub Actions genera y publica:

```text
artifact/InspiracionDia-Android-v1.0-build-N.apk
```
