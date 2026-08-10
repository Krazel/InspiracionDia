# Estado de Inspiración Día

Actualizado: **2026-08-10**
Estado: **IPA unsigned bilingüe iOS 1.0 build 13 con carta vertical compilada y verificada para Sideloadly**
Propietario único de implementación: **esta tarea cerebro**
Fuente histórica: `docs/audit/IOS_CLOSEOUT_AUDIT.md`

## Fotografía actual

- Repositorio canónico: `https://github.com/Krazel/InspiracionDia`; rama de compilación `agent/warm-words-ios-ipa`, commit bilingüe `ec7af63`.
- El propietario autorizó commit, push y compilación de la IPA el 2026-08-09. No se creó release ni se publicó o subió a TestFlight/App Store.
- `.gitignore` modificado y `store/store-manifest.json` sin seguimiento siguen preservados; el manifest de tienda no se ha editado.
- Android permanece intacto y fuera de alcance.
- La app continúa con la navegación y el lenguaje visual existentes; no se añadió pantalla ni se abrió rediseño.

## Cierre implementado localmente

- Catálogos propios completos de 180 frases y 12 categorías en inglés y español, con los mismos IDs y orden. No contienen citas atribuidas ni dependen de una fuente externa.
- El alcance solo inglés quedó sustituido por una app bilingüe: idioma inicial según el iPhone, selector persistente en Settings y cambio conjunto de interfaz, catálogo, categorías, fechas, días y próximas notificaciones. Favoritos y datos personales se conservan por ID y las frases creadas por el usuario no se traducen.
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

## Compilación macOS aprobada

- GitHub Actions run `31329591743`, job `93285576827`, completó correctamente en macOS el 2026-08-09.
- Pasaron Xcode/SDK 26+, XcodeGen, validadores de contenido/cierre, XCTest en iPhone Simulator, build Release unsigned, empaquetado y upload del artifact.
- IPA descargada: `dist/Warm-Words-Sideloadly.ipa`, 5,950,648 bytes, SHA-256 `A7E77DA23CE498C505627DCBF17CAD45F0131EB4B2131347D3F7576FA3067872`.
- Inspección local del archivo confirma ZIP válido, `Warm Words`, bundle `com.dmkr.inspiraciondia`, versión 1.0 build 9, `AppIcon`, catálogo inglés y privacy manifest.
- La IPA está unsigned a propósito: Sideloadly debe firmarla al instalarla. La prueba física en iPhone sigue pendiente.

## Cambio 1.1 cerrado en build 11

- La IPA actual corresponde al commit `6dca776` e incluye este cambio.
- Today ya no contiene la franja “Thoughtful quotes / Easy to share / One each day” ni “Explore categories”.
- El motor añade días ISO estables, próximas 60 ocurrencias filtradas, clean-install onboarding versionado, siete días por defecto, guardado atómico y migración de instalaciones anteriores sin pedir permiso al iniciar.
- El modelo permite crear una categoría personal con su primera frase, persistirla y retirarla al borrar su última frase. El ShareLink existente ya comparte frases personales como texto.
- Las cuatro propuestas de `docs/design/reminder-v2/` fueron aprobadas e implementadas: Today compacto, onboarding, Settings y nueva categoría inline.
- El formulario personal es desplazable, limita cada frase a 240 caracteres y avisa si borrar la última frase elimina también su categoría. Denegar el permiso de notificaciones muestra feedback inmediato.
- La tarjeta Today ya no hereda la proporción vertical del fondo: el contenido fija 330 pt en texto normal y la imagen se recorta como fondo, por lo que la portada compacta cabe sin el alargamiento observado en build 10.
- Validadores Windows, checks de contenido, Swift/XCTest y build Release pasan.

## Compilación macOS actual

- GitHub Actions run `31333402280`, job `93295110537`, completó correctamente en macOS el 2026-08-09.
- Pasaron Xcode/SDK 26+, XcodeGen, validadores, XCTest, build Release unsigned, empaquetado y upload del artifact.
- IPA verificada: `dist/Warm-Words-Sideloadly-build-11.ipa`, 6,024,614 bytes, SHA-256 `0087D21A6CC48ECF46ACF196E704AF28BC7BD7AC0A371C52002343BA30AF206A`.
- Inspección interna confirma ZIP válido, `Warm Words`, bundle `com.dmkr.inspiraciondia`, versión 1.0 build 11, `AppIcon`, catálogo inglés, assets compilados y privacy manifest.

## Cambio bilingüe cerrado en build 12

- Decisión registrada en `DEC-022`: Warm Words 1.0 ofrece inglés y español; `DEC-002` queda histórica.
- `AppLanguage` prioriza una elección guardada y, sin ella, usa español para variantes `es-*` del iPhone e inglés para el resto.
- Settings incorpora un selector segmentado `English / Español` dentro de la pantalla existente, sin nueva navegación ni rediseño.
- Ambos recursos se cargan con fallback seguro; los 180 pares mantienen favoritos, selección, entrega y frase diaria. Las categorías personales históricas no se eliminan por colisionar con una traducción.
- Fechas, hora de vista previa, días cortos/completos, VoiceOver y todo el copy 1.1 tienen paridad inglés/español. Cambiar el idioma vuelve a generar la cola local autorizada sin pedir permiso otra vez.
- `CFBundleLocalizations` declara `en` y `es`; tests, validadores, workflow y checklist QA cubren ambos idiomas.
- Validación Windows: exportaciones reproducibles, 180+180 frases, paridad de IDs/categorías y claves UI, plist/configuración, `git diff --check` y ausencia de diff Android.
- GitHub Actions run `31346772665`, job `93330043852`, pasó Xcode/SDK 26+, validadores, XcodeGen, XCTest, build Release, empaquetado e integración de recursos.
- IPA verificada: `dist/Warm-Words-Sideloadly-bilingual-build-12.ipa`, 6.039.556 bytes, SHA-256 `24C9F10329A73AB751A2BA7A143D803259B36E02B5E39AF296C1CE028EDDAAB9`.
- Inspección interna confirma ZIP/CRC válido, `Warm Words`, bundle `com.dmkr.inspiraciondia`, versión 1.0 build 12, `en`+`es`, 180+180 frases con IDs paralelos, AppIcon, Assets.car y PrivacyInfo.
- La siguiente puerta es instalar build 12 mediante Sideloadly y probar en iPhone el idioma inicial, el selector, persistencia, notificación en ambos idiomas y migración desde build 11.

## Ajuste Today cerrado en build 13

- El propietario indicó que la tarjeta principal seguía pareciendo cuadrada y pidió una proporción de carta vertical.
- El cambio local mantiene 330 pt de altura mínima y reduce el ancho máximo normal a 276 pt, centrado; Dynamic Type de accesibilidad conserva ancho flexible y 430 pt mínimos.
- El fondo continúa como background recortado y no participa en el cálculo de tamaño. Las listas conservan filas legibles.
- GitHub Actions run `31347994854`, job `93333435638`, pasó validadores, XcodeGen, XCTest, Release, empaquetado y artifact.
- IPA verificada: `dist/Warm-Words-Sideloadly-portrait-card-build-13.ipa`, 6.039.718 bytes, SHA-256 `ED1F64CAB286904F2255EE71739DE615A9142D43DB3C97FD080FBD601232D263`.
- Inspección interna confirma ZIP/CRC, versión 1.0 build 13, ambos idiomas/catálogos, IDs paralelos, AppIcon, Assets.car y PrivacyInfo.
- Falta la comprobación visual en iPhone de la proporción final y que Today siga cabiendo sin desplazamiento a tamaño de texto normal.

## Primer bloqueo material de App Store

El nombre público **Warm Words**, el AppIcon **C — Protected thought** y la decisión de usar un catálogo editorial propio ya están cerrados localmente. La primera puerta material restante es conservar la trazabilidad editorial del catálogo y confirmar por escrito la autoría/licencia comercial de `premium-mountains.png` y `premium-stones.png`. Recomendación: no preparar un envío a App Review hasta disponer de esa confirmación y sustituir cualquier recurso sin derechos claros.

## Puertas restantes

1. Confirmar derechos comerciales de frases y fondos.
2. Proporcionar Support URL y Privacy Policy URL públicas.
3. Confirmar Apple Developer/App Store Connect, team, bundle ID y firma.
4. Ejecutar archive firmado, Analyze/Validate App y QA real en iPhone/iOS 16 e iOS 26; después preparar capturas y ficha inglesa.
5. Revisar el candidato con el propietario. TestFlight, App Store y App Review siguen necesitando autorización expresa en ese momento.

El apoyo voluntario en Settings queda planificado para una fase posterior y no bloquea este candidato. Implementarlo requerirá StoreKit, productos mensuales en App Store Connect, restauración de compras, términos y privacidad; no se crearán ni enviarán productos sin autorización expresa.

## Limitación aceptada del MVP local

Sin servidor ni ejecución en segundo plano garantizada, la cola de recordatorios cubre aproximadamente 60 días. Se renueva al abrir o activar la app; si el usuario no la abre durante ese periodo, puede agotarse. Un cambio de zona horaria también se corrige al siguiente uso de la app.
