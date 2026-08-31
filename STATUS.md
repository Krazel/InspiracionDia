# Estado de Inspiración Día

Actualizado: **2026-08-31**
Estado: **Warm Words 1.0 build 29 válida y disponible en TestFlight interno; cierre automatizado superado**
Propietario único de implementación: **esta tarea cerebro**
Fuente histórica: `docs/audit/IOS_CLOSEOUT_AUDIT.md`

## Fotografía actual

- Repositorio canónico: `https://github.com/Krazel/InspiracionDia`; build 29 se compiló desde el commit verificado `1d2b36c`.
- El propietario autorizó expresamente commit, push, compilación, firma y subida de build 25 a TestFlight el 2026-08-24. No se creó release, no se envió a App Review y no se publicó en App Store.
- El propietario autorizó expresamente el 2026-08-24 commit, push, compilación, firma y subida interna del candidato ampliado como **1.0 (26)**. Esta autorización no comprende testers externos, App Review ni publicación pública.
- El propietario autorizó expresamente el 2026-08-31 corregir la regresión de rendimiento de build 26, hacer commit/push y compilar, firmar, subir y asignar **1.0 (27)** a TestFlight interno. No autorizó App Review ni publicación pública.
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
- TestFlight conserva builds anteriores en el grupo interno. Apple marcó build 24 como `VALID` y el workflow run `32175849335` verificó su asignación a `Warm Words Internal` el 2026-08-18; no se creó grupo externo ni se solicitó Beta App Review.
- Apple procesó build 25 como `VALID`; run `32753132327` confirmó su asignación a `Warm Words Internal` el 2026-08-24. No se creó grupo externo ni se solicitó Beta App Review.
- Artifact efímero `Warm-Words-TestFlight-v1.0-build-25`: 6.360.186 bytes, SHA-256 de artifact `4cfa215c7b03ef0d7ab5fb37a08ea995d13df8928923838f0d0c7d3c4b8b7eb7`, caducidad 2026-08-27.
- El commit `b629bcd` amplió el catálogo a 720 pares bilingües. Run `32765814357` compiló y subió **1.0 (26)**: 38 tests sin fallos, Analyze Release, firma, archive, inspección y exportación correctos; App Store Connect respondió `UPLOAD SUCCEEDED with no errors`.
- Apple procesó build 26 como `VALID`; run `32766825710` confirmó su asignación a `Warm Words Internal` el 2026-08-24. No se creó grupo externo, no se solicitó Beta App Review y no se envió a App Review.
- Artifact efímero `Warm-Words-TestFlight-v1.0-build-26`: 6.387.788 bytes, SHA-256 `15d24eefb527a3bb718ccaaead007094089290ff085716a396b051f6914b462e`, caducidad 2026-08-27.
- El commit `484ca3d` corrigió la regresión de rendimiento sin modificar diseño ni contenido. Run `33341160940` compiló y subió **1.0 (27)**: 40 tests sin fallos, Analyze Release, firma, archive, inspección, exportación y validación correctos; App Store Connect respondió `UPLOAD SUCCEEDED with no errors`.
- Apple procesó build 27 como `VALID`; run `33341523935` confirmó su asignación a `Warm Words Internal` el 2026-08-31. No se creó grupo externo, no se solicitó Beta App Review y no se envió a App Review.
- Artifact efímero `Warm-Words-TestFlight-v1.0-build-27`: 6.397.420 bytes, SHA-256 `251d8ec54c328acad49f958b0bf963b0ab47aba3737686425278345823c45cb7`, caducidad 2026-09-02.
- El commit `1d2b36c` cerró la última revisión para **1.0 (29)**. Run `33399920401` pasó 41 pruebas de lógica y 2 pruebas UI sin fallos, Analyze Release, firma, archive, inspección, exportación y validación; App Store Connect respondió `UPLOAD SUCCEEDED with no errors`.
- Apple procesó build 29 como `VALID`; run `33401009451` confirmó su asignación a `Warm Words Internal` el 2026-08-31. Artifact `Warm-Words-TestFlight-v1.0-build-29`: 6.407.143 bytes, SHA-256 `1392d2ee7bed433912f7b26699b7c7a216de19c018126c82a6a4b259f25ade7d`.
- `design/APPROVALS.md` es el manifiesto canónico de las imágenes completas aprobadas. Registra una maestra vigente por pantalla/estado cubierto, lienzo, orientación, idioma, fecha y SHA-256; separa propuestas, referencias retiradas, assets fuente y futuras capturas runtime/App Store.
- La auditoría canónica de minimización está en `docs/release/DATA_INVENTORY_1_0.md`. Build 25 usa solo frameworks Apple, no hace red, no incluye SDKs de terceros, publicidad, analítica, tracking, cuenta, nube, StoreKit ni compras. Solo pide notificaciones locales tras una acción explícita; preferencias, favoritos, frases personales e historial del ciclo permanecen en el iPhone.
- Los borradores públicos de privacidad, soporte y metadata ya separan el alias público de soporte del contacto privado de App Review y dejan vacíos los campos opcionales. No se publicará repositorio, incidencias, cuentas personales, domicilio, teléfono ni correo personal salvo obligación legal concreta.

## Catálogo ampliado entregado en build 26

- El propietario pidió ampliar el catálogo para que seleccionar una sola categoría no produzca una repetición al cabo de 30 días. El nuevo objetivo queda en 60 pares por categoría: 720 frases inglesas y 720 españolas.
- Los 360 pares añadidos están repartidos entre 12 categorías, mantienen IDs paralelos `031–060` y pasaron dos revisiones editoriales por grupo más una revisión integrada del catálogo completo.
- Las fuentes canónicas `data/quotes.js` y `data/quotes-en.js` y los recursos runtime se regeneraron de forma determinista. El validador exige 720 elementos por idioma, 60 por categoría, longitudes de 32–138 caracteres, paridad exacta y ausencia de duplicados o solapamientos altos.
- Este cambio no altera pantallas, navegación, persistencia, permisos, privacidad, SDKs ni Android. Build 26 está procesada como válida y disponible para el grupo interno de TestFlight.

## Corrección de rendimiento entregada en build 27

- La causa principal era que Categorías construía inmediatamente hasta 720 `QuoteCard` cuando estaba seleccionado `All`. La lista conserva idéntico aspecto y pasa a `LazyVStack`, por lo que solo crea las tarjetas cercanas al área visible.
- `QuoteCyclePlanner.sequence` ordenaba y deduplicaba los 720 IDs en cada una de las 60 iteraciones de la cola. Ahora calcula el orden una vez y conserva exactamente la misma secuencia y regla sin repetición.
- Al volver la app a primer plano se volvían a registrar hasta 60 notificaciones aunque ya fueran idénticas. Ahora se comparan identificador, título, cuerpo y fecha y solo se añaden solicitudes nuevas o modificadas.
- Se añadieron pruebas para el planificador con 720 candidatos y para el orden persistido, y el cierre estático exige las tres protecciones. No cambia UI, contenido, permisos, datos, privacidad ni Android.
- GitHub Actions run `33341160940` pasó 40 tests y el análisis Release, generó y validó el IPA firmado y lo subió sin errores. Apple marcó build 27 como `VALID` y run `33341523935` la asignó al grupo interno.

## Corrección de Ajustes entregada en build 28

- La comprobación del código y una auditoría independiente descartan que el engranaje tenga un área táctil pequeña o una vista superpuesta: el fallo estaba en compartir un único estado `fullScreenCover(item:)` entre Ajustes y los enlaces recibidos.
- Si iOS rechazaba la presentación durante la transición final del onboarding o de la alerta de notificaciones, el estado podía quedar fijado en `settings`; los toques posteriores escribían el mismo valor y SwiftUI no volvía a intentar abrirlo.
- Ajustes usa ahora una ruta de navegación propiedad de la raíz. Las frases compartidas conservan una portada independiente y se difieren mientras Ajustes está abierto. El encabezado permanece por encima de la tarjeta sin cambiar su aspecto.
- Se añadió un target XCUITest que completa el onboarding si hace falta, pulsa el engranaje, exige `settings-screen`, cierra y vuelve a abrir Ajustes. Run `33347733817` pasó 40 tests de lógica y la prueba UI real `testSettingsButtonOpensClosesAndReopensSettings`, además de Analyze, firma, archive, exportación, validación y subida sin errores.
- Apple procesó build 28 como `VALID`; run `33348245753` la asignó a `Warm Words Internal` el 2026-08-31. Artifact `Warm-Words-TestFlight-v1.0-build-28`: 6.398.764 bytes, SHA-256 `8257a9dffb32633ce1a1c2e56ce5b6ff504beee74bf90a4bb067096dbf8aae3d`, caducidad 2026-09-03.

## Cierre final entregado en build 29

- La categoría estable `animo` conserva IDs, historial, favoritos y preferencias, pero pasa a mostrarse explícitamente como `Motivation` en inglés y `Motivación` en español. Contiene 60 frases en cada idioma; el catálogo completo conserva 720 por idioma y 12 categorías.
- La prueba de notificación ya no presenta como entrega un simple registro aceptado. Programa un identificador propio y único a cinco segundos, comprueba que la solicitud queda pendiente, detecta permisos/alertas y Resumen programado, y confirma la recepción cuando iOS presenta la notificación en primer plano.
- Favoritos usa carga diferida igual que Categorías, evitando construir cientos de tarjetas fuera de pantalla. En Ajustes se eliminó el texto auxiliar de recomendación de todas las categorías sin alterar el onboarding.
- La nueva prueba UI abre Categorías, exige `Motivation`, la selecciona y verifica su estado. Se conserva la prueba que abre, cierra y vuelve a abrir Ajustes.
- Run `33399920401` completó 41 pruebas unitarias y 2 UI, Analyze, firma, archive, exportación, validación y subida. Apple marcó build 29 como `VALID`; run `33401009451` la asignó al grupo interno.
- La entrega visual de notificaciones sigue necesitando una comprobación física en iPhone con la app abierta y en segundo plano. Focus, Resumen programado o alertas desactivadas pueden cambiar dónde y cuándo la muestra iOS; la app ahora informa de los estados detectables.

## Enlace inteligente posterior a build 20

- El candidato implementa la generación de tarjeta PNG y URL específico versionado, pero mantiene el feature gate apagado hasta verificar la infraestructura. Las frases incluidas viajan por ID+idioma; las personales incluyen solo el texto normalizado dentro del fragmento `#`, de modo que GitHub Pages no lo recibe.
- Al abrir un enlace válido, Warm Words muestra una pantalla completa bilingüe basada en `WW-SCREEN-004`. Una frase incluida puede guardarse en Favoritos; una personal se importa, deduplica y marca favorita únicamente tras confirmación explícita.
- Se rechazan host, ruta, versión, ID, texto, longitud y caracteres de control inválidos. Si el primer onboarding sigue pendiente, la vista recibida se difiere hasta completarlo.
- El entitlement fuente para `applinks:krazel.github.io` está preparado, pero no se vincula al target ni se exige al perfil de build 23 mientras la landing/AASA no estén publicados. Associated Domains necesitará una build posterior y un perfil regenerado.
- La landing y las dos copias de AASA están preparadas únicamente en el repositorio local canónico `krazel.github.io`; no se han publicado. `ShareLinkRoute.isPublicLinkEnabled` permanece en `false` hasta que respondan 200, el CDN de Apple acepte AASA y la URL de App Store sea pública.
- Los documentos de privacidad, soporte, inventario y QA describen exactamente build 25: comparte únicamente la imagen. El enlace inteligente sigue siendo una puerta posterior y no se anuncia como activo.

## Onboarding de intereses y corrección definitiva de Ajustes para build 22

- Una instalación limpia muestra hora, días y las 12 categorías incluidas en el mismo onboarding. `All categories` está activo por defecto; tocar una categoría pasa a modo específico y permite retirar intereses. No se puede confirmar un recordatorio activo sin días o sin una categoría específica válida.
- El guardado inicial persiste las mismas preferencias locales que Settings y solo marca el onboarding como completado después de validar el recordatorio.
- El engranaje ya no depende de ninguna hoja modal ni booleano: es un `NavigationLink` nativo en el `NavigationStack` de Today. `SettingsView` no anida otro stack, oculta la navegación/tab bar de sistema y su chevrón hace pop con `dismiss()`.
- El cierre estático rechaza que vuelvan `showingSettings` o la hoja de Settings y exige la ruta y los identificadores de accesibilidad. La puerta física es abrir → volver → reabrir, también después de cambiar de pestaña.
- Se conserva marketing version 1.0 porque es el tren existente anterior al primer lanzamiento público; la nueva combinación autorizada es **1.0 (22)**.
- GitHub Actions run `31607436785`, job `94149911543`, commit `b3de5b0`, completó **27 tests sin fallos**, Analyze, firma, archive, inspección, exportación y upload. Apple respondió `No errors uploading archive`.

## Cambio incluido en build 23 — onboarding de dos pasos

- El propietario indicó que las categorías no resultaban visibles en el onboarding combinado. El flujo local abre ahora un paso 1 exclusivo para las 12 categorías, todas activas por defecto, y después un paso 2 con la hora y los días existentes.
- `Continue` solo conserva el borrador; no guarda, no programa y no solicita permiso. `Back` conserva intereses y `Set reminder` confirma conjuntamente categorías, hora y días.
- El selector canoniza de nuevo a `All categories` al reactivar las 12. Una selección específica vacía no puede avanzar y un catálogo vacío tampoco.
- La persistencia se ordenó para que el onboarding se marque completado antes de solicitar/programar notificaciones; `Not now` persiste primero el recordatorio apagado.
- El onboarding sigue en versión `1`: las actualizaciones no lo repiten. Para probar este cambio hay que borrar datos e instalar limpio.
- La nueva maestra `WW-SCREEN-002A` y la pantalla horaria reactivada `WW-SCREEN-002B` están registradas en `design/APPROVALS.md`. La pantalla combinada anterior se conserva como reemplazada.
- No se han añadido red, datos recopilados, permisos, SDKs ni assets de ejecución.
- GitHub Actions run `32163428876`, job `95797362914`, compiló el commit `6993c92` como **1.0 (23)**. Pasó 29 tests sin fallos, Analyze Release, archive firmado, inspección, exportación y upload. Apple respondió `No errors uploading archive`.

## Cierre implementado localmente

- Build 26 contiene 720 frases propias en inglés y 720 en español, 60 por cada una de las 12 categorías y con los mismos IDs y orden. La ampliación añade 360 pares bilingües y lleva a la fuente canónica 16 reescrituras editoriales de IDs existentes. No contiene citas atribuidas ni depende de una fuente externa. Build 25 conserva históricamente el catálogo anterior de 360 por idioma.
- El alcance solo inglés quedó sustituido por una app bilingüe: idioma inicial según el iPhone, selector persistente en Settings y cambio conjunto de interfaz, catálogo, categorías, fechas, días y próximas notificaciones. Favoritos y datos personales se conservan por ID y las frases creadas por el usuario no se traducen.
- Frase diaria basada en días continuos, sin reinicio por año.
- Recordatorio local sustituido por una cola de 60 notificaciones no repetitivas con una frase calculada por fecha; se refresca al activar la app y al cambiar hora, categorías o tarjetas. La autorización solo se pide tras una acción explícita.
- Hora configurada con `DatePicker`, migración estricta de la preferencia antigua y manejo de cambios DST mediante el calendario del sistema.
- Tarjetas propias: entrada vacía o categoría inválida no cierra la hoja; crear selecciona y persiste “Manual”; borrar exige confirmación y limpia favorito y notificaciones. Edición queda fuera de 1.0.
- Builds 20, 21, 22 y 23 comparten la tarjeta visual PNG sin enlace. El código contiene la implementación específica bajo un feature gate apagado; no puede activarse hasta que landing, AASA, entitlement y firma compatibles estén publicados y verificados.
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

- `node scripts/check-quotes.mjs`: 720 frases españolas y 720 inglesas, 60 por categoría, sin duplicados exactos/normalizados/casi idénticos y con paridad exacta de IDs, orden y categorías.
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
- En las IPA distribuidas hasta build 21 el enlace HTTPS permanece desactivado. La ruta pública y AASA seguían en 404 antes de preparar los archivos locales; la nueva capacidad Associated Domains y su perfil firmado aún deben configurarse y verificarse. Ninguna IPA distribuida comparte un enlace muerto.
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

## TestFlight build 21 subida

- El primer intento run `31547083020` se detuvo antes de firma por una única expectativa de test sobre cómo Foundation representa la barra final de `URL.path`; 23 de 24 tests pasaron y Apple no recibió ese intento.
- La expectativa se corrigió sin cambiar el comportamiento del enlace. El run final `31547517180` pasó los 24 tests y todas las puertas de firma, archive, exportación, validación y upload.
- Apple aceptó el upload de Warm Words 1.0 (21). El procesamiento y la asignación visible al grupo interno pueden tardar; no se afirma todavía que esté instalable hasta verificarlo en TestFlight/App Store Connect.
- “Qué se debe probar” está guardado en inglés. No hay testers externos, Beta App Review, App Review ni publicación.

## TestFlight build 22 subida

- El run `31607436785` compiló exactamente el commit `b3de5b0` con build number 22. Pasó 27 tests, Analyze Release, archive firmado, inspección del archive y exportación de la IPA.
- Apple aceptó el upload de Warm Words 1.0 (22) sin errores de transporte. El procesamiento posterior de TestFlight puede tardar; no se afirma todavía que esté instalable hasta que aparezca en la aplicación.
- Esta build incluye el onboarding con categorías y la navegación nativa de Ajustes. Para probar el onboarding hay que borrar la app/datos e instalar limpio; una actualización conserva correctamente el onboarding ya completado.
- No se activaron Universal Links, testers externos, Beta App Review, App Review ni publicación.

## TestFlight build 23 subida

- El propietario autorizó expresamente publicar el commit y subir Warm Words 1.0 (23) el 2026-08-18.
- El run `32163428876` pasó 29 tests, Analyze, archive firmado, inspección, exportación y entrega a Apple sin errores.
- Esta build contiene el onboarding de dos pasos. Para verlo hay que borrar la app y sus datos antes de instalar, porque las actualizaciones conservan correctamente el onboarding ya completado.
- Apple la marcó como `VALID` y el run `32173244154` confirmó que está asignada al grupo interno `Warm Words Internal`. No se activaron testers externos, Beta App Review, App Review, Universal Links ni publicación.

## TestFlight build 24 asignada

- El propietario aprobó simplificar las dos pantallas del primer inicio y autorizó expresamente commit, push, firma y subida a TestFlight el 2026-08-18.
- La primera pantalla ya no muestra indicadores de paso, `Quote categories`, la explicación de selección predeterminada ni `Not now`. Mantiene las 12 categorías activas y usa `What would help you today?` / `¿Qué te ayudaría hoy?`.
- La segunda pantalla ya no muestra indicador de paso y conserva hora, días, `Back` y `Not now`.
- El run `32174725981` compiló el commit `971c5d0` como **1.0 (24)**, pasó 29 tests sin fallos, Analyze, firma, archive, inspección, exportación y upload. Apple respondió `UPLOAD SUCCEEDED with no errors`.
- Apple marcó la build como `VALID` y el run `32175849335` verificó su asignación a `Warm Words Internal`.

## Corrección local posterior a build 24 — Ajustes y frases sin repetición

- El engranaje de Today ya no usa un `NavigationLink` anidado dentro de `TabView`. Es un botón táctil de 52 × 52 pt que entrega la acción a `RootView`; la raíz presenta Ajustes mediante una única ruta modal de pantalla completa, compartida de forma segura con la recepción de frases enlazadas.
- `TodayView` deja de crear su propio `NavigationStack`, eliminando el punto frágil que podía hacer que el toque se perdiera en la jerarquía real del iPhone. Abrir, cerrar y reabrir Ajustes sigue siendo una puerta obligatoria de QA físico.
- Today ahora usa únicamente las frases pertenecientes a las categorías de entrega seleccionadas. El historial se conserva por ID estable en el dispositivo y sobrevive a cierres, reinicios y cambios entre inglés y español.
- El selector ofrece primero todas las frases elegibles aún no vistas. Solo cuando se agotan elige la elegible menos recientemente mostrada; por tanto, no empieza un nuevo ciclo hasta completar el conjunto activo.
- Today y la cola de notificaciones comparten las asignaciones persistentes. Una frase prevista para el día se reutiliza como la tarjeta de ese día y se registra al vencer, evitando que la reprogramación reinicie el ciclo.
- Añadir o borrar una frase Personal, cambiar categorías o desactivar/denegar notificaciones sanea el historial y las reservas sin borrar favoritos ni frases válidas. No se añade red, SDK, permiso ni recopilación de datos.
- Validación Windows: `check-ios-closeout`, `check-quotes`, `git diff --check` y ausencia de cambios Android pasan. GitHub Actions run `32751996787` ejecutó **38 tests sin fallos**, Analyze Release, firma, archive, inspección, exportación y upload; Apple respondió `UPLOAD SUCCEEDED with no errors`.
- `.gitignore` modificado y `store/store-manifest.json` sin seguimiento permanecen preservados y no forman parte de los commits.

La auditoría de publicación vigente está en `docs/audit/IOS_RELEASE_READINESS_AUDIT_2026-08-24.md`: build 25 es suficiente para TestFlight interno y el catálogo ampliado queda preparado localmente para build 26. App Review sigue bloqueada por QA físico, privacidad/soporte públicos e internos, capturas, campos obligatorios, derechos y el enlace inteligente aprobado.

## Primer bloqueo material de App Store

El nombre público **Warm Words**, el AppIcon **C — Protected thought** y la decisión de usar un catálogo editorial propio ya están cerrados localmente. La primera puerta material restante es conservar la trazabilidad editorial del catálogo y confirmar por escrito la autoría/licencia comercial de `premium-mountains.png` y `premium-stones.png`. Recomendación: no preparar un envío a App Review hasta disponer de esa confirmación y sustituir cualquier recurso sin derechos claros.

## Puertas restantes

1. Instalar build 29 desde TestFlight en limpio y completar QA físico: onboarding de categorías → hora/días → Today; abrir/cerrar/reabrir Ajustes; seleccionar Motivation; probar la notificación con la app abierta y en segundo plano; comprobar además alertas, Focus y Resumen programado de iOS.
2. Confirmar derechos comerciales de frases, fondos y AppIcon.
3. Crear un alias exclusivo de soporte y publicar las páginas propias de privacidad/soporte; ambas rutas previstas devolvían 404 el 2026-08-11. Después, sustituir las URL provisionales de la ficha y publicar App Privacy solo con autorización.
4. Preparar capturas inglesas y españolas, copyright mínimo exigido y contacto privado de revisión.
5. App Store Connect ya identifica al desarrollador como trader para esta app; comprobar que la información verificada que Apple publicará en la UE sigue siendo correcta.
6. Revisar el candidato con el propietario. Testers externos, App Review y publicación siguen necesitando autorización expresa adicional.

El apoyo voluntario en Settings queda planificado para una fase posterior y no bloquea este candidato. Implementarlo requerirá StoreKit, productos mensuales en App Store Connect, restauración de compras, términos y privacidad; no se crearán ni enviarán productos sin autorización expresa.

## Limitación aceptada del MVP local

Sin servidor ni ejecución en segundo plano garantizada, la cola de recordatorios cubre aproximadamente 60 días. Se renueva al abrir o activar la app; si el usuario no la abre durante ese periodo, puede agotarse. Un cambio de zona horaria también se corrige al siguiente uso de la app.
