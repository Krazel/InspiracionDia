# Warm Words — iOS

Aplicación nativa SwiftUI para iPhone. El nombre interno histórico del repositorio es Inspiración Día.

## Estado actual

- iPhone: app SwiftUI nativa en `native-ios/`, con build IPA por GitHub Actions.
- Bundle ID: `com.dmkr.inspiraciondia.B2X6D3A9J9`.
- Android está congelado y fuera del alcance de este proyecto.

## Incluye

- 360 pares de frases originales en inglés y español.
- 12 categorías: Ánimo, Foco, Calma, Disciplina, Autoestima, Gratitud, Valentía, Hábitos, Creatividad, Resiliencia, Relaciones y Energía.
- Tarjetas por categoría.
- Favoritos.
- Compartir una tarjeta visual con el panel nativo del móvil.
- Recordatorios locales configurables por hora, días y categorías.
- Frases personales, favoritos y selector de idioma persistentes.
- UI premium con imágenes de fondo en iOS.

## iOS Como En Alarma

Este proyecto incluye una app iOS SwiftUI en `native-ios/`, igual que el flujo usado en `Alarma`.

Antes de subir cambios de frases:

```powershell
node scripts/check-quotes.mjs
node scripts/export-ios-content.mjs
node scripts/export-ios-content-en.mjs
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

## Revisar Frases

```powershell
node scripts/check-quotes.mjs
```
