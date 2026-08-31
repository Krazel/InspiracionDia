# Decisiones de Inspiración Día

Actualizado: **2026-08-11**

Este archivo separa decisiones aprobadas de decisiones materiales todavía pendientes. Las elecciones reversibles y técnicas corresponden al cerebro de producto; solo una decisión material se eleva cada vez, con una recomendación única.

## Decisiones aprobadas

### DEC-001 — iOS es la única plataforma activa

- iOS se desarrolla y cierra primero.
- Android no se desarrolla, mantiene, corrige, compila ni sincroniza hasta petición expresa futura.
- La carpeta Android se preserva como legado.

### DEC-002 — Lanzamiento 1.0 provisionalmente solo en inglés (sustituida)

- Interfaz pública, contenido, capturas y ficha de App Store deben estar en inglés.
- El español existente se conserva sin mantenimiento y no se expone en 1.0.
- Esta decisión histórica queda sustituida por `DEC-022` tras la petición expresa de una app bilingüe.

### DEC-003 — Cierre sin rediseño

- Se conserva la experiencia visual existente.
- Accesibilidad, cumplimiento y correcciones puntuales no abren un rediseño.

### DEC-004 — Visual-first para trabajo visual nuevo

- Toda pantalla nueva o rediseño necesita imagen completa y aprobación explícita antes de implementarse.
- El AppIcon necesita dirección visual aprobada antes de incorporarse.
- La aprobación visual bloquea solo el resultado visual final. Lógica, datos, arquitectura, navegación interna, persistencia, tests, build/CI, privacidad, tienda y documentación continúan en paralelo.
- Los prototipos previos deben marcarse como provisionales y no fijan layout, arte, icono, capturas, animación principal ni experiencia visual final.

### DEC-005 — Un único propietario de implementación

- Esta tarea cerebro es la propietaria de los cambios iOS del hito.
- Especialistas trabajan en solo lectura o en entregables no solapados e informan al cerebro.

### DEC-006 — Contexto durable en el repositorio

- `AGENTS.md` gobierna el trabajo; `STATUS.md` conserva estado y siguiente paso; `DECISIONS.md` conserva decisiones.
- `docs/audit/IOS_CLOSEOUT_AUDIT.md` permanece como fotografía histórica de AUD-001.

### DEC-007 — Repositorio canónico y cambios protegidos

- GitHub canónico: `https://github.com/Krazel/InspiracionDia`.
- `.gitignore` modificado y `store/store-manifest.json` sin seguimiento se preservan hasta una decisión expresa sobre ellos.

### DEC-008 — Publicación siempre requiere autorización

- No se permite commit, push, release, TestFlight, App Store, App Review ni publicación sin autorización expresa para esa acción.
- Una IPA unsigned es solo un artefacto de QA.

### DEC-009 — Autonomía del cerebro de producto

- El cerebro piensa el producto, decide lo reversible, crea y coordina trabajo especializado, integra resultados y avanza hasta el MVP sin esperar microtareas.
- Las tareas auxiliares informan al cerebro, no al usuario.
- El cerebro deja resultados y decisiones en su propia tarea; no envía mensajes espontáneos ni abre turnos de Brain general. Brain los consulta en el siguiente momento natural.
- Solo se eleva la primera decisión material que necesite sí, no o corrección, siempre con una recomendación única.
- Tras una aprobación visual, el trabajo continúa automáticamente sin requerir otra orden.
- Esta autonomía no permite publicar, contratar servicios ni aceptar contratos.

### DEC-010 — Alcance funcional de cierre 1.0

Resuelve las antiguas PEND-002 a PEND-007:

- Catálogo bilingüe completo de 360 pares, con IDs idénticos en inglés y español.
- El antiguo cierre en inglés fijo queda sustituido por el alcance bilingüe de `DEC-022`.
- Notificación local con una frase distinta por fecha y cola conservadora de 60 días.
- Compartir mediante tarjeta visual; el enlace inteligente queda desactivado hasta disponer de landing y Universal Links reales.
- Tarjetas propias con crear, validar y borrar; edición pospuesta.
- iPhone-only para 1.0.

Son elecciones reversibles y de cierre mínimo adoptadas por el cerebro bajo el contrato de autonomía.

### DEC-011 — Canal de CI sin publicación automática

Resuelve la antigua PEND-013:

- GitHub Actions puede compilar y probar un artifact unsigned efímero de QA.
- El workflow no crea ni actualiza GitHub Releases y usa permisos `contents: read`.
- No se borra la release remota histórica existente.
- Archive firmado, TestFlight y App Store pertenecen a un canal posterior y expresamente autorizado.

### DEC-012 — Privacidad y configuración técnica provisional

- Se declara `UserDefaults` con required reason `CA92.1` y no se observa recogida de datos ni tracking en el código iOS actual.
- `ITSAppUsesNonExemptEncryption=false` es provisional hasta inspeccionar el archive final.
- Firma automática sin team embebido, iPhone portrait y Xcode/iOS SDK 26+ son la base técnica de cierre.

### DEC-013 — El nombre público de 1.0 debe estar en inglés

- La aprobación anterior de “Inspiración Día” como nombre público queda retirada por corrección expresa del propietario.
- “Inspiración Día” se conserva únicamente como nombre interno histórico del proyecto y del repositorio.
- `Versemorn` fue rechazado expresamente y `A Quiet Spark` quedó sustituido por la petición de algo más simple.
- El propietario aprobó por contexto **Warm Words** como nombre público inglés el 2026-08-09; “War Wars” se interpreta como una errata salvo corrección posterior.
- `Warm Words` es el nombre visible en la app, compartir y notificaciones. Como Apple indicó que el nombre exacto ya estaba usado, la ficha inglesa utiliza `Warm Words: Daily Quotes` y la española `Warm Words: Frases Diarias`.
- El nombre interno de target, módulo, esquema, bundle ID, repositorio y artefactos continúa como `InspiracionDia` para evitar riesgo técnico innecesario.

### DEC-014 — Base de compilación y concurrencia

- Xcode 26 compilará el proyecto en modo de lenguaje Swift 5 (`SWIFT_VERSION: "5.0"`); `5.9` no es un modo válido de Xcode.
- El estado observable de la app pertenece al actor principal y UserNotifications usa las APIs async/await disponibles desde iOS 15.
- El target de tests conserva un bundle ID propio y la app mantiene deployment target iOS 16.

### DEC-015 — Preparación de tienda reversible

- Recomendación de ficha: categoría primaria Lifestyle, secundaria Health & Fitness, precio gratuito y liberación manual.
- Copy, privacidad, soporte y checklist QA se preparan localmente con placeholders; no se hospedan ni cargan sin autorización y datos reales del propietario.
- Las capturas usan solo la interfaz inglesa existente después de aprobar nombre e icono y superar QA del build firmado.

### DEC-016 — AppIcon C aprobado e integrado

- El propietario aprobó explícitamente **C — Protected thought** el 2026-08-09.
- La fuente de revisión es `docs/design/app-icon/warm-words-app-icon-proposal-c.png`.
- El asset final `native-ios/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` es una exportación determinista RGB opaca de 1024×1024 de la imagen aprobada, sin cambiar composición, color ni contenido.
- XcodeGen usa el catálogo `AppIcon`; CI y los validadores locales comprueban el asset y su empaquetado.
- A v2, B y el borrador A se conservan únicamente como historial visual.

### DEC-017 — IPA unsigned autorizada para Sideloadly

- El propietario autorizó expresamente commit, push y compilación el 2026-08-09 para obtener una IPA instalable mediante Sideloadly.
- Se usó la rama aislada `agent/warm-words-ios-ipa`; `main` no se modificó.
- GitHub Actions run `31329591743` compiló y probó el commit de app `1c62729`; el artifact se descargó como `dist/Warm-Words-Sideloadly.ipa`.
- Esta autorización no incluye GitHub Release, TestFlight, App Store, App Review ni publicación.

### DEC-018 — Alcance solicitado para recordatorios y categorías personales

- El propietario pidió retirar de Today “Thoughtful quotes”, “Easy to share”, “One each day” y “Explore categories”; no se añade reemplazo promocional.
- El primer arranque propondrá un recordatorio a las 07:30 con los siete días seleccionados y todos recomendados. El permiso de iOS solo se solicita tras confirmación explícita.
- Settings editará recordatorio, hora, días y categorías como borrador y aplicará todo una vez al guardar.
- Una categoría personal se crea junto con su primera frase, con nombre único de hasta 24 caracteres y estilo neutro automático; no se abre gestión avanzada.
- Las frases personales ya se comparten como texto mediante el Share sheet de iOS. Se descartan cuentas, servidor, importación y tarjeta-imagen por no ser cierre simple.
- El propietario añadió que Today debe caber sin desplazamiento; se reducirá la tarjeta y el espacio interno sin cambiar sus funciones.

### DEC-019 — Set visual 1.1 aprobado y continuidad automática

- El propietario aprobó el 2026-08-09 las cuatro propuestas completas de `docs/design/reminder-v2/`: Today compacto, onboarding, Settings y nueva categoría inline.
- No pidió ajustes. Se permite adaptar tamaños y controles para Dynamic Type, VoiceOver y límites reales de SwiftUI sin cambiar la dirección aprobada.
- El propietario autorizó continuar hasta aplicación completa, tests y nueva IPA sin más preguntas; cualquier imagen adicional estrictamente necesaria para este alcance queda aprobada directamente.
- Esta continuidad no autoriza TestFlight, App Store, App Review ni publicación oficial.

### DEC-020 — Apoyo voluntario futuro, sin bloquear el candidato actual

- Cuando se implemente, vivirá dentro de Settings bajo el nombre “Support the app” o “Support development”; nunca será una pantalla obligatoria ni bloqueará las funciones principales gratuitas.
- El formato preferido será una suscripción mensual auto-renovable con niveles equivalentes. El beneficio mínimo será el estado activo de supporter, agradecimiento y explicación de que contribuye al mantenimiento y las actualizaciones.
- Antes de comprar se mostrarán precio, duración, renovación automática, cancelación, restauración de compras, privacidad y términos. Las reseñas de App Store serán un sistema separado con enlace persistente en Settings.
- Un aviso ocasional podrá aparecer con frecuencia baja, nunca en el primer uso ni durante una tarea crítica, y siempre tendrá “Not now” y “Don’t ask again”.
- Warm Words no tiene anuncios, por lo que no se inventarán ventajas grandes. StoreKit, pantallas finales, productos de App Store Connect y envío de IAP quedan fuera del candidato build 10 y necesitan autorización separada.

### DEC-021 — Skill estándar obligatoria para lanzamiento iOS

- Todo trabajo futuro de TestFlight, App Store Connect, App Review, AdMob, StoreKit/IAP, supporter subscriptions, privacidad, soporte, firma, workflow de subida, capturas, icono o checklist de publicación debe aplicar `C:\Users\dmkra\Documents\ChatGPT\Brain\.agents\skills\ios-app-launch\SKILL.md`.
- Para Warm Words, las rutas públicas recomendadas son `https://krazel.github.io/warm-words/privacy/` y `https://krazel.github.io/warm-words/support/` dentro del sitio GitHub Pages compartido; siguen pendientes hasta que existan y se verifiquen.
- La skill estandariza preparación y verificación, pero no autoriza acciones rojas. Crear productos, usar secretos, aceptar contratos, subir builds, enviar IAP/App Review o publicar requiere autorización expresa del propietario en ese momento.

### DEC-022 — Warm Words 1.0 es bilingüe en inglés y español

- El propietario pidió expresamente el 2026-08-10 conservar las frases propias y permitir cambiar el idioma desde Settings; esta decisión sustituye el alcance solo inglés de `DEC-002` y la parte correspondiente de `DEC-010`.
- Una instalación limpia usa español cuando el idioma preferido del iPhone es español y usa inglés en los demás casos. La elección manual `English / Español` se aplica al instante y persiste.
- El cambio de idioma afecta interfaz, catálogo incluido, categorías, fechas, días, accesibilidad y las próximas notificaciones. Los 360 pares conservan IDs y orden, por lo que favoritos, selección y frase diaria sobreviven al cambio.
- Las frases y categorías creadas por el usuario se conservan literalmente; no se traducen ni se eliminan al cambiar de idioma.
- **Warm Words** permanece como marca visible en ambos idiomas. La ficha principal de App Store puede seguir en inglés, pero el binario declara soporte para `en` y `es`; una localización española de tienda y sus capturas se prepara únicamente después del QA bilingüe.

### DEC-023 — El catálogo usa frases propias, no citas externas

- Tras revisar opciones de fuentes externas, el propietario decidió el 2026-08-10 usar frases propias de Warm Words.
- Los 360 pares inglés/español actuales se tratan como catálogo editorial original del proyecto, sin autores famosos, atribuciones ni scraping de sitios de citas.
- Las futuras correcciones o ampliaciones deben conservar ese criterio, revisión humana y paridad de IDs; no se incorporan citas existentes de terceros sin procedencia y licencia comprobables.

### DEC-024 — IPA bilingüe build 12 autorizada para QA local

- El propietario aprobó generar la nueva IPA el 2026-08-10 después de confirmar que el sistema de apoyo StoreKit se mantiene fuera de esta build de Sideloadly.
- El commit `ec7af63` pasó el workflow `31346772665` completo y produjo `dist/Warm-Words-Sideloadly-bilingual-build-12.ipa`.
- Esta build gratuita incluye inglés y español, pero no muestra una suscripción ficticia. “Support the app” se implementará únicamente con productos, precios, restauración, términos y privacidad reales.
- La autorización cubre commit, push y artifact unsigned local; no cubre TestFlight, App Store Connect, IAP, App Review ni publicación.

### DEC-025 — Today usa una carta vertical estrecha

- El propietario pidió el 2026-08-10 que la tarjeta principal deje de parecer cuadrada y tenga proporción de carta alargada.
- Se conserva la altura compacta aprobada para no reintroducir desplazamiento: 276 pt de ancho máximo y 330 pt de alto mínimo con texto normal, centrada en Today.
- En tamaños de accesibilidad puede ocupar el ancho disponible y crecer a partir de 430 pt; legibilidad y acceso al contenido prevalecen sobre la proporción decorativa.
- Las tarjetas de listas conservan su formato legible de fila; convertir las 360 frases en una cuadrícula de cartas sería un rediseño distinto y empeoraría la exploración.
- El cambio quedó compilado y verificado estáticamente en la IPA build 13 mediante el run `31347994854`; la aceptación visual final corresponde a la prueba en iPhone.
- **Decisión sustituida por DEC-026:** la prueba en iPhone confirmó que 276 pt era demasiado estrecho y no correspondía a la imagen aprobada.

### DEC-026 — Today ocupa la pantalla fija disponible

- El propietario reafirmó el 2026-08-10 `docs/design/reminder-v2/warm-words-today-compact-proposal.png` como referencia exacta y rechazó la carta estrecha de build 13/14.
- Con texto normal, Today no se desplaza: la carta ocupa todo el ancho útil y absorbe toda la altura disponible entre la fecha y las acciones.
- Me gusta y Compartir permanecen siempre visibles directamente encima de la barra de pestañas.
- Los tamaños de texto de accesibilidad conservan una excepción desplazable para no cortar texto ni acciones.
- No se genera una imagen nueva porque la propuesta completa existente ya define exactamente esta composición y cuenta con aprobación del propietario.

### DEC-027 — Push y compilación privada autorizados de forma permanente

- El propietario autorizó expresamente el 2026-08-10 los `git push` necesarios de Inspiración Día y las compilaciones privadas de IPA mientras continúe el desarrollo del proyecto, hasta que revoque esta autorización.
- Esta autorización permite actualizar la rama de trabajo y ejecutar/descargar artifacts privados de GitHub Actions para Sideloadly.
- No autoriza crear o publicar GitHub Releases, subir a TestFlight/App Store, enviar a App Review, usar secretos o cuentas nuevas, aceptar contratos ni asumir costes.

### DEC-028 — Categorías propias retiradas y frases nuevas directas a Personal

- El propietario decidió el 2026-08-10 retirar la creación de categorías propias por ahora.
- El formulario de nueva frase solo solicita el texto y la guarda directamente en Personal; no muestra selector ni campos de categoría.
- Las categorías y frases históricas se preservan para no perder datos. Sus frases siguen accesibles desde Personal, aunque ya no se muestran mosaicos separados de categorías propias.
- El mismo cierre corrige el host de Settings, uniforma los mosaicos de categorías y sustituye el icono incompatible de Hábitos.

### DEC-029 — Compartir usa tarjeta visual y enlace inteligente

- El propietario decidió el 2026-08-10 sustituir el texto plano por una tarjeta visual de Warm Words acompañada de un enlace que abra la app instalada o su descarga.
- Dirección aprobada: PNG dinámica 1080 × 1350 basada en la carta Today y un único enlace HTTPS; no se añade backend, cuenta, sincronización ni publicación de frases personales.
- WhatsApp y otras extensiones deciden cómo representan `[imagen, URL]`; iOS no puede garantizar que la imagen adjunta sea pulsable. La promesa verificable es compartir la imagen y el enlace, no controlar la composición de terceros.
- La implementación del PNG puede avanzar localmente. Activar el enlace exige landing pública, App Store URL real, AASA, Team ID, Associated Domains y firma compatible; no se comparte una URL 404.

### DEC-030 — Ficha privada bilingüe creada en App Store Connect

- El propietario autorizó expresamente el 2026-08-10 crear la página de App Store y pidió inglés y castellano, con inglés como idioma principal.
- Se creó la ficha iOS 1.0 con Apple ID `6800058458`, bundle ID `com.dmkr.inspiraciondia.B2X6D3A9J9`, SKU `com.dmkr.inspiraciondia` e idioma principal Inglés (EE. UU.).
- Se añadieron localizaciones Inglés (EE. UU.) y Español (España), categorías Lifestyle y Health & Fitness, precio gratuito, disponibilidad en 175 países, soporte y privacidad provisionales mediante GitHub, ausencia de login, distribución solo en iPhone y publicación manual.
- App Store Connect muestra actualmente una clasificación global 4+ con excepciones regionales tras declarar de forma veraz el contenido general de bienestar. La app no es un dispositivo médico regulado.
- La respuesta App Privacy “no se recopilan datos” está guardada como borrador y no publicada hasta poder contrastarla con el archive firmado final.
- La creación y edición de la ficha no autorizan cargar builds, TestFlight, añadir a revisión ni publicar. Esas acciones siguen requiriendo una autorización expresa en el momento correspondiente.

### DEC-031 — Ampliación editorial y preparación de TestFlight

- El catálogo 1.0 se amplía de 180 a 360 pares originales en inglés y español: 30 por cada una de las 12 categorías, con IDs paralelos `001–030`.
- Se añaden 180 pares nuevos y se reescriben 12 pares débiles conservando sus IDs para no romper favoritos ni referencias existentes.
- `scripts/check-quotes.mjs` exige ahora tamaño, orden, paridad, longitud y ausencia de duplicados exactos, normalizados o casi idénticos. La trazabilidad queda en `docs/content-review/`.
- Se prepara un workflow TestFlight manual, separado del CI unsigned, protegido por environment y con upload desactivado por defecto. No se ejecuta hasta configurar firma y secretos con autorización expresa.
- El primer archive usará build `18` o el siguiente número libre. Subirlo a TestFlight sigue siendo una acción separada que requiere autorización en ese momento.

### DEC-032 — TestFlight interno autorizado y activo

- El propietario autorizó expresamente el 2026-08-10 crear la firma necesaria, usar secretos protegidos y subir Warm Words a TestFlight.
- Apple Developer emitió un certificado Apple Distribution y el perfil `Warm Words App Store 2026`, válidos hasta el 2027-08-10. App Store Connect creó una clave API con rol Gestor de apps.
- El identificador efectivo de la ficha se verificó como `com.dmkr.inspiraciondia.B2X6D3A9J9`; proyecto, workflow, perfil y validadores quedaron alineados con ese valor. El SKU histórico permanece `com.dmkr.inspiraciondia`.
- GitHub Actions run `31429710903`, job `93589855913`, commit `423da40`, produjo, validó y subió Warm Words 1.0 build 20. Apple la procesó correctamente.
- El grupo interno `Warm Words Internal` contiene build 20 y a la cuenta propietaria como único tester. La distribución automática futura quedó desactivada.
- Esta autorización no incluye testers externos, Beta App Review, App Review, selección del build para publicación ni lanzamiento en App Store.

### DEC-033 — Manifiesto visual canónico y sustituciones no destructivas

- Desde el 2026-08-11, `design/APPROVALS.md` es la fuente de verdad para las imágenes completas aprobadas que gobiernan Warm Words.
- Cada pantalla/estado cubierto conserva una única referencia vigente con ruta, lienzo o dispositivo, orientación, idioma, fecha y SHA-256. Las propuestas no elegidas, assets fuente, capturas runtime y capturas de tienda quedan separados.
- Una sustitución aprobada añade una nueva maestra y marca la anterior como reemplazada o retirada sin borrarla. La propuesta de creación inline de categorías se conserva como referencia retirada tras `DEC-028`.
- Las capturas de tienda usarán estas maestras como dirección de arte, pero su captura base debe salir de una build real y enlazarse al manifiesto. No se inventan capturas de implementación donde todavía no existe evidencia física.

### DEC-034 — Minimización estricta de datos e información pública

- Cada build iOS publicable debe auditarse con la skill central `ios-app-launch` y mantener un inventario exacto de datos, almacenamiento, transmisiones, permisos y SDKs.
- Warm Words 1.0 build 20 no recopila datos para el desarrollador: usa solo frameworks Apple, no hace red y no contiene cuentas, nube, publicidad, analítica, tracking, StoreKit, compras ni SDKs de terceros. Solo solicita notificaciones locales después de una acción explícita.
- Privacidad, soporte, metadata y App Store Privacy describirán la build exacta, sin cláusulas hipotéticas ni omisiones. Un cambio de SDK, permiso, red o monetización obliga a repetir la auditoría antes de distribuir.
- El soporte público usará una página propia y un alias exclusivo. No se publicarán repositorio, incidencias, cuentas personales, nombre completo, domicilio, teléfono ni correo personal salvo obligación concreta de Apple o de la ley.
- El contacto de App Review es privado y contendrá únicamente los datos reales mínimos que Apple exija. URL de marketing, URL de opciones de privacidad y demás campos opcionales permanecen vacíos si no son necesarios.
- El estado DSA trader no se presume ni se elude: se eleva como decisión material y, si aplica, se proporcionará la información pública legalmente exigida.

### DEC-035 — Los enlaces compartidos abren la frase exacta y permiten guardar frases personales

- El propietario pidió el 2026-08-12 que Compartir entregue la tarjeta PNG y un enlace específico. Con la app instalada, el enlace abre una vista previa de esa misma frase; sin la app, abre una landing que conduce a App Store.
- Las frases incluidas se identifican por su ID estable y el idioma del emisor. Las frases personales incluyen únicamente su texto normalizado —máximo 240 caracteres— dentro del fragmento `#` del enlace; no incluyen identidad, UUID local, estado de favorito ni datos del dispositivo.
- El fragmento evita que el host web reciba el texto, pero no es secreto: el servicio de mensajería y el destinatario pueden verlo. No se añade backend, cuenta, nube, analítica ni seguimiento.
- Una frase personal recibida nunca se importa automáticamente. La pantalla aprobada `WW-SCREEN-004` exige tocar `Save to Personal & Favorites`; entonces se crea o reutiliza una sola copia local y se marca como favorita. Las frases incluidas se guardan en Favoritos por ID.
- No existe deferred deep linking completo sin infraestructura adicional: quien instale la app desde la landing debe volver al mensaje original y tocar el enlace otra vez. WhatsApp y otras extensiones deciden cómo muestran la pareja imagen/enlace.
- La implementación local exige Universal Links, AASA, Associated Domains y un nuevo perfil/build. La landing y AASA pueden prepararse localmente, pero no se distribuye una build con enlaces activos hasta verificar HTTP, CDN de Apple, firma y App Store URL. Publicar el sitio o subir la build sigue siendo una acción separada.

### DEC-036 — Ajustes se presenta desde Today y TestFlight continúa en el tren 1.0

- Tras reproducirse otra vez el botón de Ajustes sin respuesta, la hoja deja de depender del estado y presenter de `RootView`. `TodayView` conserva su propio estado y presenta `SettingsView` directamente desde su `NavigationStack`, permitiendo abrir, cerrar y volver a abrir sin depender del `TabView` ni de otras portadas.
- El propietario autorizó expresamente el 2026-08-12 corregirlo y subir una nueva build a TestFlight. Como App Store Connect ya contiene el tren 1.0 y todavía no existe una versión pública, se conserva marketing version `1.0` y se usa build `21`; no se crea artificialmente una versión pública 1.1 antes del primer lanzamiento.
- La autorización de TestFlight no se amplía silenciosamente a publicar GitHub Pages. Build 21 mantiene apagado el enlace inteligente y no firma Associated Domains hasta que el propietario autorice expresamente hacer pública la landing/AASA y estas respondan correctamente.

### DEC-037 — Intereses en primer inicio y navegación nativa de Ajustes

- El propietario aprobó el 2026-08-12 que una instalación limpia permita escoger las categorías de sus recordatorios junto con la hora y los días. Las 12 categorías incluidas empiezan activas mediante `All categories`; el usuario puede reducirlas a una selección específica y no puede confirmar un recordatorio activo con cero categorías.
- La selección inicial usa los mismos IDs estables, persistencia local y planificador de Settings. No añade datos recopilados, red, cuentas ni permisos.
- Tras repetirse el fallo del engranaje con varias ubicaciones de una hoja modal, Ajustes deja de presentarse como `.sheet`: el engranaje es un `NavigationLink` nativo dentro del `NavigationStack` de Today. Volver hace `pop` con el control existente y la ruta puede abrirse de nuevo sin estado modal.
- `WW-SCREEN-002` queda reemplazada no destructivamente por la maestra completa de onboarding con categorías. La autorización permanente `DEC-019` permite integrar esta imagen necesaria sin otra pausa de aprobación.
- El propietario autorizó expresamente corregir, verificar y subir Warm Words **1.0 build 22** a TestFlight. No autoriza TestFlight externo, App Review, publicación pública ni activar los enlaces inteligentes todavía.

### DEC-038 — Onboarding de intereses separado en dos pasos

- El propietario indicó el 2026-08-18 que la selección de intereses del onboarding combinado no resultaba visible. La instalación limpia pasa a dos pasos: primero las 12 categorías, todas activas; después la pantalla existente de hora y días.
- `Continue` no persiste, no programa y no pide permiso. El borrador conjunto solo se confirma con `Set reminder` en el segundo paso. `Back` conserva la selección y una selección específica vacía no puede continuar.
- `currentReminderOnboardingVersion` permanece en `1`: una actualización no fuerza a usuarios existentes a repetir una experiencia definida para primera instalación. Para verificarla hay que borrar la app/datos y hacer clean install.
- La maestra combinada queda reemplazada sin borrarse. `WW-SCREEN-002A` gobierna intereses y la antigua pantalla de hora/días vuelve como `WW-SCREEN-002B`.
- Este cambio no añade datos recopilados, red, permisos, SDKs ni assets de ejecución. Una futura build debe usar el siguiente número libre; subirla a TestFlight sigue requiriendo autorización expresa en ese momento.

### DEC-039 — TestFlight build 23 autorizado y entregado

- El propietario autorizó expresamente el 2026-08-18 publicar el commit `6993c92`, crear Warm Words **1.0 (23)** y subirlo a TestFlight.
- GitHub Actions run `32163428876`, job `95797362914`, pasó 29 tests sin fallos, Analyze Release, firma, archive, inspección, exportación y upload. Apple aceptó el archivo sin errores de transporte.
- Ante la comprobación física de que TestFlight seguía entregando build 22, el propietario autorizó publicar y ejecutar el asignador interno. Apple confirmó build 23 como `VALID` y el run `32173244154` verificó su pertenencia a `Warm Words Internal`.
- La autorización se limita a TestFlight interno de esta build. No incluye testers externos, Beta App Review, App Review, Universal Links, publicación pública ni futuras builds.

### DEC-040 — Onboarding simplificado y TestFlight build 24

- El propietario aprobó el 2026-08-18 retirar de la primera pantalla `Step 1 of 2`, `Quote categories`, la explicación de categorías seleccionadas por defecto y `Not now`; de la segunda, retirar únicamente `Step 2 of 2`, conservando `Back` y `Not now`.
- La pregunta aprobada es `What would help you today?` / `¿Qué te ayudaría hoy?`, con un texto breve que invita a elegir qué recibir sin hablar de “tipos de palabras”. La selección inicial y toda la lógica permanecen iguales.
- El propietario autorizó expresamente commit, push, build y TestFlight. Build **1.0 (24)** desde `971c5d0` pasó 29 tests, Analyze, firma, archive, exportación y upload en run `32174725981`; Apple la marcó `VALID` y run `32175849335` verificó su asignación a `Warm Words Internal`.
- La autorización no incluye testers externos, Beta App Review, App Review, Universal Links ni publicación pública.

### DEC-041 — Ajustes se abre desde la raíz y las frases completan un ciclo antes de repetirse

- El propietario confirmó el 2026-08-24 que el engranaje seguía sin responder en la build instalada. La ruta vigente sustituye `DEC-037` en lo relativo a la presentación: Today usa un botón normal con área táctil de 52 × 52 pt y `RootView` presenta Ajustes mediante una ruta modal única de pantalla completa. Today no conserva un `NavigationStack` ni un `NavigationLink` propios.
- El propietario pidió que una tarjeta no vuelva a salir hasta haber completado todas las frases correspondientes a las categorías elegidas. La regla aprobada es un historial persistente por ID: primero se eligen las frases elegibles nunca vistas y, al agotarlas, la menos recientemente vista inicia el ciclo siguiente.
- El conjunto elegible es la unión de las categorías de entrega seleccionadas; `All categories` usa todo el catálogo. Cambiar la selección conserva el historial de las demás categorías, muestra primero cualquier frase nueva elegible y nunca borra favoritos ni contenido Personal.
- Today y las notificaciones locales usan el mismo ciclo y coordinan la asignación diaria. El historial se comparte entre inglés y español porque ambos catálogos mantienen IDs paralelos, y permanece exclusivamente en `UserDefaults` del iPhone.
- La migración conserva la selección diaria heredada cuando siguen activas todas las categorías; si existe una selección específica, prioriza desde el primer día una frase que sí pertenezca a ella. En ambos casos aplica la garantía sin repetición hacia adelante. Borrar frases Personal, denegar notificaciones o apagar el recordatorio elimina referencias inválidas o reservas futuras sin reiniciar el resto del historial.
- Esta decisión autoriza la corrección local y sus pruebas. No constituye autorización nueva para commit, push, firma, upload a TestFlight, testers externos, App Review ni publicación.

### DEC-042 — Catálogo congelado y TestFlight build 25 autorizado

- El propietario autorizó expresamente el 2026-08-24 compilar y subir la nueva versión y pidió una auditoría integral de preparación para publicación.
- La revisión editorial confirma que 360 pares —30 por cada una de 12 categorías— son suficientes para 1.0. Se reescribieron 16 pares concretos con problemas semánticos, traducciones poco naturales o afirmaciones demasiado rotundas; el catálogo queda congelado y no se añaden frases por cantidad.
- Antes de compilar se impidió seleccionar `Personal` vacío para entregas y se añadió reconciliación de notificaciones propias cuando los recordatorios están apagados.
- Los commits de app `6f978a9` y `bdec7a0` se subieron a la rama iOS. Run `32751996787` compiló Warm Words **1.0 (25)** con Xcode 26.6 / SDK 26.5, pasó 38 tests, Analyze, firma, archive, inspección, exportación y upload. Apple respondió `UPLOAD SUCCEEDED with no errors`.
- Apple procesó build 25 como `VALID` y run `32753132327` confirmó su asignación al grupo interno `Warm Words Internal`.
- Esta autorización comprende TestFlight interno de build 25. No comprende App Review, publicación pública, testers externos, publicar GitHub Pages ni activar Universal Links.

### DEC-043 — Ampliación editorial a 60 frases por categoría

- El propietario reconsideró la suficiencia de 30 frases por categoría y aprobó ampliar el catálogo antes del candidato publicable. Esta decisión sustituye únicamente la congelación cuantitativa de `DEC-042`; no cambia la validez histórica ni la autorización de TestFlight de build 25.
- El catálogo objetivo pasa a 720 pares originales inglés/español: 60 por cada una de las 12 categorías, con IDs paralelos `001–060`. Así, una persona que seleccione una sola categoría dispone de 60 días antes de repetir; con todas dispone de 720.
- Se mantienen el tono concreto y sereno, la ausencia de autores o citas famosas, la trazabilidad local y la revisión bilingüe. La cantidad no autoriza contenido de relleno: cada alta debe pasar validación estructural y revisión editorial humana.
- Las 16 reescrituras detectadas en la auditoría anterior se aplican a las fuentes canónicas, no solo a los recursos generados. La revisión de ampliación mejoró además 55 pares: tres solapamientos detectados durante la integración y 52 textos señalados por la auditoría final independiente por naturalidad, cliché, equivalencia o seguridad.
- La ampliación no modifica interfaz, lógica, privacidad ni permisos. Queda preparada localmente para la siguiente build, pero esta decisión no autoriza commit, push, firma, TestFlight, App Review ni publicación.

### DEC-044 — Build 26 y TestFlight interno autorizados

- El propietario autorizó expresamente el 2026-08-24 hacer commit y push del catálogo ampliado, compilar y firmar Warm Words **1.0 (26)**, subirla a TestFlight y asignarla al grupo interno existente.
- Se conserva excepcionalmente el tren 1.0 ya creado en App Store Connect y se incrementa el build de 25 a 26; no se abre una versión pública distinta durante este cierre previo al primer lanzamiento.
- La autorización no incluye testers externos, Beta App Review, App Review, publicación pública, activación de Universal Links, productos StoreKit ni cambios comerciales.
- Resultado: commit `b629bcd`; run `32765814357` completó tests, análisis, firma, archive, exportación y subida sin errores; Apple marcó build 26 como `VALID` y run `32766825710` la asignó a `Warm Words Internal`.

### DEC-045 — Corrección de rendimiento y build 27 autorizadas

- El propietario informó el 2026-08-31 de una lentitud clara en build 26 y autorizó corregirla y subir la siguiente versión a TestFlight.
- La corrección aprobada es técnica y reversible: renderizado perezoso de las tarjetas, planificación del ciclo en una sola ordenación y actualización diferencial de notificaciones pendientes. Debe conservar diseño, contenido, selección, historial y comportamiento visible.
- Se mantiene excepcionalmente el tren existente 1.0 y se usa build 27. La autorización comprende commit, push, firma, subida y grupo interno; no testers externos, Beta App Review, App Review ni publicación.
- Resultado: commit `484ca3d`; run `33341160940` pasó 40 tests, Analyze Release, firma, archive, inspección, exportación, validación y subida sin errores. Apple marcó build 27 como `VALID` y run `33341523935` la asignó a `Warm Words Internal`.

### DEC-046 — Corrección definitiva de Ajustes y build 28 autorizadas

- Tras confirmar que build 27 todavía podía dejar el botón de Ajustes sin respuesta, el propietario autorizó el 2026-08-31 hacer la corrección, compilarla y subirla a TestFlight.
- Ajustes se separa del estado modal de enlaces compartidos y pasa a navegación propiedad de la raíz. La entrega incluye una prueba UI que abre, cierra y vuelve a abrir la pantalla.
- Se mantiene el tren existente 1.0 y se usa build 28. La autorización comprende commit, push, firma, subida y grupo interno; no testers externos, Beta App Review, App Review ni publicación.
- Resultado: commit `87c004a`; run `33347733817` pasó 40 pruebas de lógica, la nueva prueba UI de abrir/cerrar/reabrir Ajustes, Analyze, firma, archive, exportación, validación y subida. Apple marcó build 28 como `VALID` y run `33348245753` la asignó a `Warm Words Internal`.

### DEC-047 — Cierre de sistemas y build 29 autorizados

- El propietario pidió el 2026-08-31 una comprobación final de todos los sistemas, señaló que no identificaba la categoría de motivación y que la notificación de prueba no había aparecido, y autorizó expresamente compilar y subir la corrección a TestFlight.
- Se conserva el ID estable `animo` para no romper persistencia y se aclara su nombre visible como `Motivation` / `Motivación`; no se añade una decimotercera categoría ni contenido duplicado.
- La prueba local pasa de afirmar falsamente “enviada” a distinguir solicitud programada y entrega recibida, validar el estado efectivo de alertas y advertir de Resumen programado. Favoritos adopta carga diferida y Ajustes deja de mostrar la recomendación de seleccionar todas las categorías.
- Se mantiene el tren previo al lanzamiento `1.0` y se usa build 29. La autorización comprende commit, push, firma, subida y asignación al grupo interno; no testers externos, Beta App Review, App Review ni publicación.
- Resultado: commit `1d2b36c`; run `33399920401` pasó 41 pruebas unitarias y 2 UI, Analyze, firma, archive, exportación, validación y subida sin errores. Apple marcó build 29 como `VALID` y run `33401009451` la asignó a `Warm Words Internal`.

### DEC-048 — Preparación de App Store y build 30 autorizadas

- El propietario declaró el 2026-08-31 que la aplicación le gusta como está y autorizó preparar y enviar el candidato, incluyendo icono, imágenes y cualquier requisito restante.
- El AppIcon C ya era el icono vigente y no se sustituye. Se conservan las pantallas y el diseño actuales.
- Se publicaron páginas bilingües dedicadas de Privacidad y Soporte y build 30 añadió sus enlaces dentro de Ajustes. El enlace inteligente de compartir continúa fuera de 1.0.
- Resultado técnico: commit fuente `77cf219`; run `33430292504` pasó 41 pruebas unitarias, 2 UI, Analyze, firma, archive, inspección, exportación, validación y subida. App Store Connect procesó build 30 y run `33431522703` la asignó a `Warm Words Internal`.
- La autorización permite preparar la ficha y el envío, pero no permite inventar datos privados, derechos de terceros ni información DSA. Esos valores deben confirmarse de forma veraz justo antes de completar los formularios externos.

## Primera decisión pendiente del propietario

### PEND-009 — Trazabilidad editorial y derechos de assets

La dirección de producto de usar frases propias ya está aprobada. Antes de App Review debe conservarse una nota de procedencia editorial del catálogo y confirmarse la autoría/licencia comercial de `premium-mountains.png` y `premium-stones.png`.

### PEND-010 — Privacidad y soporte públicos

Resuelto en el producto: las rutas dedicadas `https://krazel.github.io/warm-words/privacy/` y `https://krazel.github.io/warm-words/support/` están publicadas, son bilingües y se enlazan desde build 30. Pendiente externo: sustituir las URL provisionales en App Store Connect, probar recepción del alias y publicar la respuesta exacta `No data collected`.

### PEND-011 — Configuración comercial de App Store

Categorías, precio gratuito, 175 países, distribución pública, clasificación por edades y publicación manual ya están configurados. Faltan copyright y fecha objetivo.

### PEND-014 — QA Apple y autorización de distribución oficial

El archive firmado, Validate App, upload, procesamiento y asignación interna de build 30 ya pasaron. Faltan QA físico en iPhone, validar/subir las capturas inglesas/españolas, completar datos obligatorios y publicar la declaración de privacidad. La autorización de preparación y envío existe, pero la acción final necesita los datos privados y confirmaciones veraces indicados en `PEND-009` y `PEND-015`.

### PEND-015 — Estado DSA trader

App Store Connect muestra que el desarrollador ya se ha identificado como **trader para esta app**. La clasificación deja de estar pendiente; antes de distribuir en la UE queda únicamente verificar que la información de contacto validada que Apple publicará es correcta. No se cambia, oculta ni duplica en otros campos públicos.
