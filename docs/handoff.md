# Handoff — frontExpert (playbook)

> Estado entre sesiones (se reescribe al cerrar cada una; ver `03 §6`). No es bitácora.

- **Actualizado:** 2026-10-21 (cierre de sesión, tras ADR-0013).
- **Modelo:** **playbook puro** (ADR-0012) — este repo NO construye producto; produce el "cómo" que otros proyectos adoptan. La fase 1 la ejecuta el primer adoptante, en su propio repo.
- **Fase 0:** cerrada (ADR-0011). ADRs de referencia firmados: 0001, 0002, 0004, 0006, 0008, 0010, 0011, 0012, 0013. Diferidos del corpus (se resuelven en cada adopción): 0003/0005/0007 (antes de fase 3 del adoptante), 0009 (spike de fase 1 del adoptante, default: NativeWind 4 + tokens generados).
- **Licencia:** Apache-2.0 (`LICENSE` + SPDX en README), alineada con skevi. Decisión del dueño (21-oct), formalizada en ADR-0013.
- **Integridad:** manifiesto canario `.frontexpert/corpus-manifest-v1.sha256` + `scripts/verify-corpus.sh` (ADR-0013). **Regla de régimen:** cualquier cambio al corpus regenera el manifiesto en el mismo commit (comando en la cabecera del script). `verify-stack.sh` quedó reclasificado: observación, no gate.
- **Repo:** `github.com/kristhianmanue1/frontExpert` (privado), `main` sincronizado. Protección de rama diferida (GitHub Free): procedural; sin PRs de agente en este repo, el riesgo es bajo.
- **Última verificación:** `verify-stack.sh` 21-oct — sin cambios de major; NativeWind v5 sigue en RC; Vitest corregido a 5.x. `verify-corpus.sh` verde en el lote ADR-0013.
- **Deuda viva:** issue #1 — puntos 4 (escalera de precedencia en `plantillas/AGENTS.md`), 6 (MECHANISM de devolución de lecciones) y 7 (sección de adopción conjunta con skevi); exigen ronda adversarial registrada antes de cerrarse. Puntos 1 (LICENSE), 2 (manifiesto), 3 (ADRs fantasma) y 5 (reclasificación) quedaron atendidos con ADR-0013.
- **En curso:** nada abierto.
- **Siguiente paso:** preparar la **primera adopción** — identificar el proyecto adoptante y acompañar su fase 1 (el manual aún no ha sido ejecutado: la primera adopción lo estrena y lo corrige). Antes de ofrecerlo a un tercero: resolver los puntos 4/6/7 del issue #1.
- **Reglas activas:** commit/push autorizados por el dueño; merge a `main` solo humano; decisiones de producto, herramientas y hosting = del adoptante, no de este repo.
