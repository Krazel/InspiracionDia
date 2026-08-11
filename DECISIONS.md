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

## Primera decisión pendiente del propietario

### PEND-009 — Trazabilidad editorial y derechos de assets

La dirección de producto de usar frases propias ya está aprobada. Antes de App Review debe conservarse una nota de procedencia editorial del catálogo y confirmarse la autoría/licencia comercial de `premium-mountains.png` y `premium-stones.png`.

### PEND-010 — Privacidad y soporte públicos

Las URL de GitHub guardadas provisionalmente en la ficha no son aptas para lanzamiento. Las rutas dedicadas `https://krazel.github.io/warm-words/privacy/` y `https://krazel.github.io/warm-words/support/` devolvían 404 el 2026-08-11. Hay que publicar las políticas bilingües exactas, crear y probar un alias exclusivo de soporte y sustituir las URL sin exponer repositorio ni datos personales. La respuesta App Privacy “no se recopilan datos” coincide con build 20 y sigue como borrador no publicado.

### PEND-011 — Configuración comercial de App Store

Categorías, precio gratuito, 175 países, distribución pública, clasificación por edades y publicación manual ya están configurados. Faltan copyright y fecha objetivo.

### PEND-014 — QA Apple y autorización de distribución oficial

El archive firmado, Validate App, upload y procesamiento TestFlight de build 20 ya pasaron. Faltan QA físico en iPhone, capturas inglesas/españolas y publicar la declaración de privacidad tras verificar el binario. Testers externos, App Review y publicación necesitan autorización expresa adicional en ese momento.

### PEND-015 — Estado DSA trader

Antes de mantener distribución en la Unión Europea, el propietario debe confirmar si ofrece Warm Words en relación con una actividad comercial, empresarial, artesanal o profesional. Recomendación actual: declarar **non-trader** para esta 1.0 gratuita, sin anuncios, compras ni suscripciones, únicamente si el propietario confirma que es un proyecto personal ajeno a su actividad profesional; si no puede confirmarlo, declarar **trader** y aportar a Apple la información verificada que exijan la DSA y App Store Connect. No se inventará ni ocultará ningún dato.
