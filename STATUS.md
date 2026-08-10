# Estado de Inspiración Día

Actualizado: **2026-08-10**
Estado: **build 17 de QA compila tarjetas compartibles; enlace inteligente pendiente de infraestructura pública**
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

## Corrección Settings posterior a build 13

- El propietario comprobó en iPhone que tocar el engranaje no abría Settings.
- El `Binding` y el área táctil eran correctos; el punto frágil era presentar `.sheet` desde el `TabView`, cuya jerarquía UIKit puede cambiar o competir con otras presentaciones.
- La hoja se adjuntó al `Group` estable de `RootView`, manteniendo el mismo estado y contenido, y el botón recibió un identificador estable para QA.
- GitHub Actions run `31348412162`, job `93334582497`, pasó validadores, XcodeGen, XCTest, Release, empaquetado y artifact.
- IPA verificada: `dist/Warm-Words-Sideloadly-settings-fix-build-14.ipa`, 6.040.287 bytes, SHA-256 `0DB1513C9533E32A8E2AB652E53EEDAAAA98ED379B7513E23F689C7A0290E191`.
- Inspección interna confirma ZIP/CRC, versión 1.0 build 14, ambos idiomas/catálogos, AppIcon, Assets.car y PrivacyInfo.
- Falta repetir en iPhone el toque del engranaje y confirmar que la hoja abre, cambia de idioma y se cierra correctamente.

## Corrección Today posterior a build 14

- La prueba del propietario confirmó que el ancho fijo de 276 pt seguía haciendo que la carta se viera pequeña.
- La referencia canónica vuelve a ser la imagen completa aprobada `docs/design/reminder-v2/warm-words-today-compact-proposal.png`; la interpretación estrecha de build 13/14 queda sustituida.
- Con texto normal, Today pasa a ser una pantalla fija sin desplazamiento vertical: la carta usa todo el ancho útil y absorbe el espacio restante; Me gusta y Compartir quedan visibles sobre la barra de pestañas.
- Los tamaños de texto de accesibilidad mantienen desplazamiento como excepción para no cortar contenido.
- GitHub Actions run `31400577560`, job `93494239595`, pasó validadores, XcodeGen, XCTest, build Release, empaquetado y artifact.
- IPA verificada: `dist/Warm-Words-Sideloadly-full-screen-card-build-15.ipa`, 6.044.016 bytes, SHA-256 `4FA8B53A323B89CFDBAF4DEA0B8A5DF27A271FCDBC45E1DC3699D17AC15BBAFB`.
- La inspección interna confirma ZIP/CRC, versión 1.0 build 15, ambos idiomas con 180 frases, AppIcon, Assets.car y PrivacyInfo.
- Falta únicamente la comprobación visual en iPhone de que la carta llena el espacio y Today no se desplaza con texto normal.

## Correcciones Settings y categorías en build 16

- La prueba física confirmó que `Group` no era un host estable para presentar Settings. `RootView` usa ahora un `ZStack` real y conserva la hoja en ese nivel; el botón y su identificador de QA permanecen intactos.
- Los mosaicos de categorías reservan la misma caja de icono y texto, el mismo ancho, altura normal de 112 pt y borde constante; con Dynamic Type de accesibilidad pueden crecer para no cortar contenido.
- Hábitos usa `checkmark.circle`, disponible en el mínimo iOS 16, en lugar del símbolo que podía quedar vacío.
- Se retiró la creación de categorías nuevas. Toda frase nueva se guarda directamente en Personal; los datos históricos se conservan y una selección antigua de categoría propia se migra visualmente a Personal.
- GitHub Actions run `31415280600`, job `93542716643`, pasó validadores, XcodeGen, XCTest, build Release, empaquetado y artifact.
- IPA verificada: `dist/Warm-Words-Sideloadly-settings-categories-build-16.ipa`, 6.033.570 bytes, SHA-256 `6B5ABC789662582D4FDDAA737F23D0BC837D8EB924098EDE081A60CC1CFE4CA8`.
- La inspección interna confirma ZIP/CRC, versión 1.0 build 16, ambos idiomas con 180 frases, AppIcon, Assets.car y PrivacyInfo. Falta comprobar en iPhone abrir/cerrar/reabrir Settings y la cuadrícula de categorías.

## Tarjeta compartible preparada en build 17

- Los dos `ShareLink` de texto fueron sustituidos por una tarjeta PNG dinámica de 1080 × 1350 y la hoja nativa de iOS. La composición reutiliza el fondo de montaña, paleta, tipografía, categoría localizada y marca aprobadas.
- La referencia visual aprobada y el contrato están en `docs/design/share-card/`; la imagen generada es solo referencia y no se empaqueta como contenido runtime.
- La app acepta el esquema local `warmwords` y valida la futura ruta HTTPS `https://krazel.github.io/warm-words/share/`.
- El enlace HTTPS permanece desactivado: la ruta pública y el AASA devuelven 404, y faltan Team ID, Apple ID de App Store, Associated Domains y firma compatible. Ninguna IPA comparte un enlace muerto.
- GitHub Actions run `31416957423`, job `93548147914`, pasó validadores, XcodeGen, XCTest, build Release, empaquetado y artifact.
- IPA de prueba visual: `dist/Warm-Words-Sideloadly-share-card-preview-build-17.ipa`, 6.058.270 bytes, SHA-256 `616680229730AB6B87AE647C3EFD9B45FB2AA0CB31B178D430C4155B1EBAB5AF`.
- Esta build permite probar la tarjeta como imagen. No es el cierre de la función de enlace inteligente ni reemplaza la build 16 como último candidato funcional cerrado.

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
