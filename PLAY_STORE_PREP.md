# Google Play Console

Primera app recomendada: Inspiracion Dia.

Package ID fijo:

```text
com.dmkr.inspiraciondia
```

Android se compila localmente desde Windows. No usar GitHub Actions para Android.

## Build Para Play Store

Google Play usa Android App Bundle:

```text
.aab
```

Generar el bundle firmado:

```powershell
.\build-play-aab.bat
```

Salida:

```text
artifact/InspiracionDia-Android-v1.0-play-local.aab
```

La upload key vive localmente en:

```text
android/keystore/upload-keystore.jks
android/upload-key.properties
```

No subir esos archivos al repositorio.

## Play Console

1. Crear app nueva.
2. Nombre: `Inspiracion Dia`.
3. Idioma predeterminado: Espanol.
4. Tipo: App.
5. Gratis o de pago: elegir antes de publicar.
6. Activar Play App Signing.
7. Subir `artifact/InspiracionDia-Android-v1.0-play-local.aab`.
8. Completar ficha de tienda.
9. Completar Data safety.
10. Subir politica de privacidad a una URL publica.

Si la cuenta de Google Play es personal y nueva, puede pedir closed testing con al menos 12 testers durante 14 dias antes de produccion.
