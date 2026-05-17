# Inspiracion Dia Native

App movil nativa para iPhone y Android.

## Estado actual

- iPhone: app SwiftUI nativa en `native-ios/`, con build IPA por GitHub Actions.
- Android: app nativa Java/Android en `android/`, con build APK local desde Windows.
- IDs fijos:
  - iOS Bundle ID: `com.dmkr.inspiraciondia`
  - Android Package ID: `com.dmkr.inspiraciondia`

## Incluye

- 180 frases originales.
- 12 categorias: Animo, Foco, Calma, Disciplina, Autoestima, Gratitud, Valentia, Habitos, Creatividad, Resiliencia, Relaciones y Energia.
- Tarjetas por categoria.
- Favoritos.
- Compartir con el panel nativo del movil.
- Notificacion local diaria con hora configurable.
- Boton para probar notificacion.
- UI premium con imagenes de fondo en iOS y Android.

## Regla De Paridad

La app debe mantenerse para iPhone y Android.

Cuando se cambie UI o funcionalidad en iOS, hay que replicarlo en Android o dejar una issue clara pendiente.

La UI premium debe mantenerse en iOS SwiftUI y Android nativo.

## iOS Como En Alarma

Este proyecto incluye una app iOS SwiftUI en `native-ios/`, igual que el flujo usado en `Alarma`.

Antes de subir cambios de frases:

```powershell
node scripts/check-quotes.mjs
node scripts/export-ios-content.mjs
```

El workflow `.github/workflows/build-ios-unsigned.yml` genera la IPA en macOS.

Descargar IPA:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\watch-latest-ipa.ps1 -Repo "Krazel/InspiracionDia"
```

La IPA queda en:

```text
artifact/InspiracionDia-iPhone-v1.0-build-N.ipa
```

## Android

Android nativo esta en:

```text
android/
```

Para compilar en Android:

```powershell
cd android
.\gradlew.bat assembleDebug
```

El APK versionado debe quedar en:

```text
artifact/InspiracionDia-Android-v1.0-local.apk
artifact/old/
```

## Revisar Frases

```powershell
node scripts/check-quotes.mjs
```
