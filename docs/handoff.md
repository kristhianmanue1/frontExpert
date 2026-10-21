# Handoff — frontExpert (playbook)

> Estado entre sesiones (se reescribe al cerrar cada una; ver `03 §6`). No es bitácora.

- **Actualizado:** 2026-10-21 (cierre de sesión, tras la ronda II — `docs/08`).
- **Modelo:** **playbook puro** (ADR-0012) — este repo NO construye producto; produce el "cómo" que otros proyectos adoptan. La fase 1 la ejecuta el primer adoptante, en su propio repo.
- **Fase 0:** cerrada (ADR-0011). ADRs de referencia firmados: 0001, 0002, 0004, 0006, 0008, 0010, 0011, 0012, 0013. Diferidos del corpus (se resuelven en cada adopción): 0003/0005/0007 (antes de fase 3 del adoptante), 0009 (spike de fase 1 del adoptante, default: NativeWind 4 + tokens generados).
- **Licencia:** Apache-2.0 (`LICENSE` + SPDX en README), alineada con skevi (ADR-0013).
- **Integridad:** manifiesto canario `.frontexpert/corpus-manifest-v1.sha256` (31 archivos) + `scripts/verify-corpus.sh`. Regla de régimen: cambio al corpus ⇒ regenerar el manifiesto en el mismo commit (comando en la cabecera del script). `verify-stack.sh` es observación, no gate.
- **Issue #1: cerrado.** Los 7 puntos atendidos: 1–3 y 5 con ADR-0013 (`c0bc4f2`); 4 (escalera de precedencia en `plantillas/AGENTS.md` + `AGENTS.md` raíz canario), 6 (`CONTRIBUTING.md` + plantilla de issue «Lección de adopción») y 7 (sección skevi en README) con la ronda registrada en `docs/08`.
- **Repo:** `github.com/kristhianmanue1/frontExpert` (**público** desde 21-oct), `main` sincronizada. Precondición del canal de lecciones: **cumplida** — los terceros ya abren issues de lección (`CONTRIBUTING.md`). Protección de rama: disponible en repos públicos con GitHub Free; pendiente de decisión del dueño (activarla exigiría PRs y cambiaría el flujo directo actual; `04`, pregunta 8).
- **Última verificación:** `verify-stack.sh` 21-oct — sin cambios de major; NativeWind v5 sigue en RC; Vitest corregido a 5.x. `verify-corpus.sh` verde en el lote de `docs/08`.
- **En curso:** nada abierto.
- **Siguiente paso:** preparar la **primera adopción** — identificar el adoptante, entregarle el corpus (todo lo que cubre el manifiesto) y acompañar su fase 1; el manual se estrena con ella y las contradicciones vuelven por `CONTRIBUTING.md`.
- **Reglas activas:** commit/push autorizados por el dueño; merge a `main` solo humano; decisiones de producto, herramientas y hosting = del adoptante, no de este repo.
