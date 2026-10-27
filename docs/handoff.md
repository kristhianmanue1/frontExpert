# Handoff — frontExpert (playbook)

> Estado entre sesiones (se reescribe al cerrar cada una; ver `03 §6`). No es bitácora.

- **Actualizado:** 2026-10-27 (cierre de sesión — ADR-0014 aceptado + parches + issue #2 cerrado).
- **Modelo:** **playbook puro** (ADR-0012) — este repo NO construye producto; produce el "cómo" que otros proyectos adoptan.
- **Fase 0:** cerrada (ADR-0011). **ADRs firmados: 10** — 0001, 0002, 0004, 0006, 0008, 0010, 0011, 0012, 0013 y **0014** (adopción externa v2, aceptado el 27-oct tras la ronda III). Diferidos del corpus: 0003/0005/0007 (antes de fase 3 del adoptante), 0009 (spike de fase 1 del adoptante).
- **Primera adopción: ocurrió** (issue #2): conjunta con skevi v1.5.0, fase I0–I1 cerrada (solo web, nativo diferido), corpus copiado en `609fdbf`. Su cinco lecciones devenieron el **contrato v2** (ADR-0014): manifiesto del adoptante generado al final (upstream = canario), handoff de plantilla (`plantillas/handoff.md`), scripts reubicables (`verify-corpus.sh` con raíz por git y manifiesto por argumento/`CORPUS_MANIFEST`), licencia propia (solo compatibilidad Apache-2.0) y variante CI macOS (runner efímero contenedorizado en `docs/runbooks/ci-local.md`).
- **Issue #2: cerrado.** Atendido con ADR-0014 + ronda adversarial III (`docs/09`: D1–D5 SÓLIDO, H1–H4 corregidos, N1–N4 absorbidos) + parches aplicados al corpus.
- **Licencia:** Apache-2.0 (`LICENSE` + SPDX en README), alineada con skevi (ADR-0013).
- **Integridad:** manifiesto canario `.frontexpert/corpus-manifest-v1.sha256` (**34 archivos**) + `scripts/verify-corpus.sh` (reubicable y parametrizable desde ADR-0014). Regla de régimen: cambio al corpus ⇒ regenerar el manifiesto en el mismo commit (comando en la cabecera del script). `verify-stack.sh` es observación, no gate.
- **Repo:** `github.com/kristhianmanue1/frontExpert` (público), `main` protegida contra force-push y borrado; sin requisito de PR (dueño único). Transferencia a org sigue abierta como decisión aparte.
- **Última verificación:** `verify-stack.sh` 21-oct — sin cambios de major; NativeWind v5 sigue en RC; Vitest corregido a 5.x. `verify-corpus.sh` verde en el lote del 27-oct (34 archivos).
- **En curso:** nada abierto.
- **Siguiente paso:** acompañar las fases restantes del primer adoptante (desde I2); las contradicciones y lecciones vuelven por el canal de `CONTRIBUTING.md`.
- **Reglas activas:** commit/push autorizados por el dueño; merge a `main` solo humano; decisiones de producto, herramientas y hosting = del adoptante, no de este repo.
