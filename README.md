# Inspiracion Dia Native

App movil para iPhone y Android. No es una web/PWA.

## Estado actual

- iPhone: app SwiftUI nativa en `native-ios/`, con build IPA por GitHub Actions.
- Android: estructura Android/React Native generada en `android/`.
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
- iOS premium con imagenes de fondo en `native-ios/Resources/`.

## Regla De Paridad

La app debe mantenerse para iPhone y Android.

Cuando se cambie UI o funcionalidad en iOS, hay que replicarlo en Android o dejar una issue clara pendiente.

La UI premium actual esta aplicada en iOS SwiftUI. Android conserva la base React Native inicial y debe recibir el mismo rediseno para paridad visual.

## iOS Como En Alarma

Este proyecto incluye una app iOS SwiftUI en `native-ios/`, igual que el flujo usado en `Alarma`.

Antes de subir cambios:

```powershell
npm run check:quotes
npm run export:ios-content
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

Android nativo ya esta generado en:

```text
android/
```

Para instalar dependencias:

```powershell
npm install
```

Para ejecutar en Android:

```powershell
npm run android
```

Objetivo pendiente: generar un APK/AAB versionado y dejarlo en `artifact/` siguiendo la misma regla que iOS:

```text
artifact/InspiracionDia-Android-v1.0-build-N.apk
artifact/old/
```

## Revisar Frases

```powershell
npm run check:quotes
```
