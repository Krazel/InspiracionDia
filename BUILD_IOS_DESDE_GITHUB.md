# Compilar iOS desde GitHub Actions

Este proyecto sigue el mismo flujo que `Alarma`: no se compila iOS localmente en Windows. Se sube el repo publico a GitHub, GitHub Actions compila en macOS y se descarga una IPA unsigned.

## Flujo

1. Crear un repo publico para `InspiracionDiaNative`.
2. Subir `main` a GitHub.
3. GitHub Actions ejecuta `Build unsigned iOS IPA`.
4. El workflow genera `InspiracionDia-unsigned.ipa`.
5. Tambien publica la release `latest-ipa`.
6. Descargar la IPA con `scripts/watch-latest-ipa.ps1`.
7. Instalarla en iPhone con Sideloadly.

## Archivos importantes

- `.github/workflows/build-ios-unsigned.yml`: workflow macOS para compilar iOS.
- `native-ios/project.yml`: definicion XcodeGen.
- `native-ios/Sources/InspiracionDiaApp.swift`: app SwiftUI nativa.
- `native-ios/Resources/content.json`: frases y categorias para iOS.
- `scripts/export-ios-content.mjs`: regenera `content.json` desde `data/quotes.js` y `data/categories.js`.
- `scripts/watch-latest-ipa.ps1`: espera la build y descarga la IPA.
- `watch-ipa.bat`: acceso rapido al watcher desde Windows.

## Antes de subir

```powershell
npm run check:quotes
npm run export:ios-content
```

## Descargar la IPA

Por defecto el watcher apunta a:

```text
Krazel/InspiracionDia
```

Si el repo publico tiene otro nombre:

```powershell
.\scripts\watch-latest-ipa.ps1 -Repo "Krazel/NOMBRE_DEL_REPO"
```

Cuando termine la build, queda una sola IPA visible en `artifact/`:

```text
artifact/InspiracionDia-iPhone-v1.0-build-N.ipa
```

Las IPAs anteriores quedan dentro de `artifact/old/`.

## Instalar en iPhone

1. Abrir Sideloadly en Windows.
2. Conectar el iPhone por USB.
3. Seleccionar `artifact/InspiracionDia-iPhone-latest.ipa`.
4. Instalar con tu Apple ID.
5. En el iPhone, confiar en el perfil si iOS lo pide.

Con Apple ID gratuito normalmente hay que refrescar o reinstalar cada 7 dias.
