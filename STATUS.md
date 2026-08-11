# Estado de Inspiración Día

Actualizado: **2026-08-12**
Estado: **Warm Words 1.0 build 20 disponible en TestFlight interno; build 21 autorizada para corregir Ajustes, pendiente de CI/upload**
Propietario único de implementación: **esta tarea cerebro**
Fuente histórica: `docs/audit/IOS_CLOSEOUT_AUDIT.md`

## Fotografía actual

- Repositorio canónico: `https://github.com/Krazel/InspiracionDia`; el binario TestFlight se compiló desde el commit verificado `423da40`.
- El propietario autorizó expresamente la subida a TestFlight el 2026-08-10. No se creó release, no se envió a App Review y no se publicó en App Store.
- `.gitignore` modificado y `store/store-manifest.json` sin seguimiento siguen preservados; el manifest de tienda no se ha editado.
- Android permanece intacto y fuera de alcance.
- La app continúa con la navegación y el lenguaje visual existentes; no se añadió pantalla ni se abrió rediseño.
- App Store Connect contiene la ficha privada iOS 1.0 con Apple ID `6800058458`, SKU `com.dmkr.inspiraciondia` y bundle ID registrado `com.dmkr.inspiraciondia.B2X6D3A9J9`. Inglés (EE. UU.) permanece como idioma principal y Español (España) está añadido como localización completa.
- Apple rechazó el nombre exacto `Warm Words` por estar ya usado. La marca visible del binario sigue siendo `Warm Words`; la ficha usa `Warm Words: Daily Quotes` en inglés y `Warm Words: Frases Diarias` en español.
- La ficha guarda subtítulos, textos promocionales, descripciones, palabras clave, soporte y privacidad provisionales mediante GitHub, categorías Lifestyle / Health & Fitness, precio gratuito, disponibilidad en 175 países, ausencia de login y publicación manual. Esas URL provisionales ya no se consideran aptas para lanzamiento porque exponen infraestructura y las rutas dedicadas previstas siguen en 404. La distribución automática del binario iOS en Mac y Vision Pro está desactivada. No se añadió a App Review.
- App Store Connect muestra actualmente una clasificación global 4+ con excepciones regionales; se declaró que la app contiene temas generales de bienestar pero no información médica, contenido adulto, violencia, apuestas, UGC distribuido, chat, publicidad ni acceso web sin restricciones. También se declaró correctamente que no es un dispositivo médico regulado.
- App Privacy tiene guardada la respuesta “no se recopilan datos” y ambas URL de política, pero **no se pulsó Publicar**: queda preparada para el archive final, no publicada.
- El workflow manual `.github/workflows/build-ios-testflight.yml` ejecutó correctamente tests, Analyze, firma Apple Distribution, archive, inspección, exportación, validación y subida. Los siete secretos viven en el environment `app-store-production`, limitado a la rama iOS.
- La subida continúa desactivada por defecto y cualquier build futura necesita autorización expresa en el momento de activarla.
- TestFlight contiene Warm Words 1.0 build 20 en estado **En pruebas**, asignada al grupo interno `Warm Words Internal` con la cuenta propietaria como único tester. No se creó grupo externo ni se solicitó Beta App Review.
- `design/APPROVALS.md` es el manifiesto canónico de las imágenes completas aprobadas. Registra una maestra vigente por pantalla/estado cubierto, lienzo, orientación, idioma, fecha y SHA-256; separa propuestas, referencias retiradas, assets fuente y futuras capturas runtime/App Store.
- La auditoría canónica de minimización está en `docs/release/DATA_INVENTORY_1_0.md`. Build 20 usa solo frameworks Apple, no hace red, no incluye SDKs de terceros, publicidad, analítica, tracking, cuenta, nube, StoreKit ni compras. Solo pide notificaciones locales tras una acción explícita; preferencias, favoritos y frases personales permanecen en el iPhone.
- Los borradores públicos de privacidad, soporte y metadata ya separan el alias público de soporte del contacto privado de App Review y dejan vacíos los campos opcionales. No se publicará repositorio, incidencias, cuentas personales, domicilio, teléfono ni correo personal salvo obligación legal concreta.

## Enlace inteligente posterior a build 20

- El candidato implementa la generación de tarjeta PNG y URL específico versionado, pero mantiene el feature gate apagado hasta verificar la infraestructura. Las frases incluidas viajan por ID+idioma; las personales incluyen solo el texto normalizado dentro del fragmento `#`, de modo que GitHub Pages no lo recibe.
- Al abrir un enlace válido, Warm Words muestra una pantalla completa bilingüe basada en `WW-SCREEN-004`. Una frase incluida puede guardarse en Favoritos; una personal se importa, deduplica y marca favorita únicamente tras confirmación explícita.
- Se rechazan host, ruta, versión, ID, texto, longitud y caracteres de control inválidos. Si el primer onboarding sigue pendiente, la vista recibida se difiere hasta completarlo.
- El entitlement fuente para `applinks:krazel.github.io` está preparado, pero no se vincula al target ni se exige al perfil de build 21 mientras la landing/AASA no estén publicados. Associated Domains necesitará una build posterior y un perfil regenerado.
- La landing y las dos copias de AASA están preparadas únicamente en el repositorio local canónico `krazel.github.io`; no se han publicado. `ShareLinkRoute.isPublicLinkEnabled` permanece en `false` hasta que respondan 200, el CDN de Apple acepte AASA y la URL de App Store sea pública.
- Privacidad, soporte, inventario y QA describen el envío voluntario de imagen+enlace, la ausencia de backend y la limitación real: después de instalar desde la landing hay que volver al mensaje original y tocar el enlace otra vez.

## Corrección de Ajustes para build 21

- `TodayView` pasa a ser propietario del estado de su hoja de Ajustes y la presenta directamente desde su `NavigationStack`. Se elimina el binding y presenter remoto de `RootView`, que había vuelto a fallar en dispositivo.
- El cierre estático exige `TodayView()` sin binding, estado local `showingSettings` y presentación local de `SettingsView`; la puerta física sigue siendo abrir, cerrar y reabrir Ajustes en la build 21.
- Se conserva marketing version 1.0 porque es el tren existente anterior al primer lanzamiento público; la nueva combinación autorizada es **1.0 (21)**.

## Cierre implementado localmente

- Catálogos propios completos de 360 frases y 12 categorías en inglés y español, con los mismos IDs y orden. Incluyen 180 pares nuevos y 12 reescrituras editoriales que conservan IDs. No contienen citas atribuidas ni dependen de una fuente externa.
- El alcance solo inglés quedó sustituido por una app bilingüe: idioma inicial según el iPhone, selector persistente en Settings y cambio conjunto de interfaz, catálogo, categorías, fechas, días y próximas notificaciones. Favoritos y datos personales se conservan por ID y las frases creadas por el usuario no se traducen.
- Frase diaria basada en días continuos, sin reinicio por año.
- Recordatorio local sustituido por una cola de 60 notificaciones no repetitivas con una frase calculada por fecha; se refresca al activar la app y al cambiar hora, categorías o tarjetas. La autorización solo se pide tras una acción explícita.
- Hora configurada con `DatePicker`, migración estricta de la preferencia antigua y manejo de cambios DST mediante el calendario del sistema.
- Tarjetas propias: entrada vacía o categoría inválida no cierra la hoja; crear selecciona y persiste “Manual”; borrar exige confirmación y limpia favorito y notificaciones. Edición queda fuera de 1.0.
- Build 20 comparte una tarjeta visual PNG sin enlace. El candidato local posterior genera además el enlace específico, pero no puede distribuirse hasta que landing, AASA, entitlement y firma compatibles estén verificados.
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

- `node scripts/check-quotes.mjs`: 360 frases españolas y 360 inglesas, 30 por categoría, sin duplicados exactos/normalizados/casi idénticos y con paridad exacta de IDs, orden y categorías.
- `node scripts/check-ios-closeout.mjs`: idioma público, cola local, tarjetas, privacy manifest, proyecto y ausencia de release automática verificados estáticamente.
- `content.json`, `content-en.json`, `Info.plist` y `PrivacyInfo.xcprivacy` parsean correctamente.
- `project.yml` y el workflow parsean como YAML; el esquema incluye `InspiracionDiaTests`.
- `git diff --check` no detecta errores y `git diff --name-only -- android` queda vacío.
- La regeneración de ambos catálogos es byte a byte reproducible.
- El workflow TestFlight se valida como YAML manual sin eventos automáticos y no contiene secretos; su ejecución real depende de macOS, certificado, perfil y environment protegido.

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
- Build 17 añadió el esquema local `warmwords` y la validación inicial de la ruta HTTPS `https://krazel.github.io/warm-words/share/`; el candidato posterior añade el payload de frase y la recepción completa.
- En las IPA distribuidas hasta build 20 el enlace HTTPS permanece desactivado. La ruta pública y AASA seguían en 404 antes de preparar los archivos locales; la nueva capacidad Associated Domains y su perfil firmado aún deben configurarse y verificarse. Ninguna IPA distribuida comparte un enlace muerto.
- GitHub Actions run `31416957423`, job `93548147914`, pasó validadores, XcodeGen, XCTest, build Release, empaquetado y artifact.
- IPA de prueba visual: `dist/Warm-Words-Sideloadly-share-card-preview-build-17.ipa`, 6.058.270 bytes, SHA-256 `616680229730AB6B87AE647C3EFD9B45FB2AA0CB31B178D430C4155B1EBAB5AF`.
- Esta build permite probar la tarjeta como imagen. No es el cierre de la función de enlace inteligente ni reemplaza la build 16 como último candidato funcional cerrado.

## Catálogo ampliado y carril TestFlight verificados en build 19

- El catálogo de producción contiene ahora 360 frases propias en inglés y 360 en español, 30 por cada una de las 12 categorías. Se añadieron 180 pares bilingües y se reescribieron 12 pares débiles conservando sus IDs.
- Los validadores exigen paridad exacta EN/ES, IDs ordenados, longitudes editoriales y ausencia de duplicados exactos, normalizados o casi idénticos.
- Antes de la autorización de TestFlight, el workflow manual ya estaba preparado con XCTest, Analyze, archive Apple Distribution, inspección, exportación App Store Connect y subida desactivada por defecto.
- GitHub Actions run `31424514733` (número 19), job `93572928211`, commit `4ba5de9`, pasó Xcode/SDK 26+, validadores, XcodeGen, XCTest, build Release unsigned, empaquetado y artifact el 2026-08-10.
- Los actions de checkout y artifact usan sus versiones Node 24 actuales. Solo queda un aviso no bloqueante de Homebrew sobre un tap ajeno preinstalado en el runner.
- IPA descargada y verificada: `dist/Warm-Words-Sideloadly-360-quotes-build-19.ipa`, 6.071.590 bytes, SHA-256 `0AE98F3D420FD9B50D5A0F00D2E35B1293DD446943B1582B1CE2E25C964DB3B6`.
- La inspección interna confirma ZIP válido, ambos catálogos con 360 frases y 12 categorías, AppIcon, `Assets.car` y `PrivacyInfo.xcprivacy`. Sigue siendo unsigned y no es una subida a TestFlight.

## TestFlight interno activo — build 20

- El propietario autorizó expresamente firma, secretos protegidos y subida el 2026-08-10.
- Apple Developer emitió el certificado Apple Distribution y el perfil `Warm Words App Store 2026`, ambos válidos hasta el 2027-08-10. La clave de App Store Connect tiene rol Gestor de apps.
- El environment `app-store-production` contiene siete secretos cifrados y está restringido a `agent/warm-words-ios-ipa`; no se guardó material sensible en el repositorio y las copias temporales locales fueron eliminadas.
- GitHub Actions run `31429710903`, job `93589855913`, commit `423da40`, completó tests, Analyze, instalación de firma, archive, `codesign`, inspección de recursos/versión/bundle, exportación, validación y subida.
- Artifact firmado efímero `Warm-Words-TestFlight-v1.0-build-20`: 6.220.816 bytes, SHA-256 `B789F43C3CD25E9024CE9DEEB45834FACCF99EC6B1D380F42D1EB6694EFE8976`, con caducidad de tres días.
- Apple procesó Warm Words 1.0 build 20. El grupo interno `Warm Words Internal` contiene una build y la cuenta propietaria como único tester; el estado visible es **En pruebas** y caduca en 90 días.
- “Qué se debe probar” está guardado en inglés. No hay testers externos, Beta App Review, App Review ni publicación.

## Primer bloqueo material de App Store

El nombre público **Warm Words**, el AppIcon **C — Protected thought** y la decisión de usar un catálogo editorial propio ya están cerrados localmente. La primera puerta material restante es conservar la trazabilidad editorial del catálogo y confirmar por escrito la autoría/licencia comercial de `premium-mountains.png` y `premium-stones.png`. Recomendación: no preparar un envío a App Review hasta disponer de esa confirmación y sustituir cualquier recurso sin derechos claros.

## Puertas restantes

1. Instalar build 20 desde TestFlight y completar QA real en iPhone/iOS 16 e iOS 26.
2. Confirmar derechos comerciales de frases, fondos y AppIcon.
3. Crear un alias exclusivo de soporte y publicar las páginas propias de privacidad/soporte; ambas rutas previstas devolvían 404 el 2026-08-11. Después, sustituir las URL provisionales de la ficha y publicar App Privacy solo con autorización.
4. Preparar capturas inglesas y españolas, copyright mínimo exigido y contacto privado de revisión.
5. Confirmar verazmente el estado DSA trader antes de distribuir en la UE; no ocultar una obligación ni publicar datos adicionales si no corresponde.
6. Revisar el candidato con el propietario. Testers externos, App Review y publicación siguen necesitando autorización expresa adicional.

El apoyo voluntario en Settings queda planificado para una fase posterior y no bloquea este candidato. Implementarlo requerirá StoreKit, productos mensuales en App Store Connect, restauración de compras, términos y privacidad; no se crearán ni enviarán productos sin autorización expresa.

## Limitación aceptada del MVP local

Sin servidor ni ejecución en segundo plano garantizada, la cola de recordatorios cubre aproximadamente 60 días. Se renueva al abrir o activar la app; si el usuario no la abre durante ese periodo, puede agotarse. Un cambio de zona horaria también se corrige al siguiente uso de la app.
