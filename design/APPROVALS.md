# Warm Words — manifiesto canónico de aprobaciones visuales

Actualizado: **2026-08-31**

Este archivo es la fuente de verdad de las imágenes completas aprobadas que gobiernan la app iOS. Una referencia `vigente` define la dirección visual de una pantalla o salida; no implica por sí sola que exista una captura equivalente de la build real. Las propuestas no elegidas, referencias retiradas, assets fuente y capturas runtime se registran por separado.

## Referencias vigentes

| ID | Pantalla / estado | Ruta canónica | Lienzo o dispositivo | Orientación | Idioma de la referencia | Aprobación | SHA-256 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| WW-SCREEN-001 | Today — texto normal, carta completa y acciones visibles | `docs/design/reminder-v2/warm-words-today-compact-proposal.png` | iPhone, 853 × 1844 px | Vertical | Inglés; la misma dirección gobierna español | 2026-08-09; reafirmada 2026-08-10 | `a0bf19666b5f467156fecf813614fe1a0226f30dead7fe9b877d48462e7de144` |
| WW-SCREEN-002A | Primer inicio — intereses antes del horario | `docs/design/onboarding-interests/warm-words-onboarding-interests-approved.png` | iPhone, 853 × 1844 px | Vertical | Inglés; la misma dirección gobierna español | 2026-08-18; copy y simplificación reafirmados 2026-08-18 | `a1fafe50ce5a4ccff593b039befe49730023e67156d5865f2bb3e5b4615f25d7` |
| WW-SCREEN-002B | Primer inicio — hora y siete días seleccionados | `docs/design/reminder-v2/warm-words-onboarding-proposal.png` | iPhone, 853 × 1844 px | Vertical | Inglés; la misma dirección gobierna español | 2026-08-09; reactivada como segunda pantalla 2026-08-18 | `9de1202b16a5715ccd0c1ae0742446bdcb218ab1a131317724f17dbc8a812d72` |
| WW-SCREEN-003 | Settings — recordatorio activado, hora, días y categorías | `docs/design/reminder-v2/warm-words-settings-proposal.png` | iPhone, 853 × 1844 px | Vertical | Inglés; la misma dirección gobierna español | 2026-08-09 | `e349f6b2efc922c28325732a59cf078de041cb6f0e8a9eb3990170585c05216c` |
| WW-SCREEN-004 | Frase personal recibida — vista previa y guardado explícito | `docs/design/share-link/warm-words-shared-personal-quote-approved.png` | iPhone, 853 × 1844 px | Vertical | Inglés; la misma dirección y copy localizado gobiernan español | 2026-08-12; aprobación directa conforme a DEC-019 y alcance aprobado en DEC-029 | `1b8770c8764652326156c7723e9a71f5dff6fd5a46d237d42e3e34b7a8540ada` |
| WW-OUTPUT-001 | Tarjeta compartida — cita, categoría y marca | `docs/design/share-card/warm-words-share-card-approved.png` | Referencia 1122 × 1402 px; salida runtime 1080 × 1350 px | Vertical | Inglés; el renderer usa el idioma activo | 2026-08-10 | `8d2fe0df07d4aeaa12c1348ed42ad07de927a76b5d81f054cb2014d744b2fb7d` |

### Cambios aprobados que matizan las referencias

- **WW-SCREEN-001:** se retiraron la franja promocional y `Explore categories`. La carta usa todo el ancho útil y el alto restante; favorito y compartir permanecen visibles sobre la barra de pestañas sin desplazamiento con texto normal. Dynamic Type de accesibilidad puede crecer y desplazarse para evitar recortes.
- **WW-SCREEN-002A/002B:** la primera pantalla contiene exclusivamente intereses y la segunda conserva hora/días. Por aprobación expresa posterior se eliminan ambos indicadores `Step … of 2`, el encabezado `Quote categories`, la explicación de selección predeterminada y `Not now` de la primera pantalla. Su pregunta vigente es `What would help you today?` / `¿Qué te ayudaría hoy?`. `Continue` solo mueve el borrador; el permiso se solicita después de `Set reminder`. `Back` conserva la selección y `Not now` permanece en la segunda pantalla para completar el onboarding sin activar recordatorios.
- **WW-SCREEN-003:** la imagen conserva la dirección de arte y jerarquía vigentes, pero no es una captura exacta de build 20. El propietario aprobó después el selector inmediato `English / Español` y retiró la creación de categorías propias; las frases nuevas van a `Personal`. Estas correcciones no autorizan un rediseño.
- **WW-SCREEN-004:** aparece únicamente al abrir un enlace de frase válido. Reutiliza el fondo, paleta y jerarquía aprobados; una frase personal no se importa hasta tocar `Save to Personal & Favorites`. La versión española localiza la interfaz, pero conserva literalmente el texto personal recibido.
- **WW-OUTPUT-001:** la app recrea la composición en tiempo de ejecución; la imagen de referencia no se empaqueta. Ninguna build con el enlace activo puede distribuirse hasta que landing, AASA y Associated Domains sean reales y estén verificados.

## AppIcon vigente y asset integrado

| Función | Ruta | Lienzo | Aprobación | SHA-256 |
| --- | --- | --- | --- | --- |
| Dirección aprobada C — Protected thought | `docs/design/app-icon/warm-words-app-icon-proposal-c.png` | 1254 × 1254 px, cuadrado, sin idioma | 2026-08-09 | `2350382ff77a1f4556c6b8bfd17e3f659b34dc91e71ae62a6d378f32414ecd4b` |
| Master runtime derivado sin cambio visual | `native-ios/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` | 1024 × 1024 px, RGB opaco | 2026-08-09 | `c8aa83e32338289179c5c24f025dd96ed3b9a3af677280e47879683bba0b3af6` |

## Referencias retiradas o reemplazadas

| Pantalla / estado | Ruta histórica | Estado | Fecha | SHA-256 |
| --- | --- | --- | --- | --- |
| Primer inicio combinado — hora, días y categorías en una pantalla desplazable | `docs/design/onboarding-categories/warm-words-onboarding-categories-approved.png` | **Reemplazada** por el flujo `WW-SCREEN-002A/002B`: el propietario indicó que los intereses no resultaban visibles y pidió una pantalla exclusiva antes del horario. | 2026-08-18 | `702ca82fd47af567a6d7ce21228cef7b085dc9640c606241e01bf75aa0956004` |
| New personal quote — creación inline de categoría | `docs/design/reminder-v2/warm-words-new-category-proposal.png` | **Retirada**: fue aprobada el 2026-08-09, pero la función se eliminó por decisión del propietario el 2026-08-10. Las frases nuevas van directamente a `Personal`; no existe pantalla sustituta. | 2026-08-10 | `9d145129c8a98060ad5e2df536d9f54f47563c2c6c2ef031bdcc140e603ac992` |

La interpretación estrecha de Today usada en builds 13 y 14 quedó reemplazada por `WW-SCREEN-001`; no tenía una imagen maestra propia y no debe reconstruirse.

## Propuestas no vigentes

| Propuesta | Ruta | Resultado | SHA-256 |
| --- | --- | --- | --- |
| AppIcon A — primera exploración | `docs/design/app-icon/warm-words-app-icon-proposal-a.png` | No elegida y reemplazada durante exploración | `19b51f8988b0083221cb2b32f39fa98141ca0dd33581d5258c06ab103c9988bb` |
| AppIcon A v2 — Words at sunrise | `docs/design/app-icon/warm-words-app-icon-proposal-a-v2.png` | No elegida | `32fddc4022ee60927d00ecc6f8257018d8199bee72c1ec80543b01fdaf560084` |
| AppIcon B — Warm quotation heart | `docs/design/app-icon/warm-words-app-icon-proposal-b.png` | No elegida | `7a473450d24c43c15966af53844c892e03d288967bcd06013ffa9ed485885a51` |

Estas propuestas se conservan como historial. No pueden usarse como dirección vigente sin una nueva aprobación explícita.

## Assets fuente separados de las maestras

| Asset | Ruta | Lienzo | SHA-256 | Estado |
| --- | --- | --- | --- | --- |
| Fondo de montaña | `native-ios/Resources/premium-mountains.png` | 853 × 1844 px | `fc2838f54cb96c701714c284e144f7fd4cb1c75aededb7fb093a5309becf488b` | Runtime; derechos comerciales pendientes de confirmación |
| Fondo de piedras | `native-ios/Resources/premium-stones.png` | 853 × 1844 px | `d4d4051a0b49bf85097099c95f92fe05719fea2a926c8131518a505806adff14` | Runtime; derechos comerciales pendientes de confirmación |

## Capturas de implementación y App Store

El run `33434927989`, commit de captura `933238e`, generó capturas runtime sin tratamiento desde el mismo código de aplicación que build 30. Todas son PNG RGB opacas, verticales, 1320 × 2868 px, en un simulador iPhone 16 Pro Max de 6,9 pulgadas. La selección de tienda conserva solo los estados visualmente limpios; los recorridos restantes se mantienen como evidencia y no deben subirse.

| ID | Estado | Ruta | Idioma | Fecha | SHA-256 |
| --- | --- | --- | --- | --- | --- |
| WW-STORE-EN-001 | Today — vigente para tienda | `store/app-store/ios/build-30/en/01-today-en.png` | Inglés | 2026-08-31 | `5e384b24a2e0c76904645b113edf4653917d8f6e4c45f4c3f13e7ffa7083c846` |
| WW-STORE-EN-002 | Categories — vigente para tienda | `store/app-store/ios/build-30/en/02-categories-en.png` | Inglés | 2026-08-31 | `d79f64edfea1800e40705833c31724edb056f35791a75f26120c5208e78c6209` |
| WW-STORE-EN-003 | Favorites — vigente para tienda | `store/app-store/ios/build-30/en/04-favorites-en.png` | Inglés | 2026-08-31 | `8fb669e599a55608d34452616a215510a1928eb9334db60f2532ca51272b01bc` |
| WW-STORE-EN-004 | Settings con Privacidad y Soporte — vigente para tienda | `store/app-store/ios/build-30/en/06-settings-en.png` | Inglés | 2026-08-31 | `cc3b155f038941a893ff52ff3eaaf00981a7c0ecae28b70f09b5046676695c71` |
| WW-STORE-ES-001 | Hoy — vigente para tienda | `store/app-store/ios/build-30/es/01-today-es.png` | Español | 2026-08-31 | `4ca6789596c0e48dd6b353740a2df3867c75a60855e70c2126df6d0dca024b19` |
| WW-STORE-ES-002 | Categorías — vigente para tienda | `store/app-store/ios/build-30/es/02-categories-es.png` | Español | 2026-08-31 | `4308b4bd976ba474e409c35a35d50cb8822ec12d4c8ec30c1a289645659cd828` |
| WW-STORE-ES-003 | Favoritos — vigente para tienda | `store/app-store/ios/build-30/es/04-favorites-es.png` | Español | 2026-08-31 | `d6a87f1f75f1b46762d04aa3ec1f9f14a8a5fbf8a71974bffd3a9394850e9359` |
| WW-STORE-ES-004 | Ajustes con Privacidad y Soporte — vigente para tienda | `store/app-store/ios/build-30/es/06-settings-es.png` | Español | 2026-08-31 | `7d14df4a6fd0f10b43d0c136356167798620a54e3f1146318b06daf19911b38c` |

### Evidencia runtime no seleccionada para tienda

| Estado | Ruta | Motivo de no selección | SHA-256 |
| --- | --- | --- | --- |
| Motivation | `store/app-store/ios/build-30/en/03-motivation-en.png` | El desplazamiento deja contenido bajo la barra de estado; no es una imagen de tienda pulida. | `30a2a0ee9d3fede7bc18eda826197921fc2df51846ce093bc4fd89a9228e93c9` |
| Personal | `store/app-store/ios/build-30/en/05-personal-en.png` | El estado comienza a mitad del grid y recorta el encabezado; se conserva solo como evidencia. | `e8463867f3674888d08ba5c7f3c4e7b0bd72a777f462c0af5abeb7c80393afab` |
| Motivación | `store/app-store/ios/build-30/es/03-motivation-es.png` | El desplazamiento deja contenido bajo la barra de estado; no es una imagen de tienda pulida. | `3ae5b1280a7b8965b7c2fead590b4f4cf95b8265688b0e69d08ff5c817d20627` |
| Personales | `store/app-store/ios/build-30/es/05-personal-es.png` | El estado comienza a mitad del grid y recorta el encabezado; se conserva solo como evidencia. | `6be9d2b5fdbfe1ff24c05c41a38d944de5d82e173db625656671bba0f69bfe97` |

Las imágenes de App Store pueden usar las maestras vigentes como dirección de arte, pero su captura base debe proceder de la build real. Toda composición o tratamiento de tienda deberá enlazar tanto la captura base como el ID visual correspondiente de este manifiesto.

## Cobertura actual

Las pantallas existentes de Categories, detalle de categoría y la hoja actual de nueva frase fueron estabilizadas sin rediseño visual-first y no tienen una imagen completa aprobada en el repositorio. Esta ausencia no autoriza a rediseñarlas: su fuente actual es la build real. Si cambian materialmente, necesitarán una nueva imagen completa aprobada y una entrada vigente antes de implementar el resultado visual final.

## Regla de sustitución

Solo puede existir una referencia vigente por pantalla y estado. Cuando el propietario apruebe una sustitución:

1. se añade la nueva imagen sin sobrescribir archivos existentes;
2. se registra su fecha, lienzo, orientación, idioma y SHA-256;
3. la referencia anterior pasa a `Referencias retiradas o reemplazadas` con el motivo;
4. las capturas runtime y de tienda se vuelven a enlazar o se marcan históricas.
