# Estado de Inspiración Día

Actualizado: **2026-08-09**
Estado: **cierre técnico local iOS 1.0 estáticamente consistente; aún no es candidato distribuible**
Propietario único de implementación: **esta tarea cerebro**
Fuente histórica: `docs/audit/IOS_CLOSEOUT_AUDIT.md`

## Fotografía actual

- Repositorio canónico: `https://github.com/Krazel/InspiracionDia`; rama `main` sobre la base auditada `c8fac196d53c889b2125e0760ced49fd26c9666e`.
- Todo el trabajo de cierre permanece local, sin commit, push, release ni publicación.
- `.gitignore` modificado y `store/store-manifest.json` sin seguimiento siguen preservados; el manifest de tienda no se ha editado.
- Android permanece intacto y fuera de alcance.
- La app continúa con la navegación y el lenguaje visual existentes; no se añadió pantalla ni se abrió rediseño.

## Cierre implementado localmente

- Catálogo inglés completo de 180 frases y 12 categorías en `data/quotes-en.js` y `native-ios/Resources/content-en.json`, con los mismos IDs y orden que el legado español. `content.json` y sus fuentes españolas se conservan.
- Producto público fijado en inglés: carga explícita del recurso inglés, locale inglés para la fecha y selector español retirado de la UI. Preferencias y tarjetas personales anteriores se conservan cuando son válidas.
- Frase diaria basada en días continuos, sin reinicio por año.
- Recordatorio local sustituido por una cola de 60 notificaciones no repetitivas con una frase calculada por fecha; se refresca al activar la app y al cambiar hora, categorías o tarjetas. La autorización solo se pide tras una acción explícita.
- Hora configurada con `DatePicker`, migración estricta de la preferencia antigua y manejo de cambios DST mediante el calendario del sistema.
- Tarjetas propias: entrada vacía o categoría inválida no cierra la hoja; crear selecciona y persiste “Manual”; borrar exige confirmación y limpia favorito y notificaciones. Edición queda fuera de 1.0.
- Compartir continúa como texto plano; no necesita nuevo material visual.
- Accesibilidad puntual: labels y estados seleccionados, encabezados semánticos, fondos decorativos ocultos, botones táctiles, grid adaptado a tamaños AX, tipografías dinámicas críticas y dorado de texto oscurecido.
- `PrivacyInfo.xcprivacy` declara `UserDefaults` con `CA92.1`; `Info.plist` usa región inglesa, iPhone portrait y `ITSAppUsesNonExemptEncryption=false` sujeto a inspección del archive final.
- Target iPhone-only, firma automática sin team embebido y target XCTest explícito.
- El modo de lenguaje Swift se corrigió a `5.0` —`5.9` no es un valor válido de `SWIFT_VERSION` en Xcode— y el target de tests tiene bundle ID propio.
- `AppStore` y la raíz SwiftUI están aislados al actor principal; las operaciones de UserNotifications usan async/await y la reprogramación se serializa para que cambios rápidos o una desactivación no dejen una cola antigua.
- CI exige macOS 26 / SDK iOS 26+, valida ambos catálogos y privacy manifest, ejecuta tests y conserva solo un artifact unsigned durante tres días. Se eliminó la publicación automática de GitHub Releases y `contents: write`.
- La fecha y la frase del día se refrescan al volver a primer plano y con el cambio de día del sistema; la vista previa del recordatorio usa la próxima frase programada según hora y categorías.
- El copy inglés visible se pulió sin alterar el layout ni abrir un rediseño.
- Quedaron preparados, con campos externos marcados, el copy de App Store, la política de privacidad, la página de soporte y el checklist de QA en `docs/release/`.
- El AppIcon **C — Protected thought** fue aprobado e integrado como master RGB opaco de 1024×1024 en `Assets.xcassets`; XcodeGen lo referencia como `AppIcon` y las validaciones comprueban dimensiones, formato y ausencia de alpha.

## Verificaciones aprobadas en Windows

- `node scripts/check-quotes.mjs`: 180 frases españolas y 180 inglesas, 12 categorías, sin duplicados y con paridad exacta de IDs/categorías.
- `node scripts/check-ios-closeout.mjs`: idioma público, cola local, tarjetas, privacy manifest, proyecto y ausencia de release automática verificados estáticamente.
- `content.json`, `content-en.json`, `Info.plist` y `PrivacyInfo.xcprivacy` parsean correctamente.
- `project.yml` y el workflow parsean como YAML; el esquema incluye `InspiracionDiaTests`.
- `git diff --check` no detecta errores y `git diff --name-only -- android` queda vacío.
- La regeneración de ambos catálogos es byte a byte reproducible.

No puede demostrarse en Windows que Swift compile con Xcode, que XcodeGen incluya todos los recursos, ni que UI, VoiceOver, notificaciones, compartir o persistencia funcionen en un iPhone. Una segunda inspección estática no encontró otro error de compilación definitivo después de corregir `SWIFT_VERSION`, pero el workflow actualizado tampoco se ha ejecutado porque no se hizo push.

## Primer bloqueo material

El nombre público **Warm Words** y el AppIcon **C — Protected thought** ya están cerrados localmente. La primera puerta material restante es confirmar por escrito la autoría/licencia y el permiso comercial de las 180 frases inglesas y españolas y de `premium-mountains.png` y `premium-stones.png`. Recomendación: no preparar un envío a App Review hasta disponer de esa confirmación y sustituir cualquier recurso sin derechos claros.

## Puertas restantes

1. Confirmar derechos comerciales de frases y fondos.
2. Proporcionar Support URL y Privacy Policy URL públicas.
3. Confirmar Apple Developer/App Store Connect, team, bundle ID y firma.
4. Ejecutar CI/macOS, archive firmado, Analyze/Validate App y QA real en iPhone/iOS 16 e iOS 26; después preparar capturas y ficha inglesa.
5. Revisar el candidato con el propietario. TestFlight, App Store y App Review siguen necesitando autorización expresa en ese momento.

## Limitación aceptada del MVP local

Sin servidor ni ejecución en segundo plano garantizada, la cola de recordatorios cubre aproximadamente 60 días. Se renueva al abrir o activar la app; si el usuario no la abre durante ese periodo, puede agotarse. Un cambio de zona horaria también se corrige al siguiente uso de la app.
