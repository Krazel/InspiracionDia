# Decisiones de Inspiración Día

Actualizado: **2026-08-09**

Este archivo separa decisiones aprobadas de decisiones materiales todavía pendientes. Las elecciones reversibles y técnicas corresponden al cerebro de producto; solo una decisión material se eleva cada vez, con una recomendación única.

## Decisiones aprobadas

### DEC-001 — iOS es la única plataforma activa

- iOS se desarrolla y cierra primero.
- Android no se desarrolla, mantiene, corrige, compila ni sincroniza hasta petición expresa futura.
- La carpeta Android se preserva como legado.

### DEC-002 — Lanzamiento 1.0 provisionalmente solo en inglés

- Interfaz pública, contenido, capturas y ficha de App Store deben estar en inglés.
- El español existente se conserva sin mantenimiento y no se expone en 1.0.

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

- Catálogo inglés completo de 180 frases, con IDs idénticos al español preservado.
- Inglés fijo y selector español oculto; no se abre una excepción bilingüe.
- Notificación local con una frase distinta por fecha y cola conservadora de 60 días.
- Compartir texto plano; no tarjeta-imagen.
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
- `Warm Words` es el nombre visible en la app, compartir, notificaciones y ficha de App Store.
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

## Primera decisión pendiente del propietario

### PEND-009 — Derechos de contenido y assets

El propietario debe confirmar autoría/licencia y permiso comercial de las 180 frases inglesas y españolas, `premium-mountains.png` y `premium-stones.png`.

### PEND-010 — Privacidad y soporte públicos

Faltan Privacy Policy URL y Support URL reales. La etiqueta “no data collected” solo se cierra tras inspeccionar el binario final.

### PEND-011 — Configuración comercial de App Store

Faltan categoría primaria, precio, territorios, edad, copyright y fecha objetivo. Recomendación vigente: gratis mientras no exista monetización.

### PEND-012 — Cuenta Apple y firma

Faltan confirmar membresía, disponibilidad/registro de `com.dmkr.inspiraciondia`, team, certificados y acceso a App Store Connect.

### PEND-014 — QA Apple y autorización de distribución

Faltan build/test en macOS, archive firmado, Validate App, QA en iPhone, capturas y ficha inglesa. Cada upload, TestFlight o envío a App Review necesita autorización expresa en ese momento.
