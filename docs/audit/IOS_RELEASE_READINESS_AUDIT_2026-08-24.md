# Warm Words 1.0 — auditoría de preparación para publicación

Fecha de corte: **24 de agosto de 2026**

Alcance: **iPhone, iOS 16+, inglés principal y español incluido**

Candidato auditado: **1.0 (25)**, commit de app `bdec7a0`, GitHub Actions run `32751996787`

## Veredicto

**La build 25 es apta para TestFlight interno, pero todavía no es apta para enviar a App Review ni publicar.** Compila, firma, archiva y se entrega correctamente a Apple; los 38 XCTest pasan y el análisis Release no bloquea. El catálogo también está cerrado. Las puertas restantes son de QA físico, páginas y enlaces públicos, capturas reales y campos obligatorios de App Store Connect.

No conviene añadir funciones, suscripciones, anuncios ni más frases antes de cerrar 1.0. Hacerlo ampliaría el riesgo sin resolver ninguna exigencia de publicación.

## Fotografía verificable del candidato

| Área | Evidencia | Resultado |
|---|---|---|
| Identidad | `Warm Words`, bundle `com.dmkr.inspiraciondia.B2X6D3A9J9`, marketing version `1.0`, build `25`, iPhone, mínimo iOS 16 | PASS |
| Herramientas | Xcode 26.6, build 17F113, SDK iPhoneOS 26.5 | PASS |
| Tests | 38 XCTest, 0 fallos; validadores de catálogo y cierre iOS superados | PASS |
| Release | Analyze, Apple Distribution, archive, inspección, exportación y firma completados | PASS |
| Entrega | Run `32751996787`: `UPLOAD SUCCEEDED with no errors`; run `32753132327`: build `VALID` y asignada a `Warm Words Internal` | PASS |
| Artefacto | `Warm-Words-TestFlight-v1.0-build-25`, 6.360.186 bytes, artifact SHA-256 `4cfa215c7b03ef0d7ab5fb37a08ea995d13df8928923838f0d0c7d3c4b8b7eb7`, caduca el 27-08-2026 | PASS |
| Recursos | Ambos catálogos, `PrivacyInfo.xcprivacy`, AppIcon, `premium-mountains.png` y `premium-stones.png` presentes en el archive | PASS técnico / derechos pendientes |
| Privacidad técnica | Solo Foundation, SwiftUI, UIKit y UserNotifications; sin SDK externos, red propia, cuentas, analítica, tracking, anuncios, StoreKit, nube ni push remoto | PASS |
| Permisos | Solo notificaciones locales, solicitadas tras la configuración o una prueba explícita | PASS técnico / QA físico pendiente |
| Ajustes | Botón normal de 52 × 52 pt y presentación desde la raíz; ya no depende de un `NavigationLink` dentro del `TabView` | PASS de código / QA físico pendiente |
| Frases sin repetición | Historial persistente por ID, conjunto limitado a categorías elegidas y coordinación con las notificaciones | PASS de lógica / QA físico pendiente |

## Catálogo editorial

El catálogo es suficiente y queda recomendado para congelación tras las correcciones de esta build:

- 360 frases en inglés y 360 en español, enlazadas por el mismo ID.
- 12 categorías con 30 frases por categoría.
- Sin duplicados exactos, normalizados ni casi idénticos detectados.
- Con todas las categorías activas, el ciclo ofrece casi un año de contenido diario antes de repetir; con una sola categoría ofrece 30 días.
- La revisión independiente consideró 344 pares publicables sin cambios y detectó 16 pares con problemas semánticos, traducciones poco naturales o afirmaciones psicológicas demasiado rotundas. Los 16 se reescribieron conservando ID y categoría.
- No quedan promesas médicas, diagnósticos, atribuciones falsas ni citas famosas en el catálogo revisado.

**Decisión editorial recomendada: no añadir más frases para 1.0.** La cantidad ya supera lo necesario para el producto; nuevas frases aumentarían el coste de revisión y podrían bajar la calidad media.

La única puerta de derechos es documental: conservar la trazabilidad de que el catálogo es original y confirmar por escrito los derechos comerciales de los dos fondos incluidos.

## Defectos corregidos antes de la build 25

1. Ajustes se presenta mediante una ruta modal única propiedad de `RootView`, evitando el host de navegación que había fallado repetidamente en iPhone.
2. Today y las notificaciones dejan de repetir frases hasta agotar el conjunto elegible.
3. `Personal` ya no puede seleccionarse para entregas cuando no contiene frases; una selección específica vacía ya no cae silenciosamente a todas las categorías.
4. Al borrar la última frase de una categoría personal se sanea también su selección de entrega.
5. Al arrancar con recordatorios apagados, la app vuelve a retirar solicitudes propias pendientes, cerrando la carrera que podía dejar un aviso antiguo activo.
6. Dieciséis pares de frases se corrigieron editorialmente sin cambiar sus IDs.

## Preparación real de App Store Connect

### Ya preparado

- App creada con Apple ID `6800058458` y bundle correcto.
- Inglés como idioma principal y localización española preparada.
- Nombre de ficha `Warm Words: Daily Quotes` / `Warm Words: Frases Diarias`.
- Categorías Lifestyle y Health & Fitness.
- Precio gratuito, disponibilidad territorial configurada y publicación manual.
- Clasificación global 4+ con excepciones regionales visibles en la ficha.
- AppIcon 1024 × 1024 opaco y asignado al target.
- Respuesta material de App Privacy: **no se recopilan datos**, coherente con el archive.
- Estado DSA visible: el desarrollador se ha identificado como **trader para esta app**.
- No hay IAP, suscripciones ni anuncios. No son necesarios para publicar esta 1.0 y no deben añadirse como elementos ficticios.

### Bloqueos antes de App Review, por prioridad

1. **Privacidad y soporte públicos.** Las rutas previstas `/privacy/`, `/support/` y `/share/` devolvían 404 el día de la auditoría. La ficha sigue usando GitHub Issues como soporte y un archivo del repositorio como política. Hace falta publicar páginas dedicadas, con un alias de soporte probado y sin exponer repositorio ni datos personales opcionales. Apple exige además un enlace a la política de privacidad dentro de la app.
2. **Capturas.** La ficha inglesa y la española tienen cero capturas. Debe capturarse la build real ya verificada; Apple acepta de una a diez por localización. La dirección de arte puede seguir `design/APPROVALS.md`, pero la base final debe salir del runtime real.
3. **Campos obligatorios de envío.** Content Rights no está configurado; faltan copyright, los cuatro datos privados de contacto de App Review, notas de revisión y seleccionar la build final. App Privacy continúa como borrador y no se ha publicado.
4. **QA físico.** Falta probar en iPhone la instalación limpia categorías → horario, abrir/cerrar/reabrir Ajustes, recordatorios permitidos/denegados/apagados, selección de categorías, ciclo persistente, idioma, favoritos, Personal, compartir, VoiceOver, Dynamic Type y un iPhone pequeño.
5. **Compartir con enlace.** La build 25 comparte correctamente una imagen, pero no adjunta URL. El feature gate de enlace público está apagado, Associated Domains no forma parte de la firma y la landing es 404. Por tanto, todavía no cumple el requisito de producto aprobado de imagen + enlace + apertura en app/App Store + guardado explícito de una tarjeta personal. No debe describirse esa función como activa hasta verificar landing, AASA, entitlement y flujo completo en una build posterior.
6. **Derechos.** Confirmar por escrito la autoría del catálogo y la licencia comercial de `premium-mountains.png` y `premium-stones.png`.

El estado DSA no debe reinterpretarse ni ocultarse: App Store Connect ya registra `trader`. Antes de distribuir en la UE hay que comprobar que los datos verificados que Apple publicará siguen siendo correctos. Apple indica que, para traders, la dirección, teléfono y correo exigidos por la DSA aparecen en la página del producto.

La declaración de accesibilidad de App Store Connect todavía no se ha iniciado. Puede quedarse sin afirmaciones hasta completar QA; solo deben declararse prestaciones demostradas en dispositivo.

## Exactitud de privacidad y datos

La afirmación “no se recopilan datos” es correcta para la build 25:

- preferencias, favoritos, frases personales, horario, categorías, historial del ciclo y asignaciones se almacenan localmente en `UserDefaults`;
- `PrivacyInfo.xcprivacy` declara `NSPrivacyAccessedAPICategoryUserDefaults` con razón `CA92.1`;
- no hay transmisión al desarrollador ni SDK de terceros;
- compartir entrega únicamente la imagen elegida a la hoja de compartir de iOS;
- no hay cuentas, compras, publicidad, analítica, tracking ni sincronización.

Se corrigieron los borradores de privacidad, soporte, inventario y QA para que no afirmen que la build 25 comparte un enlace. La política pública final debe publicarse y enlazarse desde Settings antes de App Review.

## QA físico mínimo para aprobar el candidato

1. Instalación limpia: verificar que categorías aparece primero, horario después y la solicitud de notificaciones solo al confirmar.
2. Ajustes: abrir, cerrar y reabrir diez veces; repetir tras cambiar de pestaña, idioma y volver del segundo plano.
3. Categorías: probar una categoría, varias, todas, `Personal` vacío y `Personal` con frases; Today y recordatorios nunca deben salir del conjunto.
4. Ciclo: misma frase durante el día, avance por varias fechas, relanzamiento, cambio de idioma y agotamiento antes de repetición.
5. Recordatorios: permitir, denegar, cambiar hora/días y apagar cerrando inmediatamente; no debe quedar una notificación propia pendiente.
6. Contenido local: favoritos y frases personales tras relanzar, compartir imagen y borrar.
7. Layout: iPhone pequeño, texto normal y tamaños de accesibilidad, VoiceOver y tarjeta completa sin scroll normal.

## Plan de cierre pequeño

1. Probar build 25 en iPhone y registrar resultados.
2. Publicar privacidad/soporte con alias dedicado; añadir sus enlaces a Settings y sustituir las URL provisionales de la ficha.
3. Decidir si el enlace inteligente entra en 1.0. La recomendación es **sí**, porque ya es un requisito explícito del producto; completar landing/AASA/entitlement y generar una build posterior.
4. Capturar esa build final en inglés y español, completar Content Rights, copyright, App Review privado y App Privacy.
5. Reauditar el archive exacto, pedir autorización separada para App Review y mantener publicación manual.

## Conclusión

El producto, el contenido y el pipeline están cerca del cierre. La cantidad y la calidad de frases **sí son suficientes**. La build 25 **sí sirve para una ronda interna seria de TestFlight**, pero publicar ahora sería prematuro: faltan elementos que Apple considera obligatorios y una función de compartir aprobada que el binario aún no activa.

Fuentes oficiales consultadas: [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) y [DSA trader requirements](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements).
