# Inspiracion Dia Native

App nativa para iPhone y Android hecha con React Native y Expo. No es una web/PWA.

## Qué incluye

- 180 frases originales.
- 12 categorías: Animo, Foco, Calma, Disciplina, Autoestima, Gratitud, Valentia, Habitos, Creatividad, Resiliencia, Relaciones y Energia.
- Tarjetitas nativas con colores por categoría.
- Favoritos.
- Compartir con el panel nativo del móvil.
- Notificación local diaria con hora configurable.
- Botón para probar notificación.

## iOS como en Alarma

Este proyecto incluye una app iOS SwiftUI en `native-ios/`, igual que el flujo usado en `Alarma`.

```powershell
npm run check:quotes
npm run export:ios-content
```

Después se sube el repo público a GitHub y el workflow `.github/workflows/build-ios-unsigned.yml` genera la IPA en macOS. Ver detalles en `BUILD_IOS_DESDE_GITHUB.md`.

## Probar en móvil

Instala dependencias:

```powershell
npm install
```

Arranca Expo:

```powershell
npm start
```

Android nativo ya está generado en la carpeta `android`.

Para compilar Android:

```powershell
npm run android
```

Para iPhone:

```powershell
npm run prebuild:ios
npm run ios
```

La carpeta `ios` no se puede generar desde este Windows: Expo exige macOS o Linux para crear el proyecto iOS nativo. El proyecto ya tiene `bundleIdentifier` y configuración iOS; al abrirlo en macOS, `npm run prebuild:ios` generará la carpeta `ios`.

## Revisar frases

```powershell
npm run check:quotes
```
