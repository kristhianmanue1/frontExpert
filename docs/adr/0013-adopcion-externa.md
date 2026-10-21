# ADR-0013 · Adopción externa v1: licencia, manifiesto del corpus y reclasificación del verificador

- **Estado:** aceptado (sesión 21-oct, a partir del issue #1) · **Fecha:** 2026-10-21

## Contexto

El issue #1 (21-oct, ronda adversarial con 3 revisores de contexto fresco, 29 veredictos anclados a archivo:línea) registró la deuda que separa este playbook de una oferta ejecutable a un tercero. El contrato de adopción de ADR-0012 es literalmente **copiar el corpus**, pero: el repo público no tiene LICENSE (todos los derechos reservados → no hay oferta definible); el adoptante no puede verificar qué copió ni detectar drift (la honestidad temporal de las fechas del README es texto, no evidencia); y el inventario de ADRs se contradice entre sí. Convergencias de la ronda: LICENSE = precondición (3/3); el mecanismo ADR-032 de skevi no sirve de vehículo para corpus de terceros (3/3); `verify-stack.sh` no es gate (2/3); los ADRs fantasma son visibles con un `ls docs/adr/` (2/3). El dueño decidió licencia el 21-oct: **Apache-2.0**.

## Problema

Tres amenazas concretas: (1) bloqueo legal de toda adopción externa; (2) adopción sin integridad verificable — un corpus que se copia a mano sin hashes no distingue "versión adoptada" de "copia vieja"; (3) credencial rota: `README:46` decía «ADRs (0001–0012)», `adr/0012:19` decía «(0001–0011)» y la realidad son **8 archivos** — la discrepancia la detectaría cualquier adoptante antes que el maintainer, en un manual que vende disciplina.

## Decisión

1. **Licencia Apache-2.0.** `LICENSE` en raíz + línea SPDX en el README. Alineada con skevi a propósito: el paquete conjunto no exige análisis de compatibilidad de licencias.
2. **Manifiesto propio del corpus, formato `frontexpert/corpus-manifest/v1`.** SHA-256 por archivo en formato `shasum -c` (`.frontexpert/corpus-manifest-v1.sha256`, sin comentarios para compatibilidad con `sha256sum` de GNU) y verificador `scripts/verify-corpus.sh` (solo stdlib, sin red, fail-closed, copiable sin edición). **No reutiliza el mecanismo ADR-032 de skevi**: sus esquemas `skevi/*` son fail-closed, su verificador hardcodea `docs/MANIFEST.json` (colisión de ruta) y arrastraría scripts Python a adoptantes sin skevi — dependencia encubierta que contradice la independencia de ambos cuerpos.
   - **Auto-adopción canaria:** este repo porta su propio manifiesto; el playbook se lo come su propio cocinero antes de ofrecerse.
   - **Cadena de versiones:** los tags `docs-v0.1`/`docs-v0.2` son la historia inicial; el manifiesto v1 nace con este ADR. Regla de régimen: **cualquier cambio al corpus regenera el manifiesto en el mismo commit** (el comando queda documentado en la cabecera de `verify-corpus.sh`).
   - **Procedencia:** `github.com/kristhianmanue1/frontExpert` — ruta canónica pendiente de transferencia a org (`04`, pregunta 8); actualizar la procedencia al transferir.
3. **`verify-stack.sh` reclasificado: observación, no gate.** Es chequeo de vigencia pre-fase contra fuentes primarias; no gobierna CI. Matiz documentado en su cabecera: con `set -euo pipefail`, los greps de cadenas publicadas (§Código publicado) ya lo hacen salir ≠ 0 sin fallo de red — gate de facto parcial que debe estar dicho, no sobreentendido. Un modo futuro `--expect` (exit ≠ 0 ante drift de versión) queda como opción, no se promete.
4. **Inventario de ADRs corregido a una sola verdad.** Firmados: **8** — 0001, 0002, 0004, 0006, 0008, 0010, 0011, 0012. Los vacantes 0003/0005/0007/0009 siguen abiertos como decisiones en `04` (0009 es el citado por `06`). Corrige `README:46` y `adr/0012:19`.

## Consecuencias

- Se vuelve verdad: la copia del adoptante es verificable (`shasum -c`), la oferta legal existe y el inventario de ADRs ya no se contradice.
- Se pierde: la capacidad de tocar el corpus sin regenerar el manifiesto en el mismo commit. Es el punto, no el precio.
- **ADR-0012 queda enmendado** (registrado aquí según la práctica de `05`/`07`): la lista de copia del contrato pasa a ser `docs/` + `plantillas/` + `scripts/` + `.frontexpert/`.
- Abiertos, quedan en el issue #1 y exigen ronda adversarial registrada antes de cerrarse: escalera de precedencia heredable en `plantillas/AGENTS.md` (punto 4), MECHANISM de devolución de lecciones (punto 6) y sección de adopción conjunta con skevi (punto 7).
