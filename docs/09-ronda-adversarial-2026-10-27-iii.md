# 09 — Ronda adversarial del contrato de adopción v2 (2026-10-27, III)

**Objeto:** el ADR-0014 propuesto (`docs/adr/0014-adopcion-externa-v2.md`, cinco decisiones D1–D5) a partir de las cinco lecciones del issue #2 (primera adopción conjunta skevi + frontExpert, fase I0–I1 cerrada). **Método:** revisor adversarial de contexto fresco (subagente independiente; no ve el razonamiento, solo la propuesta, el repo y la evidencia del issue #2), solo lectura, veredictos por decisión anclados a archivo + cita textual; **re-verificación independiente de los hallazgos duros por la sesión antes de parchear** (los cuatro confirmados: ADR-0012 §Contrato «todo lo que cubre el manifiesto», `docs/03` §6 con otra forma de handoff, numeración de rondas del README «2ª/3ª» frente a I/II de `docs/07`–`08`, y la aritmética 31 − 3 = 28 del issue #2). Estado base: `609fdbf` + ADR-0014 recién creado. Anclas por texto, no por número de línea.

## Veredictos por decisión

| Decisión | Contenido | Veredicto | Corrección adoptada |
|---|---|---|---|
| D1 | Manifiesto del adoptante al final; upstream = canario | SÓLIDO (H1) | exclusiones separadas de «dentro con digest propio»; aritmética citada |
| D2 | Handoff de plantilla; `docs/handoff.md` fuera de la copia | SÓLIDO (H3) | `docs/03` §6 sumado a los parches |
| D3 | Scripts reubicables (raíz por git, manifiesto parametrizable, `scripts/frontexpert/`) | SÓLIDO | — |
| D4 | Licencia del adoptante es suya (compatibilidad Apache-2.0) | SÓLIDO (H1) | matiz de Consecuencias aplicado |
| D5 | CI: variante «host macOS — runner efímero contenedorizado» | SÓLIDO (N1, N2) | arm64 degradado a forma probada, no requisito; registro propio en el parche |

## Hallazgos y resolución

- **H1 (confirmado → corregido):** D1 mezclaba «excluidas del manifiesto» con «LICENSE dentro con digest propio», divergiendo de la evidencia: el adoptante excluyó exactamente `README.md`, `AGENTS.md`, `docs/handoff.md` y sus ADRs — 31 − 3 = 28 rutas verificadas, con `LICENSE` dentro. **Corregido:** D1 separa **fuera** (las que siempre cambian) de **dentro con digest propio**; Consecuencias acota que lo que cesa es el requisito del contrato, no el hash del canario upstream.
- **H2 (confirmado → corregido):** sin enmienda in place de ADR-0012 §Contrato («todo lo que cubre el manifiesto»), el adoptante copiaría un contrato v1 vivo que le ordena verificar contra el manifiesto upstream — la contradicción exacta que este ADR cierra. **Corregido:** `docs/adr/0012` entra en los parches derivados (precedente: ADR-0012 ya cargaba las enmiendas de ADR-0013 y `docs/08` H5).
- **H3 (confirmado → corregido):** `docs/03` §6 prescribe otra forma de handoff (fase, tarea, último PR, decisiones, bloqueos, siguiente paso) que la canonizada por D2 — dos especificaciones divergentes en el corpus adoptado. **Corregido:** el parche alinea `docs/03` §6 con `plantillas/handoff.md`.
- **H4 (confirmado → corregido):** doble numeración de rondas — el README cuenta «2ª/3ª» (incluyendo la ronda externa de `docs/05`) mientras `docs/07`–`08` y el handoff usan I/II. **Corregido:** el parche de README unifica (romanos para las rondas de revisor de contexto fresco: 07=I, 08=II, 09=III; `docs/05` queda como «ronda externa» aparte).
- **N1:** la variante macOS necesita subsección de registro propia en el runbook (token de un solo uso por `gh api` + stdin, sin `svc.sh`, labels coherentes — un contenedor Linux no lleva label `macos` —, environments y secretos sin cambios). **Absorbido** en el parche de `ci-local.md`.
- **N2:** «Linux arm64» endurecido como requisito era solo la forma probada en Apple Silicon. **Corregido:** «imagen Linux fijada por digest (arm64 en Apple Silicon; la arquitectura sigue al host, no es requisito)».
- **N3:** la lista explícita del adoptante no tenía depósito documentado; la regla heredada no era auditable. **Absorbido:** el parche de `CONTRIBUTING.md` exige depósito (cabecera de su copia del script o su propio CONTRIBUTING).
- **N4:** tras aceptar, quedan falsas dos líneas del README («el manual no ha sido ejecutado», «no consta ejecución de la combinación»). **Absorbido:** el parche las reescribe **con alcance** (ejecutado en I0–I1 web; nativo y fases restantes sin estrenar), no las elimina.

## Verificaciones mecánicas

- El comando de regeneración de la cabecera de `verify-corpus.sh` cubre automáticamente los archivos nuevos de este lote (`docs/adr/0014-*`, este `docs/09`, `plantillas/handoff.md` cuando se aplique): canario 31 → 33 rutas en este lote.
- «Sale de las rutas de copia» choca hoy en dos lugares vivos: README «Siguientes pasos» y ADR-0012 §Contrato — ambos en parches; `docs/08` H5 es registro histórico y queda intacto.
- D5 no contradice ADR-0010: preserva efímero + sin secretos del host; enmienda el runbook por adición declarada.
- Los internos de skevi (ADR-028, v1.5.0), los digests y las cifras de corridas del issue #2 van atribuidos; `609fdbf` verificado como HEAD del adoptante.

## Estado tras la ronda

- **ADR-0014: las cinco decisiones SÓLIDO**; H1–H4 aplicados al texto, N1–N4 absorbidos en los parches derivados. Aceptado por el dueño el 27-oct (misma sesión); parches aplicados en el mismo lote.
- **Parches derivados: aplicados** con la aceptación: `CONTRIBUTING.md`, `plantillas/handoff.md` (nueva), `docs/03` §6, `docs/adr/0012`, `verify-corpus.sh`, `README.md`, `docs/runbooks/ci-local.md` — manifiesto regenerado en el mismo commit (34 archivos).
- **Issue #2: cerrado** con este lote — ADR aceptado, ronda registrada y parches aplicados (práctica del issue #1).
