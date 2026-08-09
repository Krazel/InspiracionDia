# AUD-001 — Auditoría de cierre iOS 1.0

Fecha de corte: **2026-08-08**
Repositorio auditado: `C:\Users\dmkra\Documents\Codex Apps\InspiracionDiaNative`
Alcance: **iOS solamente**, versión 1.0 provisionalmente solo en inglés. Android se ha ignorado y no se ha modificado.

## Dictamen

**No está listo para cerrar ni enviar como iOS 1.0.** La base SwiftUI y el contenido existente permiten un cierre acotado y no justifican un rediseño. Los bloqueos reales son: el producto sigue siendo español por defecto y sus 180 frases solo están en español; la notificación diaria repite el mismo texto; no existe icono de app; falta el manifiesto de privacidad exigible por el uso de `UserDefaults`; no hay build firmada/archivada para App Store; y la ficha de tienda inglesa, las URLs, las capturas y las declaraciones de App Store Connect no están preparadas.

La decisión visual es conservadora: **mantener las pantallas actuales**, corregir cierre, probarlas en dispositivo y crear únicamente el icono obligatorio. Toda pantalla nueva o rediseño futuro necesitaría antes una imagen aprobada; AUD-001 no recomienda abrir ese trabajo.

## Fotografía verificable

| Área | Evidencia observada | Estado para 1.0 |
|---|---|---|
| Git | `main` y `origin/main` remoto coinciden en `c8fac196d53c889b2125e0760ced49fd26c9666e`. El commit remoto se verificó mediante GitHub. | Base reproducible. |
| Trabajo local preservado | Siguen presentes únicamente `M .gitignore` y `?? store/store-manifest.json`. `.gitignore` añade exclusiones de `*.p8` y cuentas de servicio; `git check-ignore` confirma las reglas. | **No descartar ni sobrescribir.** |
| Implementación | Una app SwiftUI nativa en `native-ios/`; `InspiracionDiaApp.swift` tiene 1.018 líneas. Target declarado iOS 16.0, Swift 5.9, versión 1.0, build 1, bundle ID `com.dmkr.inspiraciondia`. | Aprovechable, pero sin separación ni tests. |
| Contenido | `content.json` contiene 180 frases únicas, 12 categorías y 15 frases por categoría. Longitud 37–87 caracteres. Coincide byte a byte a nivel de estructura JSON con las fuentes `data/*.js`. | Contenido consistente, pero **solo español**. |
| Idioma | Hay 40 claves aproximadamente de interfaz en español/inglés y nombres ingleses de categorías. El valor inicial y el fallback persistido son `es`; las frases, descripciones de categoría, nombre, permiso de notificación y manifest de tienda son españoles. La fecha usa el locale del dispositivo. | **Bloqueo del alcance inglés.** No existe localización inglesa completa. |
| Favoritos | IDs guardados en `UserDefaults`; favoritos de frases incluidas y propias se reconstruyen al iniciar. | Conservar y probar migración/reinicio. |
| Tarjetas propias | Se crean localmente con UUID, categoría y texto, y se persisten como JSON en `UserDefaults`. Se pueden compartir y marcar como favoritas. No se pueden editar ni borrar; una entrada vacía cierra la hoja sin crear nada; seleccionar “Manual” tras crear no queda persistido. | Función parcial; requiere cierre mínimo de ciclo de vida. |
| Compartir | `ShareLink` comparte texto plano y la firma `Inspiracion Dia` desde la frase del día y las listas. | Suficiente para 1.0 si compartir texto —no imagen— es la promesa aceptada. Probar hoja real. |
| Notificación | Solicita autorización y crea un `UNCalendarNotificationTrigger` diario. Hora y categorías se guardan. El contenido de la notificación se calcula una sola vez al programar un trigger repetitivo. | **Defecto funcional:** repite indefinidamente la misma frase, aunque la app promete inspiración diaria. Cambio de idioma tampoco la actualiza. |
| Entrada de hora | Campo de texto libre; entradas incompletas o inválidas se convierten silenciosamente (`9` → `09:30`, valores altos se limitan a `23:59`) y la vista no refleja de inmediato el valor normalizado. | Riesgo de configuración y accesibilidad; usar/controlar una hora válida. |
| Assets | `premium-mountains.png` y `premium-stones.png`, ambos 853×1844; SHA-256 `FC2838…F488B` y `D4D405…FF14`. El workflow comprueba que se empaqueten. No hay `.xcassets`. | Fondos reutilizables de forma provisional; falta confirmar derechos y QA visual en dispositivo. |
| Icono | `ASSETCATALOG_COMPILER_APPICON_NAME` está vacío y no existe catálogo `AppIcon`. | **Bloqueo de distribución.** |
| Accesibilidad | No hay labels/hints/traits explícitos. Varios botones son solo iconos; la selección de categorías depende mucho de color/borde; hay tipografías de tamaño fijo y grids de 3 columnas. El dorado `#A67C2D` da entre **3,09:1 y 3,79:1** sobre los fondos claros usados, por debajo de 4,5:1 para texto normal. | Requiere VoiceOver, Dynamic Type, contraste y áreas táctiles en dispositivo. No asumir conformidad. |
| Privacidad técnica | No hay dependencias de terceros ni red en el código iOS observado. Datos, frases y preferencias son locales. Sí se usa `UserDefaults` repetidamente y no existe `PrivacyInfo.xcprivacy`. | Añadir manifiesto con `NSPrivacyAccessedAPICategoryUserDefaults` y el motivo aplicable `CA92.1`; declarar “no data collected” solo tras validar el binario final. |
| Tests | No hay targets unitarios/UI, `.xctestplan` ni pruebas automatizadas Swift. | Cobertura cero; como mínimo tests de lógica y un smoke UI antes del candidato. |
| Build remoto | Workflow `Build unsigned iOS IPA`: XcodeGen + `xcodebuild` Release con firma desactivada. Las cinco ejecuciones listadas más recientes terminaron bien; la última fue el 2026-05-17, run `26000021481`, y publicó build 8 de 4.965.620 bytes. | Prueba compilación, **no** validez App Store. |
| Distribución | `DEVELOPMENT_TEAM` vacío, firma manual, `CODE_SIGNING_ALLOWED=NO`; no hay archive/export/upload/TestFlight ni validación de App Store. El runner no fija ni registra explícitamente Xcode 26. | **Bloqueo externo/técnico.** Desde 2026-04-28 Apple exige iOS 26 SDK o posterior para uploads. |
| Tienda | `store/store-manifest.json` es local/no versionado, solo tiene `es-ES`, URLs vacías y cero capturas. No consta ficha de App Store Connect, categoría, precio, edad, privacidad, derechos, export compliance ni disponibilidad. | **Incompleto.** No usar el texto actual para el lanzamiento inglés. |

### Trazabilidad remota

- Commit auditado: [c8fac196](https://github.com/Krazel/InspiracionDia/commit/c8fac196d53c889b2125e0760ced49fd26c9666e)
- Último run observado: [GitHub Actions 26000021481](https://github.com/Krazel/InspiracionDia/actions/runs/26000021481)
- Release de QA unsigned: [latest-ipa](https://github.com/Krazel/InspiracionDia/releases/tag/latest-ipa)

## Pruebas posibles en Windows

### Ejecutadas y aprobadas

1. Estado Git, diff de `.gitignore`, presencia del manifest y coincidencia del SHA local/remoto.
2. `node scripts/check-quotes.mjs`: **180 frases revisadas en 12 categorías**, sin IDs desconocidos ni longitudes fuera de 32–138.
3. Validación adicional: 0 IDs duplicados, 0 textos duplicados, 15 frases por categoría.
4. Comparación en memoria entre `data/categories.js` + `data/quotes.js` y `native-ios/Resources/content.json`: **MATCH**; no se regeneró ni escribió el recurso.
5. Parseo de `content.json`, `store-manifest.json` e `Info.plist`: correcto.
6. Existencia, dimensiones, tamaño y SHA-256 de los dos PNG.
7. Cálculo estático de contraste de la paleta principal.
8. Inspección estática de SwiftUI, persistencia, notificaciones, compartir, tarjetas, assets, configuración XcodeGen y workflow.
9. Consulta remota de solo lectura de runs y release de GitHub.

### Posibles todavía en Windows

- Añadir al cierre validadores no mutantes para estructura de contenido inglés, claves de localización, catálogo de iconos, `PrivacyInfo.xcprivacy`, URLs/longitudes de metadata y consistencia de versión/build.
- Revisar el contenido inglés con herramientas lingüísticas, pero la aceptación editorial necesita propietario o revisor humano.
- Inspeccionar una IPA descargada: plist efectivo, recursos, arquitecturas y ausencia/presencia de firma. Esto no sustituye Validate App.

### No demostrable en Windows

- Compilar Swift/XcodeGen con el SDK exigido, archivar, firmar, validar o subir a App Store Connect.
- Probar SwiftUI en simulador, iPhone/iPad, iOS 16 e iOS 26.
- Verificar VoiceOver, Dynamic Type, Reduce Motion, contraste real, safe areas, teclado y orientación.
- Verificar autorización/denegación de notificaciones, entrega con la app cerrada, cambio de zona horaria y variación entre días.
- Verificar `ShareLink`, persistencia después de reinicio/actualización, instalación TestFlight, icono, launch screen y capturas finales.

## Defectos y riesgos ordenados

### P0 — bloquean candidato o envío

1. **El alcance inglés no está implementado.** Clean install abre en español; las 180 frases no tienen variante inglesa; fecha, nombre, permiso y metadata tampoco están cerrados en inglés. El selector interno no convierte el producto en bilingüe. Hay que elegir el contenido inglés de 1.0 o registrar una excepción explícita para lanzar en español.
2. **No existe AppIcon.** Apple exige un icono integrado en el build; el proyecto desactiva expresamente el nombre del catálogo.
3. **Falta el privacy manifest.** El código usa `UserDefaults`, una required-reason API. Apple no acepta una app que omita el motivo aprobado aplicable. Para el uso local observado corresponde `CA92.1`, sujeto a validar el binario final.
4. **La notificación diaria incumple su promesa.** Un trigger repetitivo conserva el mismo título/cuerpo. Debe programarse una secuencia de frases distintas o redefinirse honestamente la promesa antes de tienda.
5. **No existe artefacto distribuible por App Store.** La IPA pública es unsigned. Faltan team/certificados, archive, firma de distribución, Validate App, upload, procesamiento y TestFlight. El build final debe usar Xcode 26 / iOS 26 SDK o posterior.
6. **Paquete de App Store incompleto.** Falta metadata inglesa, al menos una captura admitida, Support URL real, Privacy Policy URL, app privacy, edad, categoría, precio, disponibilidad, copyright, derechos de contenido y respuesta de export compliance.

### P1 — deben cerrarse antes de aprobar 1.0

7. **Accesibilidad sin evidencia y contraste insuficiente para texto pequeño.** Añadir semántica a iconos/selecciones, revisar tamaños fijos y grids, y corregir usos de dorado que funcionen como texto normal.
8. **Tarjetas propias sin editar/borrar y con fallo silencioso al guardar vacío.** Al menos permitir borrar y no cerrar una creación inválida; decidir si editar entra en 1.0.
9. **Hora de notificación frágil.** Sustituir o reforzar el texto libre, mostrar el valor efectivo y probar locales/teclado/VoiceOver.
10. **Sin pruebas automatizadas ni QA en Apple.** Riesgo alto en fecha/frase, filtros, persistencia, normalización horaria y programación de notificaciones.
11. **Familia de dispositivos no fijada.** `TARGETED_DEVICE_FAMILY` no está declarada. Confirmar en el proyecto generado si es universal; si incluye iPad, probar iPad y preparar sus capturas requeridas, o limitar 1.0 a iPhone.
12. **Derechos no documentados.** Confirmar autoría/licencia de las 180 frases y de ambos fondos antes de marcar Content Rights.

### P2 — deuda aceptable solo si queda registrada

13. `AppStore`, datos, servicios y todas las vistas viven en un único archivo de 1.018 líneas; dificulta tests y cierre seguro, aunque no exige una refactorización total para 1.0.
14. Las 180 tarjetas se renderizan en `VStack`, no `LazyVStack`; medir memoria/scroll en un iPhone mínimo antes de optimizar.
15. Fallar al cargar `content.json` queda oculto tras una frase fallback y categorías vacías. Conviene una aserción/test de bundle y un estado de error controlado.
16. Las tarjetas propias se guardan sin límite en `UserDefaults`; aceptar un límite pequeño o migrar más adelante si el producto espera muchas.
17. El workflow publica IPAs unsigned en una release pública en cada push a `main` y conserva assets versionados anteriores. Puede mantenerse como QA, pero debe separarse claramente del canal firmado y revisarse si se desea exposición pública.
18. README y documentos antiguos ordenan paridad Android. Contradicen la decisión vigente iOS-first; no mantener Android y actualizar esa documentación solo dentro del hito de cierre autorizado.

## Qué puede conservarse

- La arquitectura nativa SwiftUI, deployment target iOS 16 y navegación de tres pestañas.
- La jerarquía visual actual, paleta, componentes y dos fondos; no hay evidencia que justifique rediseño. Sí hay que ajustar contraste/semántica sin cambiar el concepto.
- Las 12 categorías, IDs y 180 frases españolas como contenido heredado intacto. No cuentan como contenido inglés.
- Persistencia local de favoritos, selección, preferencias y tarjetas propias, añadiendo privacidad y cierres puntuales.
- `ShareLink` de texto como implementación 1.0, si el propietario confirma que “compartir” no promete una tarjeta-imagen.
- El workflow unsigned como comprobación de compilación/QA, no como entrega de tienda.
- `.gitignore` modificado y `store/store-manifest.json` local, preservados exactamente durante AUD-001.

## ¿Necesita nuevas imágenes aprobadas?

**Sí, una: el AppIcon obligatorio.** Debe diseñarse, aprobarse expresamente y convertirse en el catálogo de tamaños/variantes que acepte el Xcode usado. No se recomienda generar nuevas imágenes de pantalla ni sustituir `premium-mountains.png` o `premium-stones.png` para 1.0.

También hacen falta capturas reales de App Store en inglés. Son evidencia del producto terminado, no permiso para rediseñar: deben tomarse después del QA en el dispositivo objetivo, sin transparencias y en tamaños aceptados por App Store Connect. Apple admite de una a diez; si se usa el set de mayor resolución compatible puede escalarlo a tamaños menores. Si se añaden marcos, fondos o copy promocional fuera de la captura real, esas composiciones sí deben aprobarse como nuevos materiales visuales.

## Plan de cierre pequeño

1. **Congelar decisiones (propietario, una sesión).** Resolver idioma/nombre, tamaño del catálogo inglés, semántica de notificación, tarjetas propias, familia iPhone/iPad, icono, URLs y derechos.
2. **Cerrar producto sin rediseño.** Hacer inglés el clean install y todo el contenido público; preservar español sin mantenerlo; programar frases diarias distintas; cerrar validación/borrado de tarjetas; corregir hora, accesibilidad crítica, privacy manifest e icono aprobado. Añadir tests de lógica de alto riesgo.
3. **Crear candidato en Apple.** Generar con Xcode 26+, fijar team/firma, archivar, ejecutar Analyze/Validate App y subir a TestFlight. Registrar versión/build y confirmar el target de dispositivo.
4. **QA corto en dispositivo.** iOS 16 y iOS 26, iPhone pequeño y grande; iPad solo si se mantiene universal. Probar clean install/update, inglés, contenido, favoritos, tarjetas, compartir, permisos, notificación variable, reinicio, VoiceOver, Dynamic Type y contraste.
5. **Cerrar tienda.** Metadata inglesa, icono, capturas, URLs, política, privacy label, edad, categoría, precio, disponibilidad, derechos y export compliance; asociar el build validado.
6. **Puerta del propietario.** Revisar checklist y TestFlight. Enviar a App Review únicamente con autorización expresa en ese momento.

## Decisiones concretas del propietario

1. **Nombre público:** conservar `Inspiracion Dia` como marca española dentro de un producto inglés, corregirlo a `Inspiración Día`, o adoptar un nombre inglés. Recomendación: decidir antes del icono y del registro App Store.
2. **Contenido inglés 1.0:** traducir/revisar las 180 frases o lanzar un subconjunto inglés menor y honesto. Recomendación: catálogo menor si es la única forma de mantener el cierre pequeño; no presentar frases españolas como inglés.
3. **Español heredado:** ocultar el selector en 1.0 y conservar datos/copy sin mantenimiento, o declarar la excepción bilingüe. Recomendación: inglés por defecto y español preservado fuera del alcance público hasta una fase posterior.
4. **Notificación:** confirmar que debe traer una frase distinta cada día. Recomendación: sí; es la promesa central y la tienda no debe anunciarlo mientras repita texto.
5. **Compartir:** confirmar texto plano o exigir tarjeta-imagen. Recomendación: texto plano para 1.0; una tarjeta visual ampliaría diseño y assets.
6. **Tarjetas propias:** confirmar si 1.0 necesita editar además de borrar. Recomendación mínima: crear, validar y borrar; posponer edición si se declara.
7. **Dispositivos:** iPhone-only o universal iPhone+iPad. Recomendación: iPhone-only para el cierre pequeño, salvo compromiso previo con iPad.
8. **Icono:** aprobar una dirección visual específica antes de implementarlo. Es la única imagen de producto nueva imprescindible.
9. **Fondos y frases:** confirmar autoría/licencias y permiso comercial de ambos PNG y del catálogo de frases.
10. **Privacidad/soporte:** elegir dominio y contacto público para Privacy Policy URL y Support URL; confirmar que el binario final no recoge datos.
11. **Tienda:** categoría primaria, precio (recomendado gratis si no hay monetización), territorios, edad, copyright y fecha objetivo.
12. **Cuenta Apple:** confirmar que el bundle ID `com.dmkr.inspiraciondia` está disponible/registrado, que la membresía está activa y quién custodia firma/App Store Connect.
13. **QA público:** decidir si se conserva la release pública de IPAs unsigned o se limita el acceso. No afecta Android y no autoriza publicar una build firmada.
14. **Excepción de idioma:** si se decide lanzar en español o bilingüe, registrarlo expresamente como excepción a la regla de cartera; hoy no hay base verificable para considerar terminada la localización inglesa.

## Requisitos Apple consultados

- Desde el 28 de abril de 2026, los uploads iOS/iPadOS deben usar iOS/iPadOS 26 SDK o posterior: [Upcoming SDK minimum requirements](https://developer.apple.com/news/?id=ueeok6yw).
- Apple exige archivar y enviar una build distribuible a App Store Connect; una IPA unsigned no equivale a ello: [Distribution](https://developer.apple.com/documentation/technologyoverviews/distribution) y [Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/).
- Icono integrado en el build: [Add an app icon](https://developer.apple.com/help/app-store-connect/manage-app-information/add-an-app-icon).
- Privacy Policy URL obligatoria y declaración de prácticas de datos: [App privacy](https://developer.apple.com/help/app-store-connect/reference/app-privacy/) y [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy).
- Required-reason APIs y motivo de `UserDefaults`: [Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api) y [NSPrivacyAccessedAPIType](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype).
- Metadata, Support URL y capturas: [Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), [Upload app previews and screenshots](https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots/) y [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications).
- Edad, derechos y otra información del registro: [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information).
- Declaración de cifrado: [Overview of export compliance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance).

## Condición de cierre de AUD-001

AUD-001 queda documentada, no implementada. La siguiente tarea puede comenzar solo después de resolver las decisiones 1–8 y debe seguir siendo propietaria exclusiva de la implementación iOS. Android queda fuera; no se ha modificado código, assets, manifest existente, `.gitignore`, Git, GitHub ni App Store.
